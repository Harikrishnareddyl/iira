/**
 * LLM — wrapper around pi-ai's complete() function.
 *
 * pi-ai provides a unified interface for multiple LLM providers
 * (Anthropic, OpenAI, Google) with TypeBox-based tool validation.
 */

import { getModel, complete, validateToolArguments } from "@mariozechner/pi-ai";
import type { Tool, Message, AssistantMessage, KnownProvider, TextContent, ToolCall, Model } from "@mariozechner/pi-ai";
import { config } from "../config.ts";

export type { Tool, Message, AssistantMessage, TextContent, ToolCall };
export { validateToolArguments };

let _model: ReturnType<typeof getModel> | Model<"openai-completions"> | null = null;

// Mercury 2 API key — check INCEPTION_API_KEY first, fall back to MERCURY_API_KEY
function getMercuryApiKey(): string | undefined {
  return process.env.INCEPTION_API_KEY || process.env.MERCURY_API_KEY;
}

export function getConfiguredModel() {
  if (!_model) {
    if (config.llm.provider === "mercury") {
      // Mercury 2 is OpenAI-compatible — build a custom model object
      _model = {
        id: config.llm.model || "mercury-2",
        name: "Mercury 2",
        api: "openai-completions" as const,
        provider: "mercury",
        baseUrl: "https://api.inceptionlabs.ai/v1",
        reasoning: false,
        input: ["text"] as ("text" | "image")[],
        cost: { input: 0.00000025, output: 0.00000075, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128_000,
        maxTokens: 8_192,
        compat: {
          supportsStore: false,
          supportsDeveloperRole: false,
          supportsReasoningEffort: false,
          supportsUsageInStreaming: true,
          maxTokensField: "max_tokens" as const,
        },
      } satisfies Model<"openai-completions">;
    } else {
      // Provider and model come from runtime config (env vars).
      // getModel's generics require literal types from the MODELS registry,
      // so we assert here — an invalid combo will throw at runtime.
      _model = getModel(
        config.llm.provider as KnownProvider as any,
        config.llm.model as any,
      );
      if (!_model) {
        throw new Error(
          `Unknown model "${config.llm.model}" for provider "${config.llm.provider}". Check AGENT_MODEL and LLM_PROVIDER env vars.`,
        );
      }
    }
  }
  return _model;
}

export interface LLMResponse {
  /** The full AssistantMessage from pi-ai — push this directly into the message array */
  message: AssistantMessage;
  /** Extracted text content for convenience */
  text: string;
  /** Extracted tool calls for convenience */
  toolCalls: Array<{ id: string; name: string; arguments: Record<string, unknown> }>;
  usage: AssistantMessage["usage"];
  stopReason: AssistantMessage["stopReason"];
}

export async function callLLM(
  system: string,
  messages: Message[],
  tools: Tool[],
): Promise<LLMResponse> {
  const model = getConfiguredModel();

  const apiKey = config.llm.provider === "mercury" ? getMercuryApiKey() : undefined;

  const result = await complete(model, {
    systemPrompt: system,
    messages,
    tools,
    ...(apiKey ? { apiKey } : {}),
  });

  const text = result.content
    .filter((c): c is TextContent => c.type === "text")
    .map((c) => c.text)
    .join("");

  const toolCalls = result.content
    .filter((c): c is ToolCall => c.type === "toolCall")
    .map((c) => ({ id: c.id, name: c.name, arguments: c.arguments || {} }));

  // Strip OpenAI Responses API server-side item IDs (rs_xxx, msg IDs via textSignature,
  // and fc_xxx IDs via toolCall id suffix) from the message before it's stored in
  // Inngest's step memoization. Since we use store:false, these IDs expire after the
  // response and cause 404s when the function body replays on subsequent steps.
  for (const block of result.content) {
    if ("textSignature" in block) delete (block as any).textSignature;
    if ("thinkingSignature" in block) delete (block as any).thinkingSignature;
    if (block.type === "toolCall" && typeof (block as any).id === "string") {
      // id format is "call_id|item_id" — strip the item_id suffix
      (block as any).id = (block as any).id.split("|")[0];
    }
  }

  return {
    message: result,
    text,
    toolCalls,
    usage: result.usage,
    stopReason: result.stopReason,
  };
}
