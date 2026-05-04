/**
 * Mock IMS directorate report pipeline for the admin portal.
 * Stages: National Director of Administration → Assistant General Overseer → General Overseer.
 * Persisted in localStorage for demo continuity (not synced with the Flutter app without a backend).
 */

import {
  addApprovedReportNotices,
  addReturnedReportNotices,
  type ExecutiveActorRole,
} from "./executiveInboxStore";

export type ImsAuthorRole = "unit_head" | "manager" | "director" | "state_coordinator";
export const MIN_EXECUTIVE_RETURN_NOTE_LENGTH = 20;

export type ImsPipelineStage =
  | "awaiting_administration"
  | "awaiting_ago"
  | "awaiting_general_overseer"
  | "returned_for_revision"
  | "approved";

export type ImsPipelineTimelineAction =
  | "submitted_to_nda"
  | "forwarded_to_ago"
  | "forwarded_to_go"
  | "approved_by_go"
  | "returned_for_revision"
  | "resubmitted";

export interface ImsPipelineTimelineEvent {
  id: string;
  action: ImsPipelineTimelineAction;
  label: string;
  actorRole: ImsAuthorRole | ExecutiveActorRole | "system";
  actorName: string;
  note?: string;
  createdAt: string;
}

export interface ImsPipelineReport {
  id: string;
  title: string;
  summary: string;
  reportType?: string;
  directorateId: string;
  directorateName: string;
  unitName: string | null;
  authorRole: ImsAuthorRole;
  authorName: string;
  stage: ImsPipelineStage;
  createdAt: string;
  updatedAt: string;
  returnedByRole?: ExecutiveActorRole;
  returnedByName?: string;
  returnedNote?: string;
  returnedAt?: string;
  timeline?: ImsPipelineTimelineEvent[];
  /** Optional structured unit-head metrics (mobile smart forms / future sync). */
  metrics?: Record<string, string>;
}

const STORAGE_KEY = "ims_pipeline_reports_v1";

const actorNames: Record<ExecutiveActorRole, string> = {
  nda: "National Director of Administration",
  ago: "Assistant General Overseer",
  general_overseer: "General Overseer",
};

const demoSeed: ImsPipelineReport[] = [
  {
    id: "web-seed-1",
    title: "Directorate annual summary (director)",
    summary: "Director submission — aligns with mobile mock awaiting administration.",
    reportType: "Narrative",
    directorateId: "missions_evangelism",
    directorateName: "Directorate of Missions and Evangelism",
    unitName: "Street and Community Evangelism Unit",
    authorRole: "director",
    authorName: "Director (sample)",
    stage: "awaiting_administration",
    createdAt: new Date(Date.now() - 3 * 86400000).toISOString(),
    updatedAt: new Date(Date.now() - 12 * 3600000).toISOString(),
    metrics: {
      locations_reached: "18",
      souls_won: "64",
      contacts_captured: "41",
    },
  },
  {
    id: "web-seed-2",
    title: "Cross-directorate security prayer brief",
    summary: "Forwarded mock: sits with the National Director of Administration for triage.",
    reportType: "Narrative",
    directorateId: "intercession_prayer",
    directorateName: "Directorate of Intercession and Prayer (under National Coordinator)",
    unitName: "National prayer operations unit",
    authorRole: "manager",
    authorName: "Manager (Intercession)",
    stage: "awaiting_administration",
    createdAt: new Date(Date.now() - 5 * 86400000).toISOString(),
    updatedAt: new Date(Date.now() - 2 * 86400000).toISOString(),
  },
  {
    id: "web-seed-3",
    title: "Finance compliance pack Q1",
    summary: "National Director of Administration forwarded to AGO for executive visibility.",
    reportType: "Financial",
    directorateId: "finance_treasury_supply",
    directorateName: "Directorate of Finance, Treasury, Purchase & Supply",
    unitName: null,
    authorRole: "director",
    authorName: "Director (Finance)",
    stage: "awaiting_ago",
    createdAt: new Date(Date.now() - 6 * 86400000).toISOString(),
    updatedAt: new Date(Date.now() - 1 * 86400000).toISOString(),
  },
  {
    id: "web-seed-4",
    title: "Programs & publicity launch memo",
    summary: "AGO escalated to General Overseer for final approval.",
    reportType: "Narrative",
    directorateId: "programs_publicity",
    directorateName: "Directorate of Programs and Publicity",
    unitName: null,
    authorRole: "director",
    authorName: "Director (Programs)",
    stage: "awaiting_general_overseer",
    createdAt: new Date(Date.now() - 8 * 86400000).toISOString(),
    updatedAt: new Date(Date.now() - 6 * 3600000).toISOString(),
  },
  {
    id: "web-seed-5",
    title: "Discipleship metrics — approved reference",
    summary: "Final GO approval (mock archive).",
    reportType: "Narrative",
    directorateId: "discipleship_mentorship",
    directorateName: "Directorate of Discipleship and Mentorship",
    unitName: "Training unit",
    authorRole: "unit_head",
    authorName: "Unit head (sample)",
    stage: "approved",
    createdAt: new Date(Date.now() - 14 * 86400000).toISOString(),
    updatedAt: new Date(Date.now() - 9 * 86400000).toISOString(),
  },
];

function makeTimelineEvent(
  action: ImsPipelineTimelineAction,
  label: string,
  actorRole: ImsPipelineTimelineEvent["actorRole"],
  actorName: string,
  createdAt: string,
  note?: string,
): ImsPipelineTimelineEvent {
  return {
    id: `timeline-${createdAt}-${action}-${Math.random().toString(36).slice(2, 8)}`,
    action,
    label,
    actorRole,
    actorName,
    createdAt,
    ...(note ? { note } : {}),
  };
}

function withTimelineEvent(
  report: ImsPipelineReport,
  action: ImsPipelineTimelineAction,
  label: string,
  actorRole: ImsPipelineTimelineEvent["actorRole"],
  actorName: string,
  createdAt: string,
  note?: string,
): ImsPipelineReport {
  return {
    ...report,
    timeline: [
      ...(report.timeline ?? []),
      makeTimelineEvent(action, label, actorRole, actorName, createdAt, note),
    ],
  };
}

function inferredTimeline(report: ImsPipelineReport): ImsPipelineTimelineEvent[] {
  if (report.timeline?.length) return report.timeline;
  const events: ImsPipelineTimelineEvent[] = [
    makeTimelineEvent(
      "submitted_to_nda",
      "Report entered NDA queue",
      report.authorRole,
      report.authorName,
      report.createdAt,
    ),
  ];
  const updatedAt = report.updatedAt || report.createdAt;
  if (report.stage === "awaiting_ago" || report.stage === "awaiting_general_overseer" || report.stage === "approved") {
    events.push(
      makeTimelineEvent(
        "forwarded_to_ago",
        "Forwarded to AGO",
        "nda",
        actorNames.nda,
        updatedAt,
      ),
    );
  }
  if (report.stage === "awaiting_general_overseer" || report.stage === "approved") {
    events.push(
      makeTimelineEvent(
        "forwarded_to_go",
        "Forwarded to GO",
        "ago",
        actorNames.ago,
        updatedAt,
      ),
    );
  }
  if (report.stage === "approved") {
    events.push(
      makeTimelineEvent(
        "approved_by_go",
        "Approved by GO",
        "general_overseer",
        actorNames.general_overseer,
        updatedAt,
      ),
    );
  }
  if (report.stage === "returned_for_revision" && report.returnedNote) {
    events.push(
      makeTimelineEvent(
        "returned_for_revision",
        "Returned for revision",
        report.returnedByRole ?? "system",
        report.returnedByName ?? "Executive",
        report.returnedAt ?? updatedAt,
        report.returnedNote,
      ),
    );
  }
  return events;
}

function hydrateReport(report: ImsPipelineReport): ImsPipelineReport {
  return { ...report, timeline: inferredTimeline(report) };
}

function hydrateList(list: ImsPipelineReport[]): ImsPipelineReport[] {
  return list.map(hydrateReport);
}

function loadRaw(): ImsPipelineReport[] {
  if (typeof window === "undefined") return hydrateList([...demoSeed]);
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return hydrateList([...demoSeed]);
    const parsed = JSON.parse(raw) as ImsPipelineReport[];
    return Array.isArray(parsed) && parsed.length > 0 ? hydrateList(parsed) : hydrateList([...demoSeed]);
  } catch {
    return hydrateList([...demoSeed]);
  }
}

function saveRaw(list: ImsPipelineReport[]) {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
}

export function getImsPipelineReports(): ImsPipelineReport[] {
  return loadRaw();
}

/** Append a new row when a director approves on the line-review (web) flow. */
export function appendLineReportToImsPipeline(entry: {
  title: string;
  summary: string;
  reportType?: string;
  directorateId: string;
  directorateName: string;
  unitName: string | null;
  authorRole: ImsAuthorRole;
  authorName: string;
  metrics?: Record<string, string>;
}): ImsPipelineReport {
  const list = loadRaw();
  const now = new Date().toISOString();
  const id = `from-line-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;
  const row: ImsPipelineReport = {
    id,
    title: entry.title,
    summary: entry.summary,
    ...(entry.reportType ? { reportType: entry.reportType } : {}),
    directorateId: entry.directorateId,
    directorateName: entry.directorateName,
    unitName: entry.unitName,
    authorRole: entry.authorRole,
    authorName: entry.authorName,
    stage: "awaiting_administration",
    createdAt: now,
    updatedAt: now,
    timeline: [
      makeTimelineEvent(
        "submitted_to_nda",
        "Report entered NDA queue",
        entry.authorRole,
        entry.authorName,
        now,
      ),
    ],
    ...(entry.metrics && Object.keys(entry.metrics).length > 0 ? { metrics: { ...entry.metrics } } : {}),
  };
  list.push(row);
  saveRaw(list);
  return row;
}

export function filterImsPipelineByStage(
  list: ImsPipelineReport[],
  stage: ImsPipelineStage,
): ImsPipelineReport[] {
  return list.filter((r) => r.stage === stage);
}

export function resetImsPipelineToDemo(): ImsPipelineReport[] {
  const fresh = demoSeed.map((r) => ({ ...r }));
  saveRaw(fresh);
  return fresh;
}

export function nationalAdminForwardToAgo(id: string): ImsPipelineReport | null {
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "awaiting_administration") return null;
  const now = new Date().toISOString();
  list[i] = withTimelineEvent(
    { ...hydrateReport(list[i]), stage: "awaiting_ago", updatedAt: now },
    "forwarded_to_ago",
    "Forwarded to AGO",
    "nda",
    actorNames.nda,
    now,
  );
  saveRaw(list);
  return list[i];
}

export function agoForwardToGeneralOverseer(id: string): ImsPipelineReport | null {
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "awaiting_ago") return null;
  const now = new Date().toISOString();
  list[i] = withTimelineEvent(
    { ...hydrateReport(list[i]), stage: "awaiting_general_overseer", updatedAt: now },
    "forwarded_to_go",
    "Forwarded to GO",
    "ago",
    actorNames.ago,
    now,
  );
  saveRaw(list);
  return list[i];
}

export function generalOverseerApprove(id: string): ImsPipelineReport | null {
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "awaiting_general_overseer") return null;
  const now = new Date().toISOString();
  list[i] = withTimelineEvent(
    { ...hydrateReport(list[i]), stage: "approved", updatedAt: now },
    "approved_by_go",
    "Approved by GO",
    "general_overseer",
    actorNames.general_overseer,
    now,
  );
  addApprovedReportNotices(list[i]);
  saveRaw(list);
  return list[i];
}

function actorCanReturnStage(actorRole: ExecutiveActorRole, stage: ImsPipelineStage): boolean {
  return (
    (actorRole === "nda" && stage === "awaiting_administration") ||
    (actorRole === "ago" && stage === "awaiting_ago") ||
    (actorRole === "general_overseer" && stage === "awaiting_general_overseer")
  );
}

export function executiveReturnForRevision(
  id: string,
  actorRole: ExecutiveActorRole,
  note: string,
): ImsPipelineReport | null {
  const trimmed = note.trim();
  if (trimmed.length < MIN_EXECUTIVE_RETURN_NOTE_LENGTH) return null;
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (!actorCanReturnStage(actorRole, list[i].stage)) return null;
  const now = new Date().toISOString();
  list[i] = withTimelineEvent({
    ...list[i],
    stage: "returned_for_revision",
    returnedByRole: actorRole,
    returnedByName: actorNames[actorRole],
    returnedNote: trimmed,
    returnedAt: now,
    updatedAt: now,
  },
    "returned_for_revision",
    "Returned for revision",
    actorRole,
    actorNames[actorRole],
    now,
    trimmed,
  );
  addReturnedReportNotices(list[i], actorRole, trimmed);
  saveRaw(list);
  return list[i];
}

export const imsStageLabels: Record<ImsPipelineStage, string> = {
  awaiting_administration: "National Director of Administration",
  awaiting_ago: "Assistant General Overseer",
  awaiting_general_overseer: "General Overseer",
  returned_for_revision: "Returned for revision",
  approved: "Approved",
};

export function authorRoleLabel(r: ImsAuthorRole): string {
  switch (r) {
    case "unit_head":
      return "Unit head";
    case "manager":
      return "Manager";
    case "director":
      return "Director";
    case "state_coordinator":
      return "State coordinator";
  }
}
