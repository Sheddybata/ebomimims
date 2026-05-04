"use client";

import ExecutiveHistoryPage from "@/components/ims/ExecutiveHistoryPage";
import { ALLOW_AGO_PORTAL } from "@/lib/ims-reports/executiveRoles";

export default function AgoReportHistoryPage() {
  return <ExecutiveHistoryPage role="ago" allowedRoles={ALLOW_AGO_PORTAL} />;
}
