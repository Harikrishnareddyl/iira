/**
 * MCP — Model Context Protocol client manager.
 *
 * Connects to configured MCP servers at startup and exposes their tools
 * to the agent via mcp_list and mcp_call.
 *
 * Two transport types are supported (matching OpenHands):
 * - stdio: spawn a subprocess MCP server  { command, args?, env?, cwd? }
 * - http:  connect to a running server    { url, headers? }
 *
 * Servers are configured in tool-policy.ts via the MCP_SERVERS constant.
 */

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { MCP_SERVERS } from "./tool-policy.ts";

// ---------------------------------------------------------------------------
// Config types
// ---------------------------------------------------------------------------

export type McpStdioConfig = {
  command: string;
  args?: string[];
  env?: Record<string, string>;
  cwd?: string;
};

export type McpHttpConfig = {
  url: string;
  headers?: Record<string, string>;
};

export type McpServerConfig = McpStdioConfig | McpHttpConfig;

function isStdio(cfg: McpServerConfig): cfg is McpStdioConfig {
  return "command" in cfg;
}

// ---------------------------------------------------------------------------
// MCP tool shape (subset of what the SDK returns)
// ---------------------------------------------------------------------------

export interface McpTool {
  name: string;
  description?: string;
  inputSchema: Record<string, unknown>;
}

// ---------------------------------------------------------------------------
// Internal state
// ---------------------------------------------------------------------------

const clients = new Map<string, Client>();
const toolsByServer = new Map<string, McpTool[]>();

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/**
 * Returns true if at least one MCP server is configured in tool-policy.ts.
 * Checked at module load time to decide whether to include MCP tools.
 */
export function hasMcpServers(): boolean {
  return Object.keys(MCP_SERVERS).length > 0;
}

/**
 * Returns all tools grouped by server alias.
 */
export async function listMcpTools(): Promise<{ server: string; tools: McpTool[] }[]> {
  return [...toolsByServer.entries()].map(([server, tools]) => ({ server, tools }));
}

/**
 * Call a tool on a specific MCP server.
 * Returns the result as a formatted string.
 */
export async function callMcpTool(
  server: string,
  tool: string,
  args: Record<string, unknown>,
  timeoutMs = 60_000,
): Promise<string> {
  const client = clients.get(server);
  if (!client) {
    throw new Error(`Unknown MCP server "${server}". Available: ${[...clients.keys()].join(", ")}`);
  }

  const timeoutPromise = new Promise<never>((_, reject) =>
    setTimeout(() => reject(new Error(`MCP tool call timed out after ${timeoutMs}ms`)), timeoutMs),
  );

  type ContentBlock = { type: string; text?: string; data?: string; mimeType?: string };
  const callPromise = client.callTool({ name: tool, arguments: args }) as Promise<{ content: ContentBlock[] }>;
  const result = await Promise.race([callPromise, timeoutPromise]);

  // Flatten content blocks to a string
  if (!result.content || result.content.length === 0) return "(no output)";

  return result.content
    .map((block) => {
      if (block.type === "text") return block.text ?? "";
      if (block.type === "image") return `[image: ${block.mimeType ?? "unknown"}]`;
      return JSON.stringify(block);
    })
    .join("\n");
}

/**
 * Connect to all configured MCP servers.
 * Failures are logged but do not prevent other servers from connecting.
 * Call once at startup before serving requests.
 */
export async function initMcpClients(servers: Record<string, McpServerConfig>): Promise<void> {
  const aliases = Object.keys(servers);
  if (aliases.length === 0) return;

  await Promise.all(
    aliases.map(async (alias) => {
      try {
        await connectServer(alias, servers[alias]);
        const tools = toolsByServer.get(alias) ?? [];
        console.log(`[mcp] connected: ${alias} (${tools.length} tools)`);
      } catch (err) {
        console.warn(`[mcp] failed to connect "${alias}": ${err instanceof Error ? err.message : String(err)}`);
      }
    }),
  );
}

/**
 * Disconnect all MCP clients. Call on graceful shutdown.
 */
export async function closeMcpClients(): Promise<void> {
  await Promise.all([...clients.values()].map((c) => c.close().catch(() => {})));
  clients.clear();
  toolsByServer.clear();
}

// ---------------------------------------------------------------------------
// Internal
// ---------------------------------------------------------------------------

async function connectServer(alias: string, cfg: McpServerConfig): Promise<void> {
  const client = new Client({ name: "utah-agent", version: "1.0.0" });

  if (isStdio(cfg)) {
    const transport = new StdioClientTransport({
      command: cfg.command,
      args: cfg.args,
      env: cfg.env,
      cwd: cfg.cwd,
      stderr: "pipe",
    });
    await client.connect(transport);
  } else {
    // Try Streamable HTTP first, fall back to SSE
    const url = new URL(cfg.url);
    try {
      const transport = new StreamableHTTPClientTransport(url, {
        requestInit: cfg.headers ? { headers: cfg.headers } : undefined,
      });
      await client.connect(transport);
    } catch {
      // Fall back to SSE transport (legacy servers)
      const sseTransport = new SSEClientTransport(url, {
        requestInit: cfg.headers ? { headers: cfg.headers } : undefined,
      });
      await client.connect(sseTransport);
    }
  }

  // Discover tools
  const { tools } = await client.listTools();
  toolsByServer.set(alias, tools as McpTool[]);
  clients.set(alias, client);
}
