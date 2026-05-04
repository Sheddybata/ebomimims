"use client";

import { useCallback, useEffect, useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import {
  getSupabaseWeeklyComplianceRows,
  type SupabaseWeeklyComplianceRow,
} from "@/lib/ims-reports/supabasePipelineStore";
import { CalendarClock, CheckCircle2, AlertTriangle, RefreshCw } from "lucide-react";

export default function ComplianceDashboardPage() {
  const [rows, setRows] = useState<SupabaseWeeklyComplianceRow[]>([]);
  const [loadError, setLoadError] = useState("");

  const refresh = useCallback(async () => {
    setLoadError("");
    try {
      setRows(await getSupabaseWeeklyComplianceRows());
    } catch (error) {
      setRows([]);
      setLoadError(error instanceof Error ? error.message : "Unable to load weekly compliance.");
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const missing = rows.filter((r) => !r.submitted);
  const ok = rows.filter((r) => r.submitted);

  return (
    <ProtectedRoute requireAdmin allowedRoles={["super_admin", "general_overseer"]}>
      <DashboardLayout>
        <div className="p-6 md:p-8 space-y-8 max-w-4xl mx-auto">
          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
            <div>
              <div className="flex items-center gap-2 text-primary-600 mb-2">
                <CalendarClock size={22} />
                <span className="text-sm font-semibold uppercase tracking-wide">NDA Compliance</span>
              </div>
              <h1 className="text-2xl font-bold text-gray-900">Weekly submission compliance</h1>
              <p className="text-gray-600 mt-1 text-sm leading-relaxed max-w-2xl">
                Track which directorates have filed their weekly line report bundle (unit head → manager
                → director) by the deadline. This aligns with the mobile Reporting and metrics framework.
              </p>
              <p className="text-xs text-amber-800 bg-amber-50 border border-amber-200 rounded-lg px-3 py-2 mt-3 inline-block">
                Live Supabase view: a directorate is marked submitted when it has at least one report created this week.
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => void refresh()}
                className="px-3 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 inline-flex items-center gap-2"
              >
                <RefreshCw size={16} />
                Refresh
              </button>
            </div>
          </div>

          {loadError ? (
            <div className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-900">
              Unable to load live Supabase compliance data: {loadError}
            </div>
          ) : null}

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="rounded-xl border border-red-200 bg-red-50/60 p-4">
              <div className="flex items-center gap-2 text-red-800 font-semibold text-sm">
                <AlertTriangle size={18} />
                Not submitted ({missing.length})
              </div>
              <p className="text-xs text-red-900/80 mt-2">
                Follow up with these directorates before executive pipeline review.
              </p>
            </div>
            <div className="rounded-xl border border-emerald-200 bg-emerald-50/60 p-4">
              <div className="flex items-center gap-2 text-emerald-800 font-semibold text-sm">
                <CheckCircle2 size={18} />
                Submitted ({ok.length})
              </div>
              <p className="text-xs text-emerald-900/80 mt-2">
                Director (or delegated) has advanced the weekly bundle toward NDA / web pipeline.
              </p>
            </div>
          </div>

          <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">
                <tr>
                  <th className="px-4 py-3">Directorate</th>
                  <th className="px-4 py-3">Status</th>
                  <th className="px-4 py-3 hidden md:table-cell">Last filed</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {rows.map((r) => (
                  <tr key={r.id} className={r.submitted ? "bg-white" : "bg-red-50/30"}>
                    <td className="px-4 py-3 font-medium text-gray-900">{r.name}</td>
                    <td className="px-4 py-3">
                      {r.submitted ? (
                        <span className="inline-flex items-center gap-1 text-emerald-700 font-medium">
                          <CheckCircle2 size={16} />
                          Submitted
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 text-red-700 font-medium">
                          <AlertTriangle size={16} />
                          Missing
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-600 hidden md:table-cell">
                      {r.submittedAt
                        ? new Date(r.submittedAt).toLocaleString()
                        : r.submitted
                          ? "On file"
                          : "—"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}
