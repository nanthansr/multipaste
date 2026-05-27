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

  const supabaseUrl = process.env.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  await fetch(`${supabaseUrl}/rest/v1/purchases`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": serviceKey,
      "Authorization": `Bearer ${serviceKey}`,
      "Prefer": "resolution=merge-duplicates",
    },
    body: JSON.stringify({ license_key: licenseKey, email, gumroad_sale_id: saleId }),
  });

  return new Response("ok", { status: 200 });
}

export const config = { runtime: "edge" };
