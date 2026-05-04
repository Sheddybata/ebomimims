"use client";

import { Clock3, History, Inbox } from "lucide-react";
import {
  authorRoleLabel,
  imsStageLabels,
  type ImsPipelineReport,
  type ImsPipelineTimelineEvent,
} from "@/lib/ims-reports/pipelineStore";
import type { ExecutiveHistoryRole } from "@/lib/ims-reports/supabasePipelineStore";

interface ExecutiveReportHistoryProps {
  role: ExecutiveHistoryRole;
  reports: ImsPipelineReport[];
}

export default function ExecutiveReportHistory({ role, reports }: ExecutiveReportHistoryProps) {
  const title = `${roleLabel(role)} report history`;

  return (
    <section className="rounded-xl border border-gray-200 bg-white shadow-sm">
      <div className="border-b border-gray-100 bg-gray-50/80 p-4">
        <div className="flex items-center gap-2">
          <History size={18} className="text-gray-600" />
          <h2 className="font-bold text-gray-900">{title}</h2>
          <span className="ml-auto rounded-full border bg-white px-2 py-0.5 text-xs font-semibold text-gray-500">
            {reports.length}
          </span>
        </div>
        <p className="mt-1 text-xs text-gray-600">
          Reports this desk has already received and processed. This is read-only.
        </p>
      </div>

      <div className="space-y-3 p-3">
        {reports.length === 0 ? (
          <div className="flex flex-col items-center justify-center rounded-lg border border-dashed border-gray-200 bg-gray-50/60 px-6 py-10 text-center">
            <span className="mb-3 flex h-12 w-12 items-center justify-center rounded-full border border-gray-100 bg-white text-gray-400 shadow-sm">
              <Inbox size={22} strokeWidth={2} />
            </span>
            <p className="text-sm font-medium text-gray-700">No report history yet</p>
            <p className="mt-1 max-w-[260px] text-xs leading-relaxed text-gray-500">
              Once reports leave this queue, their history will appear here.
            </p>
          </div>
        ) : (
          reports.map((report) => (
            <HistoryCard key={report.id} role={role} report={report} />
          ))
        )}
      </div>
    </section>
  );
}

function HistoryCard({
  role,
  report,
}: {
  role: ExecutiveHistoryRole;
  report: ImsPipelineReport;
}) {
  const timeline = report.timeline ?? [];
  const receivedEvent = findReceivedEvent(timeline, role);
  const lastDeskEvent = [...timeline].reverse().find((event) => event.actorRole === role);
  const summaryEvents = timeline.slice(-3);

  return (
    <article className="rounded-xl border border-gray-100 bg-white p-3.5 shadow-sm ring-1 ring-black/[0.03]">
      <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
        <div className="min-w-0">
          <h3 className="text-sm font-semibold leading-snug text-gray-900">{report.title}</h3>
          <div className="mt-2 flex flex-wrap gap-1.5 text-[10px] text-gray-600">
            <span className="inline-flex max-w-full truncate rounded-md bg-gray-100 px-2 py-0.5 font-medium text-gray-800">
              {report.directorateName}
            </span>
            {report.unitName ? (
              <span className="inline-flex max-w-[180px] truncate rounded-md bg-primary-50 px-2 py-0.5 font-medium text-primary-900">
                {report.unitName}
              </span>
            ) : null}
            <span className="inline-flex rounded-md border border-gray-200 px-2 py-0.5">
              {authorRoleLabel(report.authorRole)}: {report.authorName}
            </span>
          </div>
        </div>
        <span className={`shrink-0 rounded-full px-2.5 py-1 text-[11px] font-bold ${stageTone(report.stage)}`}>
          {imsStageLabels[report.stage]}
        </span>
      </div>

      <div className="mt-3 grid gap-2 text-xs text-gray-600 sm:grid-cols-2">
        <HistoryFact label="Received" event={receivedEvent} />
        <HistoryFact label="Last desk action" event={lastDeskEvent} />
      </div>

      {summaryEvents.length > 0 ? (
        <ol className="mt-3 space-y-1.5 rounded-lg border border-gray-100 bg-gray-50/70 p-3">
          {summaryEvents.map((event) => (
            <li key={event.id} className="flex gap-2 text-xs">
              <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-primary-500" />
              <span className="min-w-0">
                <span className="block font-semibold text-gray-800">{event.label}</span>
                <span className="block text-[10px] text-gray-500">
                  {event.actorName} · {new Date(event.createdAt).toLocaleString()}
                </span>
              </span>
            </li>
          ))}
        </ol>
      ) : null}
    </article>
  );
}

function HistoryFact({
  label,
  event,
}: {
  label: string;
  event?: ImsPipelineTimelineEvent;
}) {
  return (
    <div className="rounded-lg border border-gray-100 bg-gray-50 px-3 py-2">
      <p className="flex items-center gap-1 text-[10px] font-semibold uppercase tracking-wide text-gray-500">
        <Clock3 size={12} />
        {label}
      </p>
      <p className="mt-1 font-medium text-gray-800">
        {event ? new Date(event.createdAt).toLocaleString() : "Not recorded"}
      </p>
      {event ? <p className="mt-0.5 text-[11px] text-gray-500">{event.label}</p> : null}
    </div>
  );
}

function findReceivedEvent(timeline: ImsPipelineTimelineEvent[], role: ExecutiveHistoryRole) {
  const action =
    role === "nda"
      ? "submitted_to_nda"
      : role === "ago"
        ? "forwarded_to_ago"
        : "forwarded_to_go";
  return timeline.find((event) => event.action === action);
}

function roleLabel(role: ExecutiveHistoryRole) {
  switch (role) {
    case "nda":
      return "NDA";
    case "ago":
      return "AGO";
    case "general_overseer":
      return "GO";
  }
}

function stageTone(stage: ImsPipelineReport["stage"]) {
  switch (stage) {
    case "approved":
      return "bg-emerald-100 text-emerald-700";
    case "returned_for_revision":
      return "bg-amber-100 text-amber-800";
    case "awaiting_general_overseer":
      return "bg-violet-100 text-violet-700";
    case "awaiting_ago":
      return "bg-orange-100 text-orange-800";
    case "awaiting_administration":
      return "bg-red-100 text-red-700";
  }
}
