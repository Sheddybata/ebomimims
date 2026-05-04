"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import {
  clearExecutiveReportInboxNotices,
  getExecutiveReportInboxNotices,
  type ExecutiveReportInboxNotice,
} from "@/lib/ims-reports/executiveInboxStore";
import {
  getLineReports,
  resetLineReportsToDemo,
  lineStageLabel,
  type LineReport,
  type LineReportStage,
} from "@/lib/ims-reports/lineReportStore";
import { GitBranch, RefreshCw, RotateCcw, X } from "lucide-react";

function filterByStage(list: LineReport[], stage: LineReportStage) {
  return list.filter((r) => r.stage === stage);
}

export default function LineReviewPage() {
  const [reports, setReports] = useState<LineReport[]>([]);
  const [inboxNotices, setInboxNotices] = useState<ExecutiveReportInboxNotice[]>([]);
  const [modalReport, setModalReport] = useState<LineReport | null>(null);

  const refresh = useCallback(() => {
    setReports(getLineReports());
    setInboxNotices(getExecutiveReportInboxNotices());
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const awaitingMgr = useMemo(
    () => filterByStage(reports, "awaiting_manager"),
    [reports],
  );
  const awaitingDir = useMemo(
    () => filterByStage(reports, "awaiting_director"),
    [reports],
  );
  const revisions = useMemo(
    () => filterByStage(reports, "revision_requested"),
    [reports],
  );

  const openReview = (r: LineReport) => {
    setModalReport(r);
  };

  const closeModal = () => {
    setModalReport(null);
  };

  return (
    <ProtectedRoute requireAdmin>
      <DashboardLayout>
        <div className="p-6 md:p-8 space-y-8 max-w-6xl mx-auto">
          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
            <div>
              <div className="flex items-center gap-2 text-primary-600 mb-2">
                <GitBranch size={22} />
                <span className="text-sm font-semibold uppercase tracking-wide">
                  Pre-Executive Review
                </span>
              </div>
              <h1 className="text-2xl font-bold text-gray-900">Manager & director review</h1>
              <p className="text-gray-600 mt-1 max-w-2xl text-sm leading-relaxed">
                Read-only Super Admin oversight for the path before executive review: unit head →
                manager → director → NDA. Managers and directors should perform approvals inside the
                app workflow, not from this console.
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => refresh()}
                className="px-3 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 inline-flex items-center gap-2"
              >
                <RefreshCw size={16} />
                Refresh
              </button>
              <button
                type="button"
                onClick={() => {
                  if (
                    window.confirm(
                      "Reset pre-executive review sample data? This does not reset the executive IMS pipeline.",
                    )
                  ) {
                    resetLineReportsToDemo();
                    refresh();
                  }
                }}
                className="px-3 py-2 bg-amber-50 border border-amber-200 rounded-lg text-sm font-medium text-amber-900 hover:bg-amber-100 inline-flex items-center gap-2"
              >
                <RotateCcw size={16} />
                Reset sample data
              </button>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Section
              title="Manager queue"
              hint="Read-only view of reports waiting for manager action in the app workflow."
              items={awaitingMgr}
              onOpen={openReview}
              actionLabel="Preview"
            />
            <Section
              title="Director queue"
              hint="Read-only view of reports waiting for director action before the NDA queue."
              items={awaitingDir}
              onOpen={openReview}
              actionLabel="Preview"
            />
          </div>

          <section className="bg-white rounded-xl border border-gray-200 p-5 shadow-sm">
            <h2 className="font-bold text-gray-900 mb-1">Returned for revision</h2>
            <p className="text-xs text-gray-600 mb-4">
              The full note is what the author should see in their app inbox after a manager or director
              returns a report.
            </p>
            {revisions.length === 0 ? (
              <p className="text-sm text-gray-500">No items in revision.</p>
            ) : (
              <ul className="space-y-4">
                {revisions.map((r) => (
                  <li
                    key={r.id}
                    className="border border-gray-100 rounded-lg p-4 bg-gray-50/60"
                  >
                    <p className="font-semibold text-gray-900">{r.title}</p>
                    <p className="text-xs text-gray-500 mt-1">
                      {lineStageLabel(r.stage)} · {r.authorRole} · {r.authorName}
                    </p>
                    {r.sendBackNote && (
                      <div className="mt-3 text-sm text-gray-800 whitespace-pre-wrap border-l-4 border-amber-400 pl-3">
                        {r.sendBackNote}
                      </div>
                    )}
                    {(r.sendBackByName || r.sendBackAt) && (
                      <p className="text-[11px] text-gray-500 mt-2">
                        {r.sendBackByName && r.sendBackByRole
                          ? `From ${r.sendBackByName} (${r.sendBackByRole})`
                          : r.sendBackByName}
                        {r.sendBackAt && ` · ${new Date(r.sendBackAt).toLocaleString()}`}
                      </p>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </section>

          <section className="bg-white rounded-xl border border-gray-200 p-5 shadow-sm">
            <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
              <div>
                <h2 className="font-bold text-gray-900 mb-1">Unit / manager / director inbox</h2>
                <p className="text-xs text-gray-600 mb-4">
                  Outcome notices generated by the executive pipeline. These represent what the app inbox should
                  receive after GO approval or an executive return-for-revision.
                </p>
              </div>
              {inboxNotices.length > 0 ? (
                <button
                  type="button"
                  onClick={() => {
                    clearExecutiveReportInboxNotices();
                    refresh();
                  }}
                  className="shrink-0 rounded-lg border border-gray-300 px-3 py-1.5 text-xs font-semibold text-gray-700 hover:bg-gray-50"
                >
                  Clear inbox
                </button>
              ) : null}
            </div>
            {inboxNotices.length === 0 ? (
              <p className="text-sm text-gray-500">No executive outcome messages yet.</p>
            ) : (
              <ul className="space-y-3">
                {inboxNotices.map((notice) => (
                  <li
                    key={notice.id}
                    className={`rounded-lg border p-4 ${
                      notice.status === "approved"
                        ? "border-emerald-100 bg-emerald-50/70"
                        : "border-amber-100 bg-amber-50/70"
                    }`}
                  >
                    <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
                      <div className="min-w-0">
                        <p className="text-sm font-semibold text-gray-900">{notice.reportTitle}</p>
                        <p className="mt-1 text-xs text-gray-600">
                          To {inboxRecipientLabel(notice.recipientRole)} · {notice.recipientName}
                        </p>
                      </div>
                      <span
                        className={`shrink-0 rounded-full px-2.5 py-1 text-[11px] font-bold ${
                          notice.status === "approved"
                            ? "bg-emerald-600 text-white"
                            : "bg-amber-500 text-amber-950"
                        }`}
                      >
                        {notice.status === "approved" ? "Approved" : "Returned"}
                      </span>
                    </div>
                    <p className="mt-2 text-xs text-gray-700">
                      {notice.status === "approved"
                        ? `Final approval completed by ${notice.actorLabel}.`
                        : `${notice.actorLabel} returned this report for revision.`}
                    </p>
                    {notice.note ? (
                      <div className="mt-3 whitespace-pre-wrap rounded-md border border-amber-200 bg-white/70 p-3 text-sm leading-relaxed text-gray-800">
                        {notice.note}
                      </div>
                    ) : null}
                    <p className="mt-2 text-[11px] text-gray-500">
                      {new Date(notice.createdAt).toLocaleString()}
                    </p>
                  </li>
                ))}
              </ul>
            )}
          </section>
        </div>

        {modalReport && (
          <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center sm:p-4 bg-black/40">
            <div
              className="bg-white w-full sm:max-w-lg sm:rounded-xl shadow-xl max-h-[min(90vh,640px)] flex flex-col"
              role="dialog"
              aria-modal="true"
              aria-labelledby="line-review-title"
            >
              <div className="flex items-start justify-between gap-2 p-4 border-b border-gray-100">
                <h2 id="line-review-title" className="font-bold text-gray-900 pr-2">
                  {modalReport.title}
                </h2>
                <button
                  type="button"
                  onClick={closeModal}
                  className="p-1 rounded-lg hover:bg-gray-100 text-gray-600"
                  aria-label="Close"
                >
                  <X size={22} />
                </button>
              </div>
              <div className="p-4 overflow-y-auto flex-1 space-y-3 text-sm">
                <p className="text-gray-800 whitespace-pre-wrap">{modalReport.summary}</p>
                <p className="text-xs text-gray-500">
                  {modalReport.reportType}
                  {modalReport.unitName ? ` · ${modalReport.unitName}` : ""} · Author:{" "}
                  {modalReport.authorName} ({modalReport.authorRole})
                </p>

                <p className="rounded-lg border border-blue-100 bg-blue-50 px-3 py-2 text-xs leading-relaxed text-blue-900">
                  This is a read-only Super Admin preview. Approval and return actions belong to the
                  manager/director app workflow.
                </p>
              </div>
              <div className="p-4 border-t border-gray-100 flex justify-end">
                <button
                  type="button"
                  onClick={closeModal}
                  className="px-4 py-2 rounded-lg border border-gray-300 text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        )}
      </DashboardLayout>
    </ProtectedRoute>
  );
}

function Section({
  title,
  hint,
  items,
  onOpen,
  actionLabel,
}: {
  title: string;
  hint: string;
  items: LineReport[];
  onOpen: (r: LineReport) => void;
  actionLabel: string;
}) {
  return (
    <section className="bg-white rounded-xl border border-gray-200 p-5 shadow-sm">
      <h2 className="font-bold text-gray-900">{title}</h2>
      <p className="text-xs text-gray-600 mb-3">{hint}</p>
      {items.length === 0 ? (
        <p className="text-sm text-gray-500">No items.</p>
      ) : (
        <ul className="space-y-2">
          {items.map((r) => (
            <li
              key={r.id}
              className="flex flex-col sm:flex-row sm:items-center gap-2 py-2 border-b border-gray-100 last:border-0"
            >
              <div className="flex-1 min-w-0">
                <p className="font-medium text-gray-900 text-sm truncate">{r.title}</p>
                <p className="text-xs text-gray-500 line-clamp-2">{r.summary}</p>
              </div>
              <button
                type="button"
                onClick={() => onOpen(r)}
                className="shrink-0 text-xs font-semibold px-3 py-1.5 rounded-lg bg-gray-900 text-white hover:bg-gray-800"
              >
                {actionLabel}
              </button>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

function inboxRecipientLabel(role: ExecutiveReportInboxNotice["recipientRole"]) {
  switch (role) {
    case "unit_head":
      return "Unit head";
    case "manager":
      return "Manager";
    case "director":
      return "Director";
  }
}
