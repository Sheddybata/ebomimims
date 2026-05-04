"use client";

import { useCallback, useEffect, useState } from "react";
import ProtectedRoute from "@/components/ProtectedRoute";
import ExecutivePortalLayout from "@/components/ExecutivePortalLayout";
import ExecutiveReportHistory from "@/components/ims/ExecutiveReportHistory";
import {
  EXECUTIVE_ROLE_LABELS,
  type ExecutiveRole,
} from "@/lib/ims-reports/executiveRoles";
import type { ImsPipelineReport } from "@/lib/ims-reports/pipelineStore";
import {
  getSupabaseExecutiveHistory,
  type ExecutiveHistoryRole,
} from "@/lib/ims-reports/supabasePipelineStore";
import { RefreshCw } from "lucide-react";

interface ExecutiveHistoryPageProps {
  role: ExecutiveHistoryRole;
  allowedRoles: string[];
}

export default function ExecutiveHistoryPage({
  role,
  allowedRoles,
}: ExecutiveHistoryPageProps) {
  const [reports, setReports] = useState<ImsPipelineReport[]>([]);
  const [loadError, setLoadError] = useState("");

  const refresh = useCallback(async () => {
    setLoadError("");
    try {
      setReports(await getSupabaseExecutiveHistory(role));
    } catch (error) {
      setReports([]);
      setLoadError(error instanceof Error ? error.message : "Unable to load report history.");
    }
  }, [role]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const label = EXECUTIVE_ROLE_LABELS[role as ExecutiveRole];

  return (
    <ProtectedRoute allowedRoles={allowedRoles}>
      <ExecutivePortalLayout role={role as ExecutiveRole} headline="Report history">
        <div className="mx-auto max-w-6xl space-y-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <p className="text-sm font-semibold uppercase tracking-wide text-primary-700">
                {label}
              </p>
              <h1 className="mt-1 text-2xl font-bold text-gray-900">Report history</h1>
              <p className="mt-1 max-w-3xl text-sm leading-relaxed text-gray-600">
                A full read-only view of reports that have passed through this executive desk.
              </p>
            </div>
            <button
              type="button"
              onClick={() => void refresh()}
              className="inline-flex items-center justify-center gap-2 rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              <RefreshCw size={16} />
              Refresh
            </button>
          </div>

          {loadError ? (
            <div className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-900">
              Unable to load report history from Supabase: {loadError}
            </div>
          ) : null}

          <ExecutiveReportHistory role={role} reports={reports} />
        </div>
      </ExecutivePortalLayout>
    </ProtectedRoute>
  );
}
