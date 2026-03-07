/**
 * Context — builds the system prompt and conversation history for the agent.
 *
 * Injects workspace context files (IDENTITY.md, SOUL.md, USER.md) and
 * memory (MEMORY.md + daily logs) into the system prompt.
 */

import { existsSync } from "fs";
import { readFile } from "fs/promises";
import { resolve } from "path";
import { config } from "../config.ts";
import { buildMemoryContext } from "./memory.ts";
import { hasExa, hasMcp } from "./tools.ts";
import { loadSession, type SessionMessage } from "./session.ts";

/**
 * Load an optional markdown file from the workspace root.
 * Returns null if the file doesn't exist.
 */
async function loadOptionalFile(filename: string): Promise<string | null> {
  const path = resolve(config.workspace.root, filename);
  if (!existsSync(path)) return null;
  try {
    return await readFile(path, "utf-8");
  } catch {
    return null;
  }
}

/**
 * Build the full system prompt.
 *
 * Structure:
 * 0. Current goal (if userMessage provided — anchors attention for long tool sequences)
 * 1. Identity (IDENTITY.md, SOUL.md, or default)
 * 2. User info (USER.md)
 * 3. Memory (MEMORY.md + daily logs)
 * 4. Tool usage guidelines
 */
export async function buildSystemPrompt(userMessage?: string): Promise<string> {
  const identity = await loadOptionalFile("IDENTITY.md");
  const soul = await loadOptionalFile("SOUL.md");
  const user = await loadOptionalFile("USER.md");
  const memory = await buildMemoryContext();

  const parts: string[] = [];

  // Goal anchoring — inject at top so it stays visible across long tool sequences
  if (userMessage) {
    parts.push(`## Current Goal\n${userMessage.trim()}`);
  }

  // Identity
  if (soul) {
    parts.push(soul);
  } else if (identity) {
    parts.push(identity);
  } else {
    parts.push(
      `You are ${config.agent.name}, a helpful AI assistant powered by Inngest.`,
    );
  }

  // User info
  if (user) {
    parts.push(`## About the User\n${user}`);
  }

  // Memory
  parts.push(`## Memory\n${memory}`);

  // Guidelines
  const webSearchLine = hasExa
    ? "\n- **web_search**: Search the web via Exa — use this to find URLs before using web_fetch"
    : "";
  const mcpLines = hasMcp
    ? "\n- **mcp_list**: List all configured MCP servers and their available tools\n- **mcp_call**: Call a tool on a configured MCP server"
    : "";
  parts.push(`## Tools & Guidelines

Available tools:
- **read**: Read file contents (supports offset/limit for large files)
- **edit**: Make precise edits to files (find exact text and replace — use this for surgical changes)
- **write**: Create new files or completely overwrite existing ones
- **grep**: Search file contents for patterns (respects .gitignore)
- **find**: Find files by glob pattern (respects .gitignore)
- **ls**: List directory contents
- **run_command**: Run project commands (npm/pnpm/node/python/etc.) in the workspace
- **git**: Run git operations (status, diff, log, add, commit, push, etc.)
- **remember**: Save a note to today's daily log
- **web_fetch**: Fetch a URL and return the body as text${webSearchLine}${mcpLines}

Guidelines:
- Use **read** to examine files before editing. Never use cat or sed.
- Use **edit** for precise changes (old text must match exactly). Prefer edit over write for modifications.
- Use **write** only for new files or complete rewrites.
- Use **grep/find/ls** for file exploration (faster, respects .gitignore).
- Use **run_command** to run scripts/tests/installs. Use **git** for version control.${hasExa ? "\n- Use **web_search** to find relevant URLs, then **web_fetch** to read them." : ""}${hasMcp ? "\n- Use **mcp_list** to discover available MCP tools, then **mcp_call** to invoke them." : ""}
- Be concise in your responses. Show file paths clearly when working with files.
- When summarizing actions, output plain text — do NOT display raw output with echo or cat.

Current time: ${new Date().toISOString()}
Working directory: ${config.workspace.root}

## How to Respond
- Your text response IS the reply. When you respond with text and no tool calls, the conversation turn ends.
- For most messages: just reply with text. No tools needed.
- Only use tools when you actually need to read/write files, run commands, or fetch URLs.
- Do NOT explore the workspace or read files unless the user asks you to.
- When using tools: gather what you need, then respond with text. Do not chain unnecessary tool calls.

## Tool Call Discipline
- Each tool call costs time and tokens. Be efficient.
- If you can answer from what you already know, do that.
- If one tool call gives you the answer, respond immediately.
- Never loop on the same tool with slightly different inputs hoping for a better result.`);

  return parts.join("\n\n---\n\n");
}

/**
 * Build conversation messages from session history.
 */
export async function buildConversationHistory(
  sessionKey: string,
  maxMessages = 10,
): Promise<SessionMessage[]> {
  const history = await loadSession(sessionKey, maxMessages);
  const filtered = history.filter((m) => m.role === "user" || m.role === "assistant");
  // Drop the last entry if it's a user message — the agent loop always appends
  // the current userMessage explicitly, and save-incoming already wrote it to the session.
  if (filtered.length > 0 && filtered[filtered.length - 1].role === "user") {
    filtered.pop();
  }
  return filtered;
}
