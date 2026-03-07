/**
 * Tool Policy — all allowlists, blocklists, and server configs for agent tools.
 *
 * Edit this file to control what the agent is and isn't allowed to do.
 * Changes here take effect immediately on next worker restart.
 */

import type { McpServerConfig } from "./mcp.ts";

// ---------------------------------------------------------------------------
// run_command
// ---------------------------------------------------------------------------

/**
 * Binaries the agent can invoke via run_command.
 * Only the first token of the command is checked against this list.
 */
export const ALLOWED_COMMANDS = new Set([
  "npm",
  "pnpm",
  "npx",
  "node",
  "python",
  "python3",
  "pip",
  "pip3",
  "deno",
  "bun",
]);

/**
 * Shell metacharacters that are always blocked in run_command.
 * Prevents shell injection and pipeline composition.
 */
export const SHELL_OPERATORS = /[|>&;`$(){}]/;

// ---------------------------------------------------------------------------
// git
// ---------------------------------------------------------------------------

/**
 * Git subcommands the agent may run.
 * Remove entries to restrict access to specific operations.
 */
export const ALLOWED_GIT_SUBCOMMANDS = new Set([
  "status",
  "diff",
  "log",
  "show",
  "add",
  "commit",
  "branch",
  "checkout",
  "switch",
  "pull",
  "push",
  "fetch",
  "stash",
  "reset",
  "revert",
  "merge",
  "rebase",
  "tag",
  "remote",
  "init",
  "clone",
]);

/**
 * Git subcommands on which force/hard flags are checked and blocked.
 * Add subcommands here to extend protection to more operations.
 */
export const GIT_DESTRUCTIVE_SUBCOMMANDS = new Set([
  "push",
  "reset",
  "checkout",
  "rebase",
]);

/**
 * Flags blocked when used on GIT_DESTRUCTIVE_SUBCOMMANDS.
 */
export const BLOCKED_GIT_FLAGS = new Set([
  "--force",
  "-f",
  "--hard",
]);

// ---------------------------------------------------------------------------
// web_fetch
// ---------------------------------------------------------------------------

/**
 * Maximum response body size returned by web_fetch (bytes).
 * Larger responses are truncated to this limit.
 */
export const WEB_FETCH_MAX_BYTES = 50_000;

/** Timeout for web_fetch requests (milliseconds). */
export const WEB_FETCH_TIMEOUT_MS = 30_000;

// ---------------------------------------------------------------------------
// web_search (Exa)
// ---------------------------------------------------------------------------

/** Default number of search results returned by web_search. */
export const WEB_SEARCH_DEFAULT_RESULTS = 5;

/** Maximum number of results the agent can request from web_search. */
export const WEB_SEARCH_MAX_RESULTS = 10;

/** Timeout for web_search requests (milliseconds). */
export const WEB_SEARCH_TIMEOUT_MS = 15_000;

// ---------------------------------------------------------------------------
// run_command execution
// ---------------------------------------------------------------------------

/** Timeout for run_command execution (milliseconds). */
export const RUN_COMMAND_TIMEOUT_MS = 60_000;

/** Maximum combined stdout+stderr returned by run_command (bytes). */
export const RUN_COMMAND_MAX_OUTPUT_BYTES = 20_000;

// ---------------------------------------------------------------------------
// git execution
// ---------------------------------------------------------------------------

/** Timeout for git command execution (milliseconds). */
export const GIT_TIMEOUT_MS = 30_000;

// ---------------------------------------------------------------------------
// mcp
// ---------------------------------------------------------------------------

/**
 * MCP servers available to the agent.
 * Add entries here to connect to MCP servers at startup.
 *
 * Two transport types:
 *   stdio — spawn a subprocess:  { command, args?, env?, cwd? }
 *   http  — connect to a URL:    { url, headers? }
 *
 * Examples:
 *   github: { command: "npx", args: ["-y", "@modelcontextprotocol/server-github"], env: { GITHUB_TOKEN: "ghp_..." } }
 *   fs:     { command: "npx", args: ["-y", "@modelcontextprotocol/server-filesystem", "./workspace"] }
 *   myapi:  { url: "http://localhost:3001/mcp" }
 */
export const MCP_SERVERS: Record<string, McpServerConfig> = {
  // "github": { command: "npx", args: ["-y", "@modelcontextprotocol/server-github"], env: { GITHUB_TOKEN: "" } },
};

/** Timeout for individual MCP tool calls (milliseconds). */
export const MCP_CALL_TIMEOUT_MS = 60_000;

// ---------------------------------------------------------------------------
// message
// ---------------------------------------------------------------------------

/**
 * Maximum incoming message length in characters.
 * Messages longer than this are truncated before reaching the agent loop.
 */
export const MESSAGE_MAX_CHARS = 32_000;
