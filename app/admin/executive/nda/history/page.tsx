"use client";

import ExecutiveHistoryPage from "@/components/ims/ExecutiveHistoryPage";
import { ALLOW_NDA_PORTAL } from "@/lib/ims-reports/executiveRoles";

export default function NdaReportHistoryPage() {
  return <ExecutiveHistoryPage role="nda" allowedRoles={ALLOW_NDA_PORTAL} />;
}
