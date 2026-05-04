"use client";

import { CheckCircle } from "lucide-react";
import { useSearchParams } from "next/navigation";
import { Suspense } from "react";

function VerificationCompleteContent() {
  const searchParams = useSearchParams();
  const flow = searchParams.get("flow");
  const isReset = flow === "reset";

  const title = isReset ? "Password updated" : "Verification complete";
  const body = isReset
    ? "Your password has been updated. Please return to the EBOMIM mobile app and sign in with your email and new password."
    : "Your email has been verified. Please open the EBOMIM mobile app and sign in with your email and password.";

  return (
    <>
      <div className="mb-6 flex justify-center">
        <div className="flex h-16 w-16 items-center justify-center rounded-full bg-emerald-50 ring-4 ring-emerald-100">
          <CheckCircle className="h-10 w-10 text-emerald-600" aria-hidden />
        </div>
      </div>
      <h1 className="text-center text-2xl font-bold text-red-600 md:text-3xl">{title}</h1>
      <p className="mt-4 text-center text-sm leading-relaxed text-gray-600 md:text-base">{body}</p>
    </>
  );
}

export default function VerificationCompletePage() {
  return (
    <div className="relative flex min-h-screen items-center justify-center bg-gradient-to-br from-pink-50 via-red-50 to-pink-100 p-4">
      <div className="pointer-events-none absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 h-80 w-80 rounded-full bg-red-200/30 blur-3xl" />
        <div className="absolute -bottom-40 -left-40 h-80 w-80 rounded-full bg-pink-200/30 blur-3xl" />
      </div>

      <div className="relative z-10 w-full max-w-md rounded-2xl bg-white p-8 shadow-2xl md:p-10">
        <Suspense
          fallback={
            <div className="flex flex-col items-center gap-4 py-4">
              <div className="h-10 w-10 animate-spin rounded-full border-2 border-red-600 border-t-transparent" />
              <p className="text-sm text-gray-500">Loading…</p>
            </div>
          }
        >
          <VerificationCompleteContent />
        </Suspense>
      </div>
    </div>
  );
}
