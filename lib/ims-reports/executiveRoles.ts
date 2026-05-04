/** IMS executive portal roles (sessionStorage `role`). */
export const EXECUTIVE_ROLES = ["nda", "ago", "general_overseer"] as const;
export type ExecutiveRole = (typeof EXECUTIVE_ROLES)[number];
export type AdminRole = "super_admin";

export function isExecutiveRole(role: string | null): role is ExecutiveRole {
  return role != null && (EXECUTIVE_ROLES as readonly string[]).includes(role);
}

export function getExecutiveHomePath(role: string): string {
  switch (role) {
    case "nda":
      return "/admin/executive/nda";
    case "ago":
      return "/admin/executive/ago";
    case "general_overseer":
      return "/admin/executive/general-overseer";
    default:
      return "/login";
  }
}

export const EXECUTIVE_ROLE_LABELS: Record<ExecutiveRole, string> = {
  nda: "National Director of Administration",
  ago: "Assistant General Overseer",
  general_overseer: "General Overseer",
};

/** Stable props for `ProtectedRoute` (avoid new array identity each render). */
export const ALLOW_NDA_PORTAL: string[] = ["nda"];
export const ALLOW_AGO_PORTAL: string[] = ["ago"];
export const ALLOW_GO_PORTAL: string[] = ["general_overseer"];
export const ALLOW_SUPER_ADMIN: string[] = ["super_admin"];
