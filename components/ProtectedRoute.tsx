"use client";

import { useEffect, useState } from "react";
import { useRouter, usePathname } from "next/navigation";
import {
  getExecutiveHomePath,
  isExecutiveRole,
} from "@/lib/ims-reports/executiveRoles";

interface ProtectedRouteProps {
  children: React.ReactNode;
  requireAdmin?: boolean;
  allowedRoles?: string[];
}

export default function ProtectedRoute({ children, requireAdmin = false, allowedRoles }: ProtectedRouteProps) {
  const router = useRouter();
  const pathname = usePathname();
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);
  const [isAuthorized, setIsAuthorized] = useState<boolean | null>(null);
  const allowedRolesKey = allowedRoles?.join("\x01") ?? "";

  useEffect(() => {
    // Check authentication status
    const checkAuth = () => {
      const auth = sessionStorage.getItem("authenticated") === "true";
      const role = sessionStorage.getItem("role");
      const effectiveRole = role === "admin" ? "super_admin" : role;
      if (role === "admin") {
        sessionStorage.setItem("role", "super_admin");
      }
      
      setIsAuthenticated(auth);

      if (!auth) {
        // Store intended destination for redirect after login
        sessionStorage.setItem("redirectAfterLogin", pathname);
        router.push("/login");
        return;
      }

      // Broad admin areas are not exposed to executive logins.
      if (requireAdmin) {
        if (
          effectiveRole === "super_admin" ||
          (allowedRoles?.length && effectiveRole && allowedRoles.includes(effectiveRole))
        ) {
          setIsAuthorized(true);
          return;
        }
        setIsAuthorized(false);
        if (isExecutiveRole(effectiveRole)) {
          router.push(getExecutiveHomePath(effectiveRole));
          return;
        }
        router.push("/login");
        return;
      }

      // Role-gated pages (executive portals: nda, ago, general_overseer, etc.)
      if (allowedRoles?.length) {
        if (!effectiveRole || !allowedRoles.includes(effectiveRole)) {
          setIsAuthorized(false);
          if (isExecutiveRole(effectiveRole)) {
            router.push(getExecutiveHomePath(effectiveRole));
            return;
          }
          if (effectiveRole === "super_admin") {
            router.push("/admin/dashboard");
            return;
          }
          router.push("/login");
          return;
        }
      }

      setIsAuthorized(true);
    };

    checkAuth();
  }, [router, pathname, requireAdmin, allowedRolesKey]);

  // Show loading state while checking authentication
  if (isAuthenticated === null || isAuthorized === null) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-red-600"></div>
      </div>
    );
  }

  // Only render children if authenticated and authorized
  if (!isAuthenticated || !isAuthorized) {
    return null;
  }

  return <>{children}</>;
}
