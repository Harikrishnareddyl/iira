/**
 * Worker — registers Inngest functions and connects via WebSocket.
 */
// Load the Inngest client w/ extended traces before anything else
import { inngest } from "./client.ts";
import { connect } from "inngest/connect";
import { handleMessage } from "./functions/message.ts";
import { sendReply } from "./functions/send-reply.ts";
import { acknowledgeMessage } from "./functions/acknowledge-message.ts";
import { failureHandler } from "./functions/failure-handler.ts";
import { heartbeat } from "./functions/heartbeat.ts";
import { subAgent } from "./functions/sub-agent.ts";
import { ensureWorkspace } from "./lib/session.ts";
import { setup } from "./setup.ts";
import { config } from "./config.ts";
import { initMcpClients } from "./lib/mcp.ts";
import { MCP_SERVERS } from "./lib/tool-policy.ts";

const functions = [
  handleMessage,
  sendReply,
  acknowledgeMessage,
  failureHandler,
  heartbeat,
  subAgent,
];

async function main() {
  // Validate required env vars before anything else
  const apiKeyMap: Record<string, string> = {
    anthropic: "ANTHROPIC_API_KEY",
    openai: "OPENAI_API_KEY",
    google: "GOOGLE_API_KEY",
    mercury: "INCEPTION_API_KEY",
  };
  const requiredKey = apiKeyMap[config.llm.provider];
  const hasMercuryKey = config.llm.provider === "mercury" &&
    (process.env.INCEPTION_API_KEY || process.env.MERCURY_API_KEY);
  if (requiredKey && !process.env[requiredKey] && !hasMercuryKey) {
    throw new Error(`Missing required env var: ${requiredKey} (provider: ${config.llm.provider})`);
  }
  const isDevMode = process.env.INNGEST_DEV === "1";
  if (!isDevMode && !process.env.INNGEST_SIGNING_KEY) {
    console.warn("⚠️  INNGEST_SIGNING_KEY not set — required for production");
  }

  await ensureWorkspace(config.workspace.root);

  // Connect to MCP servers (no-op if MCP_SERVERS is empty)
  await initMcpClients(MCP_SERVERS);

  // Ensure Inngest webhook + Telegram webhook are configured
  await setup();

  console.log(`🤖 ${config.agent.name} starting...`);
  console.log(`   Model: ${config.llm.provider}/${config.llm.model}`);
  console.log(`   Workspace: ${config.workspace.root}`);
  console.log(`   Functions: ${functions.length}`);

  await connect({
    apps: [{ client: inngest, functions }],
    handleShutdownSignals: ["SIGTERM", "SIGINT"],
  });
  console.log(`   Inngest: WebSocket connected`);
  console.log(`\n✅ ${config.agent.name} is alive\n`);
}

main().catch((e) => {
  console.error("Fatal error:", e);
  process.exit(1);
});
