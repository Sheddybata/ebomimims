"use client";

import ExecutiveHistoryPage from "@/components/ims/ExecutiveHistoryPage";
import { ALLOW_GO_PORTAL } from "@/lib/ims-reports/executiveRoles";

export default function GoReportHistoryPage() {
  return <ExecutiveHistoryPage role="general_overseer" allowedRoles={ALLOW_GO_PORTAL} />;
}
