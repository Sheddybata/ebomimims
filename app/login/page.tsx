"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { Lock, Mail, Eye, EyeOff } from "lucide-react";
import { supabase } from "@/lib/supabase/client";
import { getExecutiveHomePath } from "@/lib/ims-reports/executiveRoles";

const WEB_ADMIN_ROLES = ["nda", "ago", "general_overseer", "super_admin"] as const;
type WebAdminRole = (typeof WEB_ADMIN_ROLES)[number];

function isWebAdminRole(role: string): role is WebAdminRole {
  return (WEB_ADMIN_ROLES as readonly string[]).includes(role);
}

function redirectPathForRole(role: WebAdminRole): string {
  if (role === "super_admin") return "/admin/dashboard";
  return getExecutiveHomePath(role);
}

export default function LoginPage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: "",
    password: "",
    rememberMe: false,
  });
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [resetMessage, setResetMessage] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setResetMessage("");
    setIsLoading(true);

    const email = formData.email.trim().toLowerCase();

    try {
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password: formData.password,
      });

      if (authError || !authData.user) {
        setError("Invalid email or password. Please try again.");
        return;
      }

      const userId = authData.user.id;

      const { data: profile, error: profileError } = await supabase
        .from("profiles")
        .select("role")
        .eq("id", userId)
        .maybeSingle();

      if (profileError || !profile?.role) {
        await supabase.auth.signOut();
        setError("Your account profile was not found. Please contact administration.");
        return;
      }

      const role = profile.role as string;

      if (!isWebAdminRole(role)) {
        await supabase.auth.signOut();
        setError(
          "This portal is for administration accounts only. Field leaders should use the EBOMIM mobile application.",
        );
        return;
      }

      if (formData.rememberMe) {
        localStorage.setItem("rememberMe", "true");
      }

      sessionStorage.setItem("authenticated", "true");
      sessionStorage.setItem("username", email);
      sessionStorage.setItem("role", role);

      const redirectTo = redirectPathForRole(role);
      sessionStorage.removeItem("redirectAfterLogin");
      router.push(redirectTo);
    } catch {
      setError("An error occurred. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleForgotPassword = async () => {
    setError("");
    setResetMessage("");
    const email = formData.email.trim().toLowerCase();
    if (!email) {
      setError("Enter your email address above, then tap Forgot password again.");
      return;
    }
    setIsLoading(true);
    try {
      const site =
        typeof window !== "undefined" ? `${window.location.origin}/login` : "https://ebomim.org/login";
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: site,
      });
      if (resetError) {
        setError("Could not send reset email. Confirm your email or contact IT support.");
        return;
      }
      setResetMessage("If this email is registered, a password reset link has been sent.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
    if (error) setError("");
    if (resetMessage) setResetMessage("");
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-pink-50 via-red-50 to-pink-100 p-4">
      {/* Background decorative waves */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-red-200/30 rounded-full blur-3xl"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-pink-200/30 rounded-full blur-3xl"></div>
      </div>

      <div className="relative w-full max-w-6xl bg-white rounded-2xl shadow-2xl overflow-hidden flex flex-col md:flex-row z-10">
        {/* Left Section - Login Form */}
        <div className="w-full md:w-2/3 p-8 md:p-12 lg:p-16 flex flex-col justify-center">
          <div className="max-w-md mx-auto w-full space-y-8">
            <div className="space-y-2">
              <h1 className="text-4xl md:text-5xl font-bold text-red-600">Log in</h1>
              <p className="text-gray-600 text-sm">
                Welcome back. Sign in with your official administration email and password.
              </p>
            </div>

            {/* Error Message */}
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm animate-shake">
                {error}
              </div>
            )}

            {resetMessage && (
              <div className="bg-emerald-50 border border-emerald-200 text-emerald-800 px-4 py-3 rounded-lg text-sm">
                {resetMessage}
              </div>
            )}

            {/* Login Form */}
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Email */}
              <div className="space-y-2">
                <label htmlFor="email" className="text-sm font-medium text-gray-700 sr-only">
                  Email
                </label>
                <div className="relative group">
                  <div className="absolute left-4 top-1/2 -translate-y-1/2 text-red-600 group-focus-within:text-red-700 transition-colors">
                    <Mail size={20} />
                  </div>
                  <input
                    id="email"
                    name="email"
                    type="email"
                    autoComplete="email"
                    placeholder="Email"
                    value={formData.email}
                    onChange={handleChange}
                    required
                    className="w-full pl-12 pr-4 py-3.5 border-2 border-gray-200 rounded-xl focus:border-red-500 focus:ring-2 focus:ring-red-100 outline-none transition-all text-gray-900 placeholder-gray-400"
                    disabled={isLoading}
                  />
                </div>
              </div>

              {/* Password Field */}
              <div className="space-y-2">
                <label htmlFor="password" className="text-sm font-medium text-gray-700 sr-only">
                  Password
                </label>
                <div className="relative group">
                  <div className="absolute left-4 top-1/2 -translate-y-1/2 text-red-600 group-focus-within:text-red-700 transition-colors">
                    <Lock size={20} />
                  </div>
                  <input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    autoComplete="current-password"
                    placeholder="Password"
                    value={formData.password}
                    onChange={handleChange}
                    required
                    className="w-full pl-12 pr-12 py-3.5 border-2 border-gray-200 rounded-xl focus:border-red-500 focus:ring-2 focus:ring-red-100 outline-none transition-all text-gray-900 placeholder-gray-400"
                    disabled={isLoading}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-red-600 hover:text-red-700 transition-colors focus:outline-none"
                    tabIndex={-1}
                  >
                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                  </button>
                </div>
              </div>

              {/* Remember Me & Forgot Password */}
              <div className="flex items-center justify-between text-sm">
                <label className="flex items-center space-x-2 cursor-pointer group">
                  <input
                    type="checkbox"
                    name="rememberMe"
                    checked={formData.rememberMe}
                    onChange={handleChange}
                    className="w-4 h-4 text-red-600 border-gray-300 rounded focus:ring-red-500 focus:ring-2 cursor-pointer"
                    disabled={isLoading}
                  />
                  <span className="text-gray-700 group-hover:text-gray-900 transition-colors">
                    Remember Me
                  </span>
                </label>
                <button
                  type="button"
                  onClick={handleForgotPassword}
                  className="text-red-600 hover:text-red-700 font-medium transition-colors focus:outline-none focus:underline"
                  disabled={isLoading}
                >
                  Forgot Password?
                </button>
              </div>

              {/* Login Button */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full bg-red-600 hover:bg-red-700 text-white font-semibold py-3.5 rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed transform hover:scale-[1.02] active:scale-[0.98]"
              >
                {isLoading ? (
                  <span className="flex items-center justify-center">
                    <svg
                      className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <circle
                        className="opacity-25"
                        cx="12"
                        cy="12"
                        r="10"
                        stroke="currentColor"
                        strokeWidth="4"
                      ></circle>
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                      ></path>
                    </svg>
                    Logging in...
                  </span>
                ) : (
                  "Log in"
                )}
              </button>
            </form>
          </div>
        </div>

        {/* Right section: orbital crests around central portrait (classic IMS login layout) */}
        <div className="w-full md:w-1/3 bg-gradient-to-br from-red-800 via-red-700 to-red-900 relative overflow-hidden min-h-[360px] md:min-h-[520px]">
          <div className="absolute inset-0 opacity-10" aria-hidden>
            <div
              className="absolute inset-0"
              style={{
                backgroundImage: `repeating-linear-gradient(
                45deg,
                transparent,
                transparent 10px,
                rgba(255,255,255,.05) 10px,
                rgba(255,255,255,.05) 20px
              )`,
              }}
            />
          </div>

          <div className="relative z-10 flex h-full min-h-[360px] md:min-h-[520px] items-center justify-center p-6 md:p-8">
            <div className="relative mx-auto h-[min(72vw,20rem)] w-[min(72vw,20rem)] md:h-[23rem] md:w-[23rem] max-w-[20rem]">
              {/* Centre — spiritual oversight portrait */}
              <div className="absolute left-1/2 top-1/2 z-20 -translate-x-1/2 -translate-y-1/2">
                <div className="relative h-24 w-24 md:h-28 md:w-28">
                  <div className="absolute inset-0 rounded-full bg-gradient-to-br from-green-400 via-orange-400 to-amber-600 p-0.5 animate-pulse-slow">
                    <div className="h-full w-full rounded-full bg-white p-0.5">
                      <div className="relative h-full w-full overflow-hidden rounded-full">
                        <Image
                          src="/arms/prophetisaelbubapicture.png"
                          alt="H.E Prophet Dr. Isa El-buba Sadiq"
                          fill
                          className="object-cover"
                          sizes="112px"
                          priority
                          unoptimized
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Orbital crests */}
              {/* Top — EBOMIM */}
              <div className="absolute left-1/2 top-0 z-30 flex -translate-x-1/2 flex-col items-center gap-1.5">
                <div className="flex h-[3rem] w-[3rem] md:h-14 md:w-14 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-white/30 bg-white/15 p-1.5 shadow-lg backdrop-blur-sm transition hover:scale-110 hover:bg-white/20">
                  <Image
                    src="/arms/ebomi.jpg"
                    alt="EBOMIM"
                    width={48}
                    height={48}
                    className="h-full w-full rounded-full object-cover"
                    unoptimized
                  />
                </div>
                <span className="text-center text-[10px] font-semibold text-white drop-shadow md:text-xs">
                  EBOMIM
                </span>
              </div>

              {/* Upper right — Tanjuriel */}
              <div className="absolute right-[-4%] top-[16%] z-30 flex flex-col items-center gap-1 md:right-[-2%]">
                <div className="flex h-[2.65rem] w-[2.65rem] md:h-12 md:w-12 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-white/30 bg-white/15 p-1 shadow-lg backdrop-blur-sm transition hover:scale-110 hover:bg-white/20 md:p-1.5">
                  <Image
                    src="/arms/tanjuriel.jpg"
                    alt=""
                    width={40}
                    height={40}
                    className="h-full w-full rounded-full object-cover"
                    unoptimized
                  />
                </div>
                <span className="text-center text-[9px] font-semibold text-white/95 drop-shadow md:text-[10px]">
                  Tanjuriel
                </span>
              </div>

              {/* Lower right — IBBN */}
              <div className="absolute bottom-[12%] right-[-6%] z-30 flex flex-col items-center gap-1 md:right-[-2%]">
                <div className="flex h-[2.65rem] w-[2.65rem] md:h-12 md:w-12 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-white/30 bg-white/15 p-1 shadow-lg backdrop-blur-sm transition hover:scale-110 hover:bg-white/20 md:p-1.5">
                  <Image
                    src="/arms/ibbn.png"
                    alt=""
                    width={40}
                    height={40}
                    className="h-full w-full rounded-full object-cover"
                    unoptimized
                  />
                </div>
                <span className="text-center text-[9px] font-semibold text-white/95 drop-shadow md:text-[10px]">
                  IBBN
                </span>
              </div>

              {/* Lower left — DISEF */}
              <div className="absolute bottom-[12%] left-[-6%] z-30 flex flex-col items-center gap-1 md:left-[-2%]">
                <div className="flex h-[2.65rem] w-[2.65rem] md:h-12 md:w-12 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-white/30 bg-white/15 p-1 shadow-lg backdrop-blur-sm transition hover:scale-110 hover:bg-white/20 md:p-1.5">
                  <Image
                    src="/arms/DISEF.jpg"
                    alt=""
                    width={40}
                    height={40}
                    className="h-full w-full rounded-full object-cover"
                    unoptimized
                  />
                </div>
                <span className="text-center text-[9px] font-semibold text-white/95 drop-shadow md:text-[10px]">
                  DISEF
                </span>
              </div>

              {/* Upper left — Education */}
              <div className="absolute left-[-4%] top-[16%] z-30 flex flex-col items-center gap-1 md:left-[-2%]">
                <div className="flex h-[2.65rem] w-[2.65rem] md:h-12 md:w-12 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-white/30 bg-white/15 p-1 shadow-lg backdrop-blur-sm transition hover:scale-110 hover:bg-white/20 md:p-1.5">
                  <Image
                    src="/arms/school.jpg"
                    alt=""
                    width={40}
                    height={40}
                    className="h-full w-full rounded-full object-cover"
                    unoptimized
                  />
                </div>
                <span className="text-center text-[9px] font-semibold text-white/95 drop-shadow md:text-[10px]">
                  Education
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        @keyframes shake {
          0%,
          100% {
            transform: translateX(0);
          }
          25% {
            transform: translateX(-5px);
          }
          75% {
            transform: translateX(5px);
          }
        }
        .animate-shake {
          animation: shake 0.5s ease-in-out;
        }
        @keyframes pulse-slow {
          0%,
          100% {
            opacity: 1;
          }
          50% {
            opacity: 0.8;
          }
        }
        .animate-pulse-slow {
          animation: pulse-slow 3s ease-in-out infinite;
        }
      `}</style>
    </div>
  );
}
