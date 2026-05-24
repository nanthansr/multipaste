import { createClient } from "@supabase/supabase-js";

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

export default async function handler(req) {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await req.text();
  const params = new URLSearchParams(body);

  const licenseKey = params.get("license_key");
  const email = params.get("email");
  const saleId = params.get("sale_id");

  if (!licenseKey) {
    return new Response("Missing license_key", { status: 400 });
  }

  await supabase.from("purchases").upsert(
    { license_key: licenseKey, email, gumroad_sale_id: saleId },
    { onConflict: "license_key" }
  );

  return new Response("ok", { status: 200 });
}

export const config = { runtime: "edge" };
