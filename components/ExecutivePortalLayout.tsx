"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";

import { supabase } from "@/lib/supabase/client";
import { CalendarClock, History, LayoutDashboard, LogOut, Inbox, Shield } from "lucide-react";
import {
  EXECUTIVE_ROLE_LABELS,
  type ExecutiveRole,
} from "@/lib/ims-reports/executiveRoles";

function executivePortraitSrc(r: ExecutiveRole): string {
  switch (r) {
    case "nda":
      return "/admin/nda.jpg";
    case "ago":
      return "/admin/ago.jpg";
    case "general_overseer":
      return "/arms/prophetisaelbubapicture.png";
    default:
      return "/arms/prophetisaelbubapicture.png";
  }
}

interface ExecutivePortalLayoutProps {
  children: React.ReactNode;
  /** e.g. "Your report queue" */
  headline: string;
  role: ExecutiveRole;
}

export default function ExecutivePortalLayout({
  children,
  headline,
  role,
}: ExecutivePortalLayoutProps) {
  const pathname = usePathname();
  const router = useRouter();
  const username = typeof window !== "undefined" ? sessionStorage.getItem("username") : null;
  const label = EXECUTIVE_ROLE_LABELS[role];
  const homeHref =
    role === "nda"
      ? "/admin/executive/nda"
      : role === "ago"
        ? "/admin/executive/ago"
        : "/admin/executive/general-overseer";
  const historyHref = `${homeHref}/history`;

  return (
    <div className="flex min-h-screen bg-gray-50">
      <aside className="w-60 shrink-0 bg-white border-r border-gray-200 flex flex-col">
        <div className="p-4 border-b border-gray-100">
          <div className="flex items-center gap-2 mb-1">
            <div className="w-9 h-9 rounded-full bg-primary-600 text-white flex items-center justify-center text-sm font-bold">
              E
            </div>
            <span className="font-semibold text-gray-900 text-sm">EBOMIM IMS</span>
          </div>
          <p className="text-[11px] text-gray-500 leading-tight">Executive portal</p>
        </div>
        <nav className="p-2 flex-1">
          <Link
            href={homeHref}
            className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
              pathname === homeHref
                ? "bg-primary-100 text-primary-800"
                : "text-gray-700 hover:bg-gray-100"
            }`}
          >
            <Inbox size={18} />
            My queue
          </Link>
          <Link
            href={historyHref}
            className={`mt-1 flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
              pathname === historyHref
                ? "bg-primary-100 text-primary-800"
                : "text-gray-700 hover:bg-gray-100"
            }`}
          >
            <History size={18} />
            Report history
          </Link>
          {role === "general_overseer" ? (
            <>
              <Link
                href="/admin/dashboard"
                className={`mt-1 flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                  pathname === "/admin/dashboard"
                    ? "bg-primary-100 text-primary-800"
                    : "text-gray-700 hover:bg-gray-100"
                }`}
              >
                <LayoutDashboard size={18} />
                Command Center
              </Link>
              <Link
                href="/admin/compliance-dashboard"
                className={`mt-1 flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                  pathname === "/admin/compliance-dashboard"
                    ? "bg-primary-100 text-primary-800"
                    : "text-gray-700 hover:bg-gray-100"
                }`}
              >
                <CalendarClock size={18} />
                Weekly Compliance
              </Link>
            </>
          ) : null}
        </nav>
        <div className="p-3 border-t border-gray-100 space-y-2">
          <button
            type="button"
            onClick={async () => {
              await supabase.auth.signOut();
              sessionStorage.removeItem("authenticated");
              sessionStorage.removeItem("username");
              sessionStorage.removeItem("role");
              sessionStorage.removeItem("rememberMe");
              router.push("/login");
            }}
            className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-gray-700 hover:bg-gray-100"
          >
            <LogOut size={18} />
            Sign out
          </button>
        </div>
      </aside>
      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-14 bg-white border-b border-gray-200 flex items-center justify-between px-4 md:px-6">
          <div className="flex items-center gap-3 min-w-0">
            <Shield className="text-primary-600 shrink-0" size={22} />
            <div className="min-w-0">
              <p className="text-xs font-semibold text-primary-700 uppercase tracking-wide truncate">
                {label}
              </p>
              <h1 className="text-sm md:text-base font-bold text-gray-900 truncate">{headline}</h1>
            </div>
          </div>
          <div className="flex items-center gap-2 shrink-0">
            <div className="hidden sm:flex flex-col items-end text-right mr-2">
              <span className="text-xs font-medium text-gray-800">{username || "User"}</span>
              <span className="text-[10px] text-gray-500">{label}</span>
            </div>
            <div className="w-9 h-9 rounded-full overflow-hidden ring-2 ring-primary-100">
              <Image
                src={executivePortraitSrc(role)}
                alt={label}
                width={36}
                height={36}
                className="w-full h-full object-cover"
                unoptimized
              />
            </div>
          </div>
        </header>
        <main className="flex-1 overflow-y-auto p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
