/**
 * Minimal test function to debug auth issues
 * No Firebase imports - just tests auth token verification
 */

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, OPTIONS",
};

function base64UrlDecode(str: string): string {
  str = str.replace(/-/g, "+").replace(/_/g, "/");
  while (str.length % 4) str += "=";
  return atob(str);
}

serve(async (req: Request) => {
  console.log("test-auth: Request received");

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const startTime = Date.now();
  console.log(`test-auth: [${Date.now() - startTime}ms] Starting`);

  try {
    // Get auth header
    const authHeader = req.headers.get("Authorization");
    console.log(`test-auth: [${Date.now() - startTime}ms] Auth header present: ${!!authHeader}`);

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ success: false, error: "No auth header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const token = authHeader.replace("Bearer ", "");
    console.log(`test-auth: [${Date.now() - startTime}ms] Token length: ${token.length}`);

    // Parse JWT (no verification, just decode)
    const parts = token.split(".");
    if (parts.length !== 3) {
      return new Response(
        JSON.stringify({ success: false, error: "Invalid JWT format" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const payload = JSON.parse(base64UrlDecode(parts[1]));
    console.log(`test-auth: [${Date.now() - startTime}ms] Decoded token for user: ${payload.sub}`);

    const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
    const now = Math.floor(Date.now() / 1000);

    // Validate claims
    const validations = {
      hasSub: !!payload.sub,
      notExpired: !payload.exp || payload.exp >= now,
      notFuture: !payload.iat || payload.iat <= now + 300,
      correctAud: payload.aud === projectId,
      correctIss: payload.iss === `https://securetoken.google.com/${projectId}`,
    };

    console.log(`test-auth: [${Date.now() - startTime}ms] Validations:`, JSON.stringify(validations));

    const allValid = Object.values(validations).every(v => v);

    if (!allValid) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "Token validation failed",
          validations,
          tokenAud: payload.aud,
          tokenIss: payload.iss,
          expectedAud: projectId,
          expectedIss: `https://securetoken.google.com/${projectId}`,
        }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    console.log(`test-auth: [${Date.now() - startTime}ms] Success!`);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Auth test passed!",
        uid: payload.sub,
        elapsed: Date.now() - startTime,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error(`test-auth: Error:`, error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
