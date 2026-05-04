"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import {
  getExecutiveHomePath,
  isExecutiveRole,
} from "@/lib/ims-reports/executiveRoles";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    const isAuthenticated = sessionStorage.getItem("authenticated") === "true";
    const role = sessionStorage.getItem("role");

    if (!isAuthenticated) {
      router.push("/login");
      return;
    }

    if (isExecutiveRole(role)) {
      router.push(getExecutiveHomePath(role));
      return;
    }

    router.push("/admin/dashboard");
  }, [router]);

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-red-600"></div>
    </div>
  );
}
