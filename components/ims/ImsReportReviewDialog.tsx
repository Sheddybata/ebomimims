"use client";

import { useState } from "react";
import { X } from "lucide-react";
import { MIN_EXECUTIVE_RETURN_NOTE_LENGTH } from "@/lib/ims-reports/pipelineStore";
import type { ImsPipelineReport } from "@/lib/ims-reports/pipelineStore";
import { authorRoleLabel } from "@/lib/ims-reports/pipelineStore";
import PipelineMetricsDashboard from "@/components/ims/PipelineMetricsDashboard";

export default function ImsReportReviewDialog({
  report,
  title,
  decisionSummary,
  confirmLabel,
  confirmClassName,
  returnLabel,
  isBusy = false,
  onCancel,
  onConfirm,
  onReturn,
}: {
  report: ImsPipelineReport;
  title: string;
  decisionSummary: string;
  confirmLabel: string;
  confirmClassName: string;
  returnLabel?: string;
  isBusy?: boolean;
  onCancel: () => void;
  onConfirm: () => void;
  onReturn?: (note: string) => void;
}) {
  const [returnNote, setReturnNote] = useState("");
  const [returnError, setReturnError] = useState("");

  const submitReturn = () => {
    const trimmed = returnNote.trim();
    if (trimmed.length < MIN_EXECUTIVE_RETURN_NOTE_LENGTH) {
      setReturnError(
        `Enter at least ${MIN_EXECUTIVE_RETURN_NOTE_LENGTH} characters so the author knows what to fix.`,
      );
      return;
    }
    setReturnError("");
    onReturn?.(trimmed);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/45 p-0 sm:items-center sm:p-4">
      <div
        className="flex max-h-[92vh] w-full flex-col bg-white shadow-2xl sm:max-w-2xl sm:rounded-2xl"
        role="dialog"
        aria-modal="true"
        aria-labelledby="ims-report-review-title"
      >
        <div className="flex items-start justify-between gap-3 border-b border-gray-100 p-4 sm:p-5">
          <div className="min-w-0">
            <p className="text-xs font-semibold uppercase tracking-wide text-primary-700">
              Review before action
            </p>
            <h2 id="ims-report-review-title" className="mt-1 text-lg font-bold text-gray-900">
              {title}
            </h2>
          </div>
          <button
            type="button"
            onClick={onCancel}
            className="rounded-lg p-1.5 text-gray-500 hover:bg-gray-100 hover:text-gray-800"
            aria-label="Close review dialog"
          >
            <X size={22} />
          </button>
        </div>

        <div className="flex-1 space-y-5 overflow-y-auto p-4 sm:p-5">
          <section className="rounded-xl border border-primary-100 bg-primary-50/70 p-4">
            <p className="text-[11px] font-semibold uppercase tracking-wide text-primary-800">
              Decision summary
            </p>
            <p className="mt-1 text-sm leading-relaxed text-primary-950">{decisionSummary}</p>
          </section>

          <div>
            <h3 className="text-base font-bold text-gray-900">{report.title}</h3>
            <div className="mt-2 flex flex-wrap gap-1.5 text-[11px] text-gray-600">
              <span className="inline-flex rounded-md bg-gray-100 px-2 py-1 font-medium text-gray-800">
                {report.directorateName}
              </span>
              {report.reportType ? (
                <span className="inline-flex rounded-md bg-slate-900 px-2 py-1 font-medium text-white">
                  {report.reportType}
                </span>
              ) : null}
              {report.unitName ? (
                <span className="inline-flex rounded-md bg-primary-50 px-2 py-1 font-medium text-primary-900">
                  {report.unitName}
                </span>
              ) : null}
              <span className="inline-flex rounded-md border border-gray-200 px-2 py-1">
                {authorRoleLabel(report.authorRole)}: {report.authorName}
              </span>
            </div>
          </div>

          {report.metrics && Object.keys(report.metrics).length > 0 ? (
            <PipelineMetricsDashboard metrics={report.metrics} />
          ) : null}

          <section className="rounded-xl border border-gray-200 bg-gray-50/70 p-4">
            <p className="text-[11px] font-semibold uppercase tracking-wide text-gray-500">
              Full report body
            </p>
            <p className="mt-2 whitespace-pre-wrap break-words text-sm leading-relaxed text-gray-800">
              {report.summary}
            </p>
          </section>

          <p className="text-xs text-gray-500">
            Last updated {new Date(report.updatedAt).toLocaleString()}
          </p>

          {report.timeline && report.timeline.length > 0 ? (
            <section className="rounded-xl border border-gray-200 bg-white p-4">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-gray-500">
                Report journey
              </p>
              <ol className="mt-3 space-y-3">
                {report.timeline.map((event) => (
                  <li key={event.id} className="flex gap-3 text-sm">
                    <span className="mt-1.5 h-2.5 w-2.5 shrink-0 rounded-full bg-primary-600" />
                    <div className="min-w-0">
                      <p className="font-semibold text-gray-900">{event.label}</p>
                      <p className="text-xs text-gray-500">
                        {event.actorName} · {new Date(event.createdAt).toLocaleString()}
                      </p>
                      {event.note ? (
                        <p className="mt-1 whitespace-pre-wrap break-words rounded-md bg-gray-50 p-2 text-xs leading-relaxed text-gray-700">
                          {event.note}
                        </p>
                      ) : null}
                    </div>
                  </li>
                ))}
              </ol>
            </section>
          ) : null}

          {onReturn ? (
            <section className="rounded-xl border border-amber-200 bg-amber-50/70 p-4">
              <label
                htmlFor="executive-return-note"
                className="text-[11px] font-semibold uppercase tracking-wide text-amber-900"
              >
                Return for revision note
              </label>
              <p className="mt-1 text-xs leading-relaxed text-amber-900/80">
                Use this only when the report needs correction before it can continue. The author
                chain will receive the full note in their inbox. Minimum{" "}
                {MIN_EXECUTIVE_RETURN_NOTE_LENGTH} characters.
              </p>
              <textarea
                id="executive-return-note"
                value={returnNote}
                onChange={(e) => {
                  setReturnNote(e.target.value);
                  if (returnError) setReturnError("");
                }}
                rows={4}
                className="mt-3 w-full rounded-lg border border-amber-300 bg-white px-3 py-2 text-sm text-gray-900 outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-200"
                placeholder="Explain what needs correction before this report can continue."
              />
              {returnError ? (
                <p className="mt-2 text-xs font-medium text-red-600" role="alert">
                  {returnError}
                </p>
              ) : null}
            </section>
          ) : null}
        </div>

        <div className="flex flex-col-reverse gap-2 border-t border-gray-100 p-4 sm:flex-row sm:justify-end sm:p-5">
          <button
            type="button"
            onClick={onCancel}
            disabled={isBusy}
            className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Cancel
          </button>
          {onReturn ? (
            <button
              type="button"
              onClick={submitReturn}
              disabled={isBusy}
              className="rounded-lg border border-amber-300 bg-amber-50 px-4 py-2 text-sm font-semibold text-amber-900 hover:bg-amber-100 disabled:cursor-not-allowed disabled:opacity-60"
            >
              {isBusy ? "Processing..." : returnLabel ?? "Return for revision"}
            </button>
          ) : null}
          <button
            type="button"
            onClick={onConfirm}
            disabled={isBusy}
            className={`rounded-lg px-4 py-2 text-sm font-semibold text-white disabled:cursor-not-allowed disabled:opacity-60 ${confirmClassName}`}
          >
            {isBusy ? "Processing..." : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
