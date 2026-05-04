"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";

import { supabase } from "@/lib/supabase/client";
import {
  CalendarClock,
  FileText,
  Inbox,
  LayoutDashboard,
  LogOut,
  Menu,
  X,
} from "lucide-react";

interface NavItem {
  name: string;
  icon: React.ReactNode;
  href: string;
}

const navItems: NavItem[] = [
  { name: "Command Center", icon: <LayoutDashboard size={18} />, href: "/admin/dashboard" },
  { name: "Executive Pipeline", icon: <FileText size={18} />, href: "/admin/ims-pipeline" },
  { name: "Weekly Compliance", icon: <CalendarClock size={18} />, href: "/admin/compliance-dashboard" },
];

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const pathname = usePathname();
  const router = useRouter();
  const username = typeof window !== "undefined" ? sessionStorage.getItem("username") : null;
  const role = typeof window !== "undefined" ? sessionStorage.getItem("role") : null;
  const isGo = role === "general_overseer";
  const visibleNavItems = isGo
    ? [
        {
          name: "My queue",
          icon: <Inbox size={18} />,
          href: "/admin/executive/general-overseer",
        },
        ...navItems.filter((item) => item.href !== "/admin/ims-pipeline"),
      ]
    : navItems;

  const isActive = (href: string) => pathname === href || pathname.startsWith(href + "/");

  const signOut = async () => {
    await supabase.auth.signOut();
    sessionStorage.removeItem("authenticated");
    sessionStorage.removeItem("username");
    sessionStorage.removeItem("role");
    sessionStorage.removeItem("rememberMe");
    router.push("/login");
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <aside
        className={`${
          sidebarOpen ? "w-64" : "w-20"
        } bg-white shadow-lg transition-all duration-300 overflow-y-auto`}
      >
        <div className="p-3 flex items-center justify-between border-b border-gray-100">
          {sidebarOpen ? (
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-primary-600 rounded-full flex items-center justify-center text-white font-bold text-sm">
                E
              </div>
              <div>
                <span className="block font-semibold text-sm text-gray-800">EBOMIM IMS</span>
                <span className="block text-[10px] text-gray-500">
                  {isGo ? "GO Oversight" : "Super Admin"}
                </span>
              </div>
            </div>
          ) : null}
          <button
            type="button"
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-1.5 hover:bg-gray-100 rounded-lg"
            aria-label={sidebarOpen ? "Collapse sidebar" : "Expand sidebar"}
          >
            {sidebarOpen ? <X size={18} /> : <Menu size={18} />}
          </button>
        </div>

        <nav className="mt-3 px-2 space-y-1">
          {visibleNavItems.map((item) => (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center space-x-2 px-3 py-2 rounded-lg transition-colors text-sm ${
                isActive(item.href)
                  ? "bg-primary-100 text-primary-700"
                  : "text-gray-700 hover:bg-gray-100"
              }`}
              title={sidebarOpen ? undefined : item.name}
            >
              <div className="w-4 h-4 shrink-0">{item.icon}</div>
              {sidebarOpen ? <span className="text-sm">{item.name}</span> : null}
            </Link>
          ))}
        </nav>
      </aside>

      <div className="flex-1 flex flex-col overflow-hidden">
        <header className="bg-white shadow-sm h-14 flex items-center justify-between px-4">
          <div>
            <p className="text-xs font-semibold uppercase tracking-wide text-primary-700">
              {isGo ? "General Overseer Oversight" : "Super Admin Console"}
            </p>
            <p className="text-[11px] text-gray-500">
              {isGo
                ? "Read-only command view for compliance and workflow health"
                : "System oversight for the report workflow"}
            </p>
          </div>
          <div className="flex items-center gap-3">
            <div className="hidden sm:flex flex-col items-end text-right">
              <span className="text-xs font-medium text-gray-800">{username || "admin"}</span>
              <span className="text-[10px] text-gray-500">
                {isGo ? "general_overseer" : "super_admin"}
              </span>
            </div>
            <div className="w-8 h-8 rounded-full overflow-hidden ring-2 ring-primary-200">
              <Image
                src="/arms/prophetisaelbubapicture.png"
                alt=""
                width={32}
                height={32}
                className="w-full h-full object-cover"
                unoptimized
              />
            </div>
            <button
              type="button"
              onClick={signOut}
              className="inline-flex items-center gap-2 rounded-lg border border-gray-200 px-3 py-1.5 text-xs font-semibold text-gray-700 hover:bg-gray-50"
            >
              <LogOut size={15} />
              Sign out
            </button>
          </div>
        </header>

        <main className="flex-1 overflow-y-auto p-4">{children}</main>
      </div>
    </div>
  );
}
