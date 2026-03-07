/**
 * Message Handler — the main agent function.
 *
 * Trigger: agent.message.received
 * Flow: load session → run agent loop → save result → emit reply event
 *
 * Key Inngest features used:
 * - Singleton (one run per chat at a time)
 * - Step-based execution (each LLM call and tool is a step)
 */

import { inngest, agentMessageReceived } from "../client.ts";
import { createAgentLoop } from "../agent-loop.ts";
import { appendToSession } from "../lib/session.ts";
import { config } from "../config.ts";
import { MESSAGE_MAX_CHARS } from "../lib/tool-policy.ts";

export const handleMessage = inngest.createFunction(
  {
    id: "agent-handle-message",
    retries: 2,
    triggers: [agentMessageReceived],
    singleton: { key: "event.data.sessionKey", mode: "cancel" },
  },
  async ({ event, step }) => {
    let {
      message,
      sessionKey = "main",
      channel = "unknown",
      destination,
      channelMeta = {},
    } = event.data;

    // Enforce Telegram allowed-chat filter
    if (channel === "telegram") {
      const allowed = config.telegram.allowedChatIds;
      if (allowed.length > 0 && !allowed.includes(destination?.chatId ?? "")) {
        console.log(`[message] Telegram chatId "${destination?.chatId}" not in allowlist — dropping`);
        return;
      }
    }

    // Truncate oversized messages
    if (message.length > MESSAGE_MAX_CHARS) {
      console.warn(`[message] Truncating message from ${message.length} to ${MESSAGE_MAX_CHARS} chars`);
      message = message.slice(0, MESSAGE_MAX_CHARS);
    }

    // Save the incoming message
    await step.run("save-incoming", async () => {
      await appendToSession(sessionKey, "user", message);
    });

    // Run the agent loop — each think/tool is a durable step
    const agentLoop = createAgentLoop(message, sessionKey);
    const result = await agentLoop(step);

    // Save the response
    await step.run("save-response", async () => {
      await appendToSession(sessionKey, "assistant", result.response, {
        iterations: result.iterations,
        toolCalls: result.toolCalls,
      });
    });

    // Emit a reply event — destination and channelMeta pass through
    if (destination) {
      await step.sendEvent("reply", {
        name: "agent.reply.ready",
        data: {
          response: result.response,
          channel,
          destination,
          channelMeta,
        },
      });
    }

    return result;
  },
);
