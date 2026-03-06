/**
 * Tools — pi-coding-agent's battle-tested coding tools, wrapped for Inngest steps.
 *
 * Uses pi-coding-agent's tool implementations directly:
 * - read: offset/limit, image support, binary detection, smart truncation
 * - edit: exact text match + replace (surgical edits, not full file rewrites)
 * - write: create/overwrite files with directory creation
 * - grep: regex search respecting .gitignore
 * - find: glob-based file discovery respecting .gitignore
 * - ls: directory listing with tree display
 *
 * Plus custom tools specific to Utah:
 * - remember: append to daily memory log
 * - web_fetch: fetch a URL as text
 * - web_search: search via Exa (only available when EXA_API_KEY is set)
 * - run_command: run allowlisted project commands (npm/pnpm/node/python/etc.)
 * - git: run allowlisted git subcommands
 * - delegate_task: spawn a sub-agent via Inngest
 */

import { Type } from "@mariozechner/pi-ai";
import type { Tool, TextContent } from "@mariozechner/pi-ai";
import {
  createReadTool,
  createEditTool,
  createWriteTool,
  createGrepTool,
  createFindTool,
  createLsTool,
} from "@mariozechner/pi-coding-agent";
import type { AgentTool } from "@mariozechner/pi-agent-core";
import { spawn } from "child_process";
import { config } from "../config.ts";
import { appendDailyLog } from "./memory.ts";
import { hasMcpServers, listMcpTools, callMcpTool } from "./mcp.ts";
import {
  ALLOWED_COMMANDS,
  SHELL_OPERATORS,
  ALLOWED_GIT_SUBCOMMANDS,
  GIT_DESTRUCTIVE_SUBCOMMANDS,
  BLOCKED_GIT_FLAGS,
  WEB_FETCH_MAX_BYTES,
  WEB_FETCH_TIMEOUT_MS,
  WEB_SEARCH_DEFAULT_RESULTS,
  WEB_SEARCH_MAX_RESULTS,
  WEB_SEARCH_TIMEOUT_MS,
  RUN_COMMAND_TIMEOUT_MS,
  RUN_COMMAND_MAX_OUTPUT_BYTES,
  GIT_TIMEOUT_MS,
} from "./tool-policy.ts";

// --- Pi-coding-agent tools (configured for workspace) ---

// Cast to AgentTool<any>[] — the specific TSchema generics cause contravariance issues
// but the tools are used dynamically (looked up by name) so this is safe.
const piTools: AgentTool<any>[] = [
  createReadTool(config.workspace.root),
  createEditTool(config.workspace.root),
  createWriteTool(config.workspace.root),
  createGrepTool(config.workspace.root),
  createFindTool(config.workspace.root),
  createLsTool(config.workspace.root),
];

// --- run_command tool ---

function parseRunCommand(command: string): { bin: string; args: string[] } | null {
  if (SHELL_OPERATORS.test(command)) return null;
  const parts = command.trim().split(/\s+/);
  if (!ALLOWED_COMMANDS.has(parts[0])) return null;
  return { bin: parts[0], args: parts.slice(1) };
}

const runCommandTool: Tool = {
  name: "run_command",
  description:
    "Run a project command in the workspace. Use for: installing dependencies, running tests, building, running scripts. " +
    "Allowed: npm, pnpm, npx, node, python, python3, pip, pip3, deno, bun. " +
    "Shell operators (|, >, &&, ;) are not supported.",
  parameters: Type.Object({
    command: Type.String({
      description: 'Command to run, e.g. "pnpm install", "npm test", "node scripts/seed.js"',
    }),
  }),
};

// --- git tool ---

function parseGitArgs(args: string): string[] | null {
  const parts = args.trim().split(/\s+/);
  if (!ALLOWED_GIT_SUBCOMMANDS.has(parts[0])) return null;
  if (GIT_DESTRUCTIVE_SUBCOMMANDS.has(parts[0])) {
    for (const part of parts) {
      if (BLOCKED_GIT_FLAGS.has(part)) return null;
    }
  }
  return parts;
}

const gitTool: Tool = {
  name: "git",
  description:
    "Run a git command in the workspace. Use for: status, diff, log, add, commit, branch, checkout, pull, push, stash, reset, etc. " +
    "Force flags (--force, -f) are blocked on destructive operations.",
  parameters: Type.Object({
    args: Type.String({
      description:
        'Git arguments (without "git"), e.g. "status", "diff HEAD", "log --oneline -10", "commit -m \'fix: typo\'"',
    }),
  }),
};

// --- web_search tool (Exa, optional) ---

const webSearchTool: Tool = {
  name: "web_search",
  description:
    "Search the web using Exa. Returns titles, URLs, and snippets. " +
    "Use this to find relevant URLs before using web_fetch, rather than guessing URLs.",
  parameters: Type.Object({
    query: Type.String({ description: "Search query" }),
    num_results: Type.Optional(
      Type.Number({ description: "Number of results to return (default 5, max 10)", minimum: 1, maximum: 10 }),
    ),
  }),
};

// --- remember tool ---

const rememberTool: Tool = {
  name: "remember",
  description:
    "Save a note to today's daily log. Use for things you want to remember across conversations — decisions, facts, user preferences, task outcomes.",
  parameters: Type.Object({
    note: Type.String({ description: "The note to save" }),
  }),
};

// --- web_fetch tool ---

const webFetchTool: Tool = {
  name: "web_fetch",
  description: "Fetch a URL and return the response body as text",
  parameters: Type.Object({
    url: Type.String({ description: "URL to fetch" }),
  }),
};

// --- mcp_list tool ---

const mcpListTool: Tool = {
  name: "mcp_list",
  description:
    "List all configured MCP servers and their available tools. Use this before mcp_call to discover what's available.",
  parameters: Type.Object({}),
};

// --- mcp_call tool ---

const mcpCallTool: Tool = {
  name: "mcp_call",
  description:
    "Call a tool on a configured MCP server. Use mcp_list first to discover available servers and tool names.",
  parameters: Type.Object({
    server: Type.String({ description: "MCP server alias (as shown by mcp_list)" }),
    tool: Type.String({ description: "Tool name to call" }),
    args: Type.Optional(
      Type.Record(Type.String(), Type.Unknown({ description: "Tool arguments" })),
    ),
  }),
};

// --- delegate_task tool ---

const delegateTaskTool: Tool = {
  name: "delegate_task",
  description: `Delegate a self-contained task to a sub-agent that runs in an isolated context window.
Use this when:
- The task requires many file reads/edits (4+ tool calls expected)
- The task is independent and can be described as a clear goal
- You want to keep your own context lean
The sub-agent has access to the same workspace and tools but its own conversation.
You'll receive a summary of what it accomplished.`,
  parameters: Type.Object({
    task: Type.String({
      description:
        "Clear, detailed description of what the sub-agent should do. Include file paths, goals, and constraints.",
    }),
  }),
};

// --- Exports ---

const baseTools: Tool[] = [
  ...piTools,
  rememberTool,
  webFetchTool,
  runCommandTool,
  gitTool,
  delegateTaskTool,
];

const baseSubAgentTools: Tool[] = [
  ...piTools,
  rememberTool,
  webFetchTool,
  runCommandTool,
  gitTool,
];

// web_search is only available when EXA_API_KEY is configured
export const hasExa = Boolean(process.env.EXA_API_KEY);

// mcp_list/mcp_call are only available when MCP_SERVERS is configured
export const hasMcp = hasMcpServers();

const mcpTools: Tool[] = hasMcp ? [mcpListTool, mcpCallTool] : [];

/**
 * All tools available to the main agent (includes delegate_task).
 */
export const TOOLS: Tool[] = [
  ...(hasExa ? [...baseTools, webSearchTool] : baseTools),
  ...mcpTools,
];

/**
 * Tools available to sub-agents (no delegate_task to prevent recursive spawning).
 */
export const SUB_AGENT_TOOLS: Tool[] = [
  ...(hasExa ? [...baseSubAgentTools, webSearchTool] : baseSubAgentTools),
  ...mcpTools,
];

/**
 * Map of pi-coding-agent tools by name for direct execution.
 */
const piToolMap = new Map<string, AgentTool>(piTools.map((t) => [t.name, t]));

// --- Tool Execution ---

export interface ToolResult {
  /** Text content returned to the LLM */
  result: string;
  /** Whether this result represents an error */
  error?: boolean;
}

/**
 * Run a child process and return combined stdout+stderr.
 */
function runProcess(
  bin: string,
  args: string[],
  cwd: string,
  timeoutMs: number,
  maxOutputBytes = 20_000,
): Promise<{ output: string; exitCode: number | null }> {
  return new Promise((resolve) => {
    const chunks: Buffer[] = [];
    const proc = spawn(bin, args, { cwd, stdio: ["ignore", "pipe", "pipe"] });

    proc.stdout.on("data", (d: Buffer) => chunks.push(d));
    proc.stderr.on("data", (d: Buffer) => chunks.push(d));

    const timer = setTimeout(() => {
      proc.kill();
      resolve({ output: "(timed out)", exitCode: null });
    }, timeoutMs);

    proc.on("close", (code) => {
      clearTimeout(timer);
      const raw = Buffer.concat(chunks).toString("utf-8");
      resolve({
        output: raw.length > maxOutputBytes ? raw.slice(0, maxOutputBytes) + "\n...(truncated)" : raw,
        exitCode: code,
      });
    });
  });
}

/**
 * Execute a tool by name.
 */
export async function executeTool(
  toolCallId: string,
  name: string,
  args: Record<string, unknown>,
): Promise<ToolResult> {
  try {
    // Check if it's a pi-coding-agent tool
    const piTool = piToolMap.get(name);
    if (piTool) {
      const result = await piTool.execute(toolCallId, args);

      // Convert AgentToolResult to our ToolResult format
      const text = result.content
        .filter((c): c is TextContent => c.type === "text")
        .map((c) => c.text)
        .join("\n");

      return { result: text || "(no output)" };
    }

    // Custom tools
    switch (name) {
      case "remember": {
        await appendDailyLog(args.note as string);
        return { result: "Saved to today's log." };
      }

      case "web_fetch": {
        const res = await fetch(args.url as string, {
          signal: AbortSignal.timeout(WEB_FETCH_TIMEOUT_MS),
          headers: { "User-Agent": "Utah-Agent/1.0" },
        });
        const text = await res.text();
        return { result: text.slice(0, WEB_FETCH_MAX_BYTES) };
      }

      case "web_search": {
        const apiKey = process.env.EXA_API_KEY;
        if (!apiKey) {
          return { result: "EXA_API_KEY is not set.", error: true };
        }
        const numResults = Math.min(Number(args.num_results ?? WEB_SEARCH_DEFAULT_RESULTS), WEB_SEARCH_MAX_RESULTS);
        const res = await fetch("https://api.exa.ai/search", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-api-key": apiKey,
          },
          body: JSON.stringify({
            query: args.query,
            numResults,
            useAutoprompt: true,
          }),
          signal: AbortSignal.timeout(WEB_SEARCH_TIMEOUT_MS),
        });
        if (!res.ok) {
          const err = await res.text();
          return { result: `Exa search error ${res.status}: ${err}`, error: true };
        }
        const data = (await res.json()) as { results: Array<{ title: string; url: string; snippet?: string }> };
        const lines = data.results.map(
          (r) => `${r.title}\n${r.url}${r.snippet ? `\n${r.snippet}` : ""}`,
        );
        return { result: lines.join("\n\n") || "(no results)" };
      }

      case "run_command": {
        const parsed = parseRunCommand(args.command as string);
        if (!parsed) {
          return {
            result: `Command not allowed. Only these are permitted: ${[...ALLOWED_COMMANDS].join(", ")}. Shell operators (|, >, &&, ;) are not supported.`,
            error: true,
          };
        }
        const { output, exitCode } = await runProcess(
          parsed.bin,
          parsed.args,
          config.workspace.root,
          RUN_COMMAND_TIMEOUT_MS,
          RUN_COMMAND_MAX_OUTPUT_BYTES,
        );
        return {
          result: `Exit code: ${exitCode ?? "killed"}\n${output}`,
          error: exitCode !== 0 && exitCode !== null,
        };
      }

      case "git": {
        const parsed = parseGitArgs(args.args as string);
        if (!parsed) {
          const sub = (args.args as string).trim().split(/\s+/)[0];
          if (!ALLOWED_GIT_SUBCOMMANDS.has(sub)) {
            return {
              result: `Git subcommand "${sub}" is not allowed. Allowed: ${[...ALLOWED_GIT_SUBCOMMANDS].join(", ")}.`,
              error: true,
            };
          }
          return {
            result: `Blocked: force flags (--force, -f, --hard) are not allowed on destructive git operations.`,
            error: true,
          };
        }
        const { output, exitCode } = await runProcess(
          "git",
          parsed,
          config.workspace.root,
          GIT_TIMEOUT_MS,
        );
        return {
          result: output || "(no output)",
          error: exitCode !== 0 && exitCode !== null,
        };
      }

      case "mcp_list": {
        const all = await listMcpTools();
        if (all.length === 0) return { result: "No MCP servers connected." };
        const lines = all.map(
          ({ server, tools }) =>
            `${server}:\n${tools.map((t) => `  - ${t.name}${t.description ? `: ${t.description}` : ""}`).join("\n")}`,
        );
        return { result: lines.join("\n\n") };
      }

      case "mcp_call": {
        const result = await callMcpTool(
          args.server as string,
          args.tool as string,
          (args.args as Record<string, unknown>) ?? {},
        );
        return { result };
      }

      default:
        return { result: `Unknown tool: ${name}`, error: true };
    }
  } catch (err) {
    return {
      result: `Error: ${err instanceof Error ? err.message : String(err)}`,
      error: true,
    };
  }
}
