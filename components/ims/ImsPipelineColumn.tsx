"use client";

import type { ReactNode } from "react";
import { Building2, Inbox } from "lucide-react";
import type { ImsPipelineReport } from "@/lib/ims-reports/pipelineStore";
import { authorRoleLabel } from "@/lib/ims-reports/pipelineStore";
import PipelineMetricsDashboard from "@/components/ims/PipelineMetricsDashboard";

export default function ImsPipelineColumn({
  title,
  description,
  reports,
  accent,
  actions,
}: {
  title: string;
  description: string;
  reports: ImsPipelineReport[];
  accent: string;
  actions: (r: ImsPipelineReport) => ReactNode;
}) {
  return (
    <div className={`bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden ${accent}`}>
      <div className="p-4 border-b border-gray-100 bg-gray-50/80">
        <div className="flex items-center gap-2">
          <Building2 size={18} className="text-gray-600" />
          <h2 className="font-bold text-gray-900">{title}</h2>
          <span className="ml-auto text-xs font-semibold text-gray-500 bg-white px-2 py-0.5 rounded-full border">
            {reports.length}
          </span>
        </div>
        <p className="text-xs text-gray-600 mt-1">{description}</p>
      </div>
      <div className="p-3 space-y-3 max-h-[min(520px,60vh)] overflow-y-auto">
        {reports.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-10 px-6 text-center rounded-lg border border-dashed border-gray-200 bg-gray-50/60 mx-1">
            <span className="flex h-12 w-12 items-center justify-center rounded-full bg-white shadow-sm border border-gray-100 text-gray-400 mb-3">
              <Inbox size={22} strokeWidth={2} />
            </span>
            <p className="text-sm font-medium text-gray-700">Nothing in this column yet</p>
            <p className="text-xs text-gray-500 mt-1 max-w-[220px] leading-relaxed">
              When reports move here, you&apos;ll see titles, metrics, and actions.
            </p>
          </div>
        ) : (
          reports.map((r) => (
            <article
              key={r.id}
              className="p-3.5 rounded-xl border border-gray-100 bg-white shadow-sm ring-1 ring-black/[0.03] hover:ring-gray-200/80 hover:shadow-md transition-all duration-200"
            >
              <h3 className="font-semibold text-gray-900 text-sm leading-snug">{r.title}</h3>
              <div className="mt-2 flex flex-wrap gap-1.5 text-[10px] text-gray-600">
                <span className="inline-flex items-center rounded-md bg-gray-100 px-2 py-0.5 font-medium text-gray-800 max-w-full truncate">
                  {r.directorateName}
                </span>
                {r.reportType ? (
                  <span className="inline-flex items-center rounded-md bg-slate-900 px-2 py-0.5 font-medium text-white">
                    {r.reportType}
                  </span>
                ) : null}
                {r.unitName ? (
                  <span className="inline-flex items-center rounded-md bg-primary-50 px-2 py-0.5 font-medium text-primary-900 max-w-[180px] truncate">
                    {r.unitName}
                  </span>
                ) : null}
                <span className="inline-flex items-center rounded-md border border-gray-200 px-2 py-0.5">
                  {authorRoleLabel(r.authorRole)}: {r.authorName}
                </span>
              </div>
              {r.metrics && Object.keys(r.metrics).length > 0 ? (
                <PipelineMetricsDashboard metrics={r.metrics} />
              ) : null}
              {r.returnedNote ? (
                <div className="mt-3 rounded-lg border border-amber-200 bg-amber-50/80 p-3">
                  <p className="text-[10px] font-semibold uppercase tracking-wide text-amber-900">
                    Returned by {r.returnedByName ?? "Executive"}
                  </p>
                  <p className="mt-1 text-xs leading-relaxed text-amber-950 whitespace-pre-wrap break-words">
                    {r.returnedNote}
                  </p>
                  {r.returnedAt ? (
                    <p className="mt-1 text-[10px] text-amber-900/70">
                      {new Date(r.returnedAt).toLocaleString()}
                    </p>
                  ) : null}
                </div>
              ) : null}
              <div className="mt-2.5">
                <p className="text-[10px] font-semibold uppercase tracking-wide text-gray-400 mb-0.5">
                  Report body
                </p>
                <p className="text-xs text-gray-700 whitespace-pre-wrap break-words leading-relaxed">{r.summary}</p>
              </div>
              {r.timeline && r.timeline.length > 0 ? (
                <div className="mt-3 rounded-lg border border-gray-100 bg-gray-50/70 p-3">
                  <p className="text-[10px] font-semibold uppercase tracking-wide text-gray-500">
                    Report journey
                  </p>
                  <ol className="mt-2 space-y-2">
                    {r.timeline.map((event) => (
                      <li key={event.id} className="flex gap-2 text-xs">
                        <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-primary-500" />
                        <span className="min-w-0">
                          <span className="block font-semibold text-gray-800">{event.label}</span>
                          <span className="block text-[10px] text-gray-500">
                            {event.actorName} · {new Date(event.createdAt).toLocaleString()}
                          </span>
                          {event.note ? (
                            <span className="mt-1 block whitespace-pre-wrap break-words text-[11px] leading-relaxed text-gray-700">
                              {event.note}
                            </span>
                          ) : null}
                        </span>
                      </li>
                    ))}
                  </ol>
                </div>
              ) : null}
              <p className="text-[10px] text-gray-400 mt-2 tabular-nums">
                Updated {new Date(r.updatedAt).toLocaleString()}
              </p>
              {actions(r)}
            </article>
          ))
        )}
      </div>
    </div>
  );
}
