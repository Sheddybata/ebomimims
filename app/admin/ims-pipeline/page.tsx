"use client";

import { useCallback, useEffect, useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import ImsPipelineColumn from "@/components/ims/ImsPipelineColumn";
import {
  clearExecutiveReportInboxNotices,
  getExecutiveReportInboxNotices,
  type ExecutiveReportInboxNotice,
} from "@/lib/ims-reports/executiveInboxStore";
import {
  getImsPipelineReports,
  resetImsPipelineToDemo,
  imsStageLabels,
  filterImsPipelineByStage,
  type ImsPipelineReport,
} from "@/lib/ims-reports/pipelineStore";
import {
  RefreshCw,
  ArrowRight,
  GitBranch,
  RotateCcw,
} from "lucide-react";

export default function ImsPipelinePage() {
  const [reports, setReports] = useState<ImsPipelineReport[]>([]);
  const [inboxNotices, setInboxNotices] = useState<ExecutiveReportInboxNotice[]>([]);
  const [showDevTools, setShowDevTools] = useState(false);

  const refresh = useCallback(() => {
    setReports(getImsPipelineReports());
    setInboxNotices(getExecutiveReportInboxNotices());
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const national = filterImsPipelineByStage(reports, "awaiting_administration");
  const ago = filterImsPipelineByStage(reports, "awaiting_ago");
  const goQueue = filterImsPipelineByStage(reports, "awaiting_general_overseer");
  const returned = filterImsPipelineByStage(reports, "returned_for_revision");
  const approved = filterImsPipelineByStage(reports, "approved");

  return (
    <ProtectedRoute requireAdmin>
      <DashboardLayout>
        <div className="p-6 md:p-8 space-y-8 max-w-7xl mx-auto">
          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4">
            <div>
              <div className="flex items-center gap-2 text-primary-600 mb-2">
                <GitBranch size={22} />
                <span className="text-sm font-semibold uppercase tracking-wide">EBOMIM IMS</span>
              </div>
              <h1 className="text-2xl font-bold text-gray-900">Directorate reports pipeline</h1>
              <p className="text-gray-600 mt-1 max-w-2xl text-sm leading-relaxed">
                <strong>Super Admin overview:</strong> monitor the full report journey across NDA, AGO,
                General Overseer, returned items, and approved archives. Executive users still work from
                their own focused queues; this page is read-only.
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <button
                type="button"
                onClick={() => {
                  refresh();
                }}
                className="px-3 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 flex items-center gap-2"
              >
                <RefreshCw size={16} />
                Refresh
              </button>
              <button
                type="button"
                onClick={() => setShowDevTools((v) => !v)}
                className="px-3 py-2 bg-amber-50 border border-amber-200 rounded-lg text-sm font-medium text-amber-900 hover:bg-amber-100 flex items-center gap-2"
              >
                <RotateCcw size={16} />
                Developer tools
              </button>
            </div>
          </div>

          {showDevTools ? (
            <section className="rounded-xl border border-amber-200 bg-amber-50/70 p-4">
              <p className="text-sm font-bold text-amber-950">Developer tools</p>
              <p className="mt-1 text-xs leading-relaxed text-amber-900">
                These controls are for local testing only and should stay hidden during user demos.
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                <button
                  type="button"
                  onClick={() => {
                    if (
                      window.confirm(
                        "Reset all pipeline items to the built-in sample set? This clears local changes.",
                      )
                    ) {
                      resetImsPipelineToDemo();
                      refresh();
                    }
                  }}
                  className="rounded-lg bg-amber-600 px-3 py-2 text-xs font-semibold text-white hover:bg-amber-700"
                >
                  Reset pipeline sample data
                </button>
              </div>
            </section>
          ) : null}

          {/* Flow strip */}
          <div className="bg-gradient-to-r from-slate-800 to-slate-900 rounded-xl p-4 text-white">
            <p className="text-xs font-medium text-slate-300 mb-2">End-to-end (reference)</p>
            <div className="flex flex-wrap items-center gap-2 text-xs sm:text-sm">
              <span className="px-2 py-1 bg-white/10 rounded">Unit head / Manager (mobile)</span>
              <ArrowRight size={14} className="opacity-60 shrink-0" />
              <span className="px-2 py-1 bg-white/10 rounded">Director (mobile)</span>
              <ArrowRight size={14} className="opacity-60 shrink-0" />
              <span className="px-2 py-1 bg-red-500/30 rounded border border-red-400/40">
                National Director of Administration
              </span>
              <ArrowRight size={14} className="opacity-60 shrink-0" />
              <span className="px-2 py-1 bg-white/10 rounded">Assistant General Overseer</span>
              <ArrowRight size={14} className="opacity-60 shrink-0" />
              <span className="px-2 py-1 bg-white/10 rounded">General Overseer</span>
              <ArrowRight size={14} className="opacity-60 shrink-0" />
              <span className="px-2 py-1 bg-emerald-500/30 rounded border border-emerald-400/40">Approved</span>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <ImsPipelineColumn
              title={imsStageLabels.awaiting_administration}
              description="Read-only view of reports waiting for NDA review."
              reports={national}
              accent="border-l-4 border-red-500"
              actions={() => null}
            />
            <ImsPipelineColumn
              title={imsStageLabels.awaiting_ago}
              description="Read-only view of reports waiting for AGO review."
              reports={ago}
              accent="border-l-4 border-amber-500"
              actions={() => null}
            />
            <ImsPipelineColumn
              title={imsStageLabels.awaiting_general_overseer}
              description="Read-only view of reports waiting for GO final approval."
              reports={goQueue}
              accent="border-l-4 border-violet-500"
              actions={() => null}
            />
            <ImsPipelineColumn
              title={imsStageLabels.returned_for_revision}
              description="Items sent back by NDA, AGO, or GO with a correction note."
              reports={returned}
              accent="border-l-4 border-amber-300"
              actions={() => null}
            />
            <ImsPipelineColumn
              title={imsStageLabels.approved}
              description="Closed items (archive)."
              reports={approved}
              accent="border-l-4 border-emerald-500"
              actions={() => null}
            />
          </div>

          <section className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
            <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
              <div>
                <h2 className="font-bold text-gray-900">Outcome Inbox Notices</h2>
                <p className="mt-1 max-w-2xl text-xs leading-relaxed text-gray-600">
                  Approval and return notices generated for unit heads, managers, and directors.
                  These represent the inbox messages the app should receive after executive action.
                </p>
              </div>
              {inboxNotices.length > 0 ? (
                <button
                  type="button"
                  onClick={() => {
                    if (window.confirm("Clear all outcome inbox notices?")) {
                      clearExecutiveReportInboxNotices();
                      refresh();
                    }
                  }}
                  className="shrink-0 rounded-lg border border-gray-300 px-3 py-1.5 text-xs font-semibold text-gray-700 hover:bg-gray-50"
                >
                  Clear notices
                </button>
              ) : null}
            </div>

            {inboxNotices.length === 0 ? (
              <div className="mt-4 rounded-lg border border-dashed border-gray-200 bg-gray-50 px-4 py-8 text-center">
                <p className="text-sm font-medium text-gray-700">No outcome notices yet</p>
                <p className="mt-1 text-xs text-gray-500">
                  Notices will appear here when GO approves or an executive returns a report for revision.
                </p>
              </div>
            ) : (
              <ul className="mt-4 grid grid-cols-1 gap-3 lg:grid-cols-2">
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
      </DashboardLayout>
    </ProtectedRoute>
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
