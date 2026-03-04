/**
 * Shared helpers for channel setup scripts.
 *
 * Provides Inngest REST API access for webhook management.
 */

const INNGEST_API = process.env.INNGEST_DEV === "1"
  ? (process.env.INNGEST_BASE_URL ?? "http://localhost:8288")
  : "https://api.inngest.com";

function getSigningKey(): string {
  if (process.env.INNGEST_DEV === "1") return "dev";
  const key = process.env.INNGEST_SIGNING_KEY;
  if (!key) throw new Error("INNGEST_SIGNING_KEY is required");
  return key;
}

/**
 * Fetch from the Inngest REST API (authenticated with signing key).
 */
export async function inngestFetch(path: string, options: RequestInit = {}): Promise<any> {
  const envHeaders: Record<string, string> = {};
  if (process.env.INNGEST_ENV) {
    envHeaders["X-Inngest-Env"] = process.env.INNGEST_ENV;
  }
  const res = await fetch(`${INNGEST_API}${path}`, {
    ...options,
    headers: {
      "Authorization": `Bearer ${getSigningKey()}`,
      "Content-Type": "application/json",
      ...envHeaders,
      ...options.headers,
    },
  });
  const json = await res.json();
  if (!res.ok) {
    throw new Error(`Inngest API ${path}: ${res.status} — ${JSON.stringify(json)}`);
  }
  return json;
}
