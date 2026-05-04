"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import {
  filterImsPipelineByStage,
  imsStageLabels,
  type ImsPipelineReport,
} from "@/lib/ims-reports/pipelineStore";
import {
  getSupabasePipelineReports,
  getSupabaseWeeklyComplianceRows,
  type SupabaseWeeklyComplianceRow,
} from "@/lib/ims-reports/supabasePipelineStore";
import {
  AlertTriangle,
  ArrowRight,
  CalendarClock,
  CheckCircle2,
  FileText,
  RefreshCw,
} from "lucide-react";

export default function AdminDashboard() {
  const [pipelineReports, setPipelineReports] = useState<ImsPipelineReport[]>([]);
  const [complianceRows, setComplianceRows] = useState<SupabaseWeeklyComplianceRow[]>([]);
  const [loadError, setLoadError] = useState("");

  const refresh = useCallback(async () => {
    setLoadError("");
    try {
      const [remoteReports, remoteComplianceRows] = await Promise.all([
        getSupabasePipelineReports(),
        getSupabaseWeeklyComplianceRows(),
      ]);
      setPipelineReports(remoteReports);
      setComplianceRows(remoteComplianceRows);
    } catch (error) {
      setPipelineReports([]);
      setComplianceRows([]);
      setLoadError(error instanceof Error ? error.message : "Unable to load Supabase reports.");
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const counts = useMemo(
    () => ({
      nda: filterImsPipelineByStage(pipelineReports, "awaiting_administration").length,
      ago: filterImsPipelineByStage(pipelineReports, "awaiting_ago").length,
      go: filterImsPipelineByStage(pipelineReports, "awaiting_general_overseer").length,
      returned: filterImsPipelineByStage(pipelineReports, "returned_for_revision").length,
      approved: filterImsPipelineByStage(pipelineReports, "approved").length,
    }),
    [pipelineReports],
  );

  const missingCompliance = complianceRows.filter((r) => !r.submitted).length;

  return (
    <ProtectedRoute requireAdmin allowedRoles={["super_admin", "general_overseer"]}>
      <DashboardLayout>
        <div className="mx-auto max-w-7xl space-y-8 p-4 md:p-6">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <div className="mb-2 flex items-center gap-2 text-primary-600">
                <FileText size={22} />
                <span className="text-sm font-semibold uppercase tracking-wide">
                  Report Command Center
                </span>
              </div>
              <h1 className="text-2xl font-bold text-gray-900">Report Command Center</h1>
              <p className="mt-1 max-w-2xl text-sm leading-relaxed text-gray-600">
                Oversight for the report workflow from director approval through NDA, AGO, GO,
                and final archive.
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
              Unable to load live Supabase data: {loadError}
            </div>
          ) : null}

          <section className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-5">
            <StatusCard label={imsStageLabels.awaiting_administration} value={counts.nda} tone="red" />
            <StatusCard label={imsStageLabels.awaiting_ago} value={counts.ago} tone="amber" />
            <StatusCard label={imsStageLabels.awaiting_general_overseer} value={counts.go} tone="violet" />
            <StatusCard label={imsStageLabels.returned_for_revision} value={counts.returned} tone="orange" />
            <StatusCard label={imsStageLabels.approved} value={counts.approved} tone="emerald" />
          </section>

          <section className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <WorkflowPanel
              title="Weekly Compliance"
              icon={<CalendarClock size={20} />}
              href="/admin/compliance-dashboard"
              rows={[
                ["Directorates tracked", complianceRows.length],
                ["Missing submissions", missingCompliance],
                ["Submitted", complianceRows.length - missingCompliance],
              ]}
            />
            <WorkflowPanel
              title="Executive Workflow"
              icon={<CheckCircle2 size={20} />}
              href="/admin/executive/general-overseer"
              rows={[
                ["Waiting for NDA", counts.nda],
                ["Waiting for AGO", counts.ago],
                ["Waiting for GO", counts.go],
              ]}
            />
          </section>

          <section className="grid grid-cols-1 gap-6 lg:grid-cols-2">
            <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
              <div className="mb-4 flex items-center justify-between gap-3">
                <div>
                  <h2 className="font-bold text-gray-900">Priority Attention</h2>
                  <p className="text-xs text-gray-600">
                    Items that may need follow-up before the executive chain can complete.
                  </p>
                </div>
                <AlertTriangle className="text-amber-500" size={22} />
              </div>
              <div className="space-y-3">
                <AttentionRow
                  label="Reports returned by executives"
                  count={counts.returned}
                  href="/admin/dashboard"
                />
                <AttentionRow
                  label="Directorates missing weekly bundle"
                  count={missingCompliance}
                  href="/admin/compliance-dashboard"
                />
              </div>
            </div>

            <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
              <div className="mb-4 flex items-center justify-between gap-3">
                <div>
                  <h2 className="font-bold text-gray-900">Approval Snapshot</h2>
                  <p className="text-xs text-gray-600">
                    Live counts from submitted Supabase reports only. Demo/local sample data is not included.
                  </p>
                </div>
                <CheckCircle2 className="text-emerald-500" size={22} />
              </div>
              <div className="space-y-3">
                <AttentionRow label="Approved reports" count={counts.approved} href="/admin/dashboard" />
                <AttentionRow label="Reports in GO queue" count={counts.go} href="/admin/executive/general-overseer" />
                <AttentionRow label="Reports still before GO" count={counts.nda + counts.ago} href="/admin/dashboard" />
              </div>
            </div>
          </section>

          <section className="grid grid-cols-1 gap-4 md:grid-cols-2">
            <QuickLink
              href="/admin/executive/general-overseer"
              title="Open My Queue"
              description="Review reports currently waiting for GO final approval."
            />
            <QuickLink
              href="/admin/compliance-dashboard"
              title="Open Compliance"
              description="Check directorate weekly submission status."
            />
          </section>
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}

function StatusCard({
  label,
  value,
  tone,
}: {
  label: string;
  value: number;
  tone: "red" | "amber" | "violet" | "orange" | "emerald";
}) {
  const tones = {
    red: "bg-red-50 text-red-700 border-red-100",
    amber: "bg-amber-50 text-amber-700 border-amber-100",
    violet: "bg-violet-50 text-violet-700 border-violet-100",
    orange: "bg-orange-50 text-orange-700 border-orange-100",
    emerald: "bg-emerald-50 text-emerald-700 border-emerald-100",
  };
  return (
    <div className={`rounded-xl border p-4 shadow-sm ${tones[tone]}`}>
      <p className="text-xs font-semibold uppercase tracking-wide opacity-80">{label}</p>
      <p className="mt-3 text-3xl font-bold tabular-nums">{value}</p>
    </div>
  );
}

function WorkflowPanel({
  title,
  icon,
  href,
  rows,
}: {
  title: string;
  icon: React.ReactNode;
  href: string;
  rows: Array<[string, number]>;
}) {
  return (
    <Link
      href={href}
      className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm transition hover:border-primary-200 hover:shadow-md"
    >
      <div className="mb-4 flex items-center gap-2 text-primary-700">
        {icon}
        <h2 className="font-bold text-gray-900">{title}</h2>
      </div>
      <div className="space-y-2">
        {rows.map(([label, count]) => (
          <div key={label} className="flex items-center justify-between text-sm">
            <span className="text-gray-600">{label}</span>
            <span className="font-bold text-gray-900 tabular-nums">{count}</span>
          </div>
        ))}
      </div>
      <span className="mt-4 inline-flex items-center gap-1 text-xs font-semibold text-primary-700">
        Open <ArrowRight size={14} />
      </span>
    </Link>
  );
}

function AttentionRow({ label, count, href }: { label: string; count: number; href: string }) {
  return (
    <Link href={href} className="flex items-center justify-between rounded-lg bg-gray-50 px-3 py-2 hover:bg-gray-100">
      <span className="text-sm text-gray-700">{label}</span>
      <span className={`text-sm font-bold tabular-nums ${count > 0 ? "text-amber-700" : "text-emerald-700"}`}>
        {count}
      </span>
    </Link>
  );
}

function QuickLink({
  href,
  title,
  description,
}: {
  href: string;
  title: string;
  description: string;
}) {
  return (
    <Link
      href={href}
      className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm transition hover:border-primary-200 hover:shadow-md"
    >
      <p className="font-bold text-gray-900">{title}</p>
      <p className="mt-1 text-sm leading-relaxed text-gray-600">{description}</p>
    </Link>
  );
}
