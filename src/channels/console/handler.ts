/**
 * Console channel — logs replies to stdout. Used for local dev testing.
 */

import type { ChannelHandler, SendReplyParams, AcknowledgeParams } from "../types.ts";

export const sendReply = async ({ response }: SendReplyParams): Promise<void> => {
  console.log("\n=== Agent Reply ===");
  console.log(response);
  console.log("==================\n");
};

export const acknowledge = async (_params: AcknowledgeParams): Promise<void> => {
  console.log("[console] thinking...");
};

export const consoleHandler: ChannelHandler = { sendReply, acknowledge };
