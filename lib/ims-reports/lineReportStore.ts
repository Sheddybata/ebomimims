/**
 * Demo line-level reports (unit head → manager → director) for the web admin.
 * Separate from the Flutter in-memory store; localStorage only.
 */

import { appendLineReportToImsPipeline, type ImsAuthorRole } from "./pipelineStore";

export const MIN_SENDBACK_NOTE_LENGTH = 20;

export type LineReportStage = "awaiting_manager" | "awaiting_director" | "revision_requested";

export type LineAuthorRole = "unit_head" | "manager" | "director";

export interface LineReport {
  id: string;
  title: string;
  summary: string;
  reportType: string;
  metrics?: Record<string, string>;
  directorateId: string;
  directorateName: string;
  unitId: string | null;
  unitName: string | null;
  authorId: string;
  authorName: string;
  authorRole: LineAuthorRole;
  stage: LineReportStage;
  sendBackNote: string | null;
  sendBackByName: string | null;
  sendBackByRole: "manager" | "director" | null;
  sendBackAt: string | null;
  createdAt: string;
  updatedAt: string;
}

const STORAGE_KEY = "ims_line_reports_v1";

const demoSeed: LineReport[] = [
  {
    id: "line-seed-1",
    title: "Weekly field summary (web demo)",
    summary:
      "Prayer walks completed; 12 new contacts. Same shape as the mobile mock awaiting manager review.",
    reportType: "Narrative",
    metrics: {
      locations_reached: "7",
      souls_won: "12",
      contacts_captured: "12",
    },
    directorateId: "missions_evangelism",
    directorateName: "Directorate of Missions and Evangelism",
    unitId: "me_u1",
    unitName: "Street and Community Evangelism Unit",
    authorId: "uh_demo",
    authorName: "Unit head (web demo)",
    authorRole: "unit_head",
    stage: "awaiting_manager",
    sendBackNote: null,
    sendBackByName: null,
    sendBackByRole: null,
    sendBackAt: null,
    createdAt: new Date(Date.now() - 3 * 3600000).toISOString(),
    updatedAt: new Date(Date.now() - 3 * 3600000).toISOString(),
  },
  {
    id: "line-seed-2",
    title: "Consolidated Q1 outreach (web demo)",
    summary: "Forwarded to director queue for approval or send-back test.",
    reportType: "Financial",
    metrics: {
      household_visits: "9",
      community_leader_engagement: "Two community leaders met; one follow-up scheduled for Friday.",
    },
    directorateId: "missions_evangelism",
    directorateName: "Directorate of Missions and Evangelism",
    unitId: "me_u2",
    unitName: "Missionary and rural outreach unit",
    authorId: "uh_demo",
    authorName: "Unit head (web demo)",
    authorRole: "unit_head",
    stage: "awaiting_director",
    sendBackNote: null,
    sendBackByName: null,
    sendBackByRole: null,
    sendBackAt: null,
    createdAt: new Date(Date.now() - 26 * 3600000).toISOString(),
    updatedAt: new Date(Date.now() - 5 * 3600000).toISOString(),
  },
  {
    id: "line-seed-mgr",
    title: "Manager memorandum — web demo",
    summary: "Director can approve into the National Director of Administration queue or send back to the manager.",
    reportType: "Narrative",
    directorateId: "missions_evangelism",
    directorateName: "Directorate of Missions and Evangelism",
    unitId: null,
    unitName: null,
    authorId: "mgr_web_demo",
    authorName: "Manager (web demo)",
    authorRole: "manager",
    stage: "awaiting_director",
    sendBackNote: null,
    sendBackByName: null,
    sendBackByRole: null,
    sendBackAt: null,
    createdAt: new Date(Date.now() - 9 * 3600000).toISOString(),
    updatedAt: new Date(Date.now() - 9 * 3600000).toISOString(),
  },
  {
    id: "line-seed-revision",
    title: "Rural outreach expense draft",
    summary: "Original summary before send-back (demo).",
    reportType: "Financial",
    directorateId: "missions_evangelism",
    directorateName: "Directorate of Missions and Evangelism",
    unitId: "me_u1",
    unitName: "Street and Community Evangelism Unit",
    authorId: "uh_demo",
    authorName: "Unit head (web demo)",
    authorRole: "unit_head",
    stage: "revision_requested",
    sendBackNote:
      "Please attach scanned receipts for transport and list each expense line with date and amount. The directorate finance checklist requires at least three line items before this can move forward.",
    sendBackByName: "Manager (web demo)",
    sendBackByRole: "manager",
    sendBackAt: new Date(Date.now() - 3600000).toISOString(),
    createdAt: new Date(Date.now() - 2 * 86400000).toISOString(),
    updatedAt: new Date(Date.now() - 3600000).toISOString(),
  },
];

function loadRaw(): LineReport[] {
  if (typeof window === "undefined") return demoSeed.map((r) => ({ ...r }));
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return demoSeed.map((r) => ({ ...r }));
    const parsed = JSON.parse(raw) as LineReport[];
    return Array.isArray(parsed) && parsed.length > 0 ? parsed : demoSeed.map((r) => ({ ...r }));
  } catch {
    return demoSeed.map((r) => ({ ...r }));
  }
}

function saveRaw(list: LineReport[]) {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
}

export function getLineReports(): LineReport[] {
  return loadRaw();
}

export function resetLineReportsToDemo(): LineReport[] {
  const fresh = demoSeed.map((r) => ({ ...r }));
  saveRaw(fresh);
  return fresh;
}

function touch(
  r: LineReport,
  patch: Partial<LineReport> & Pick<LineReport, "stage">,
): LineReport {
  const now = new Date().toISOString();
  return { ...r, ...patch, updatedAt: now };
}

function clearSendBack(r: LineReport): Pick<
  LineReport,
  "sendBackNote" | "sendBackByName" | "sendBackByRole" | "sendBackAt"
> {
  return {
    sendBackNote: null,
    sendBackByName: null,
    sendBackByRole: null,
    sendBackAt: null,
  };
}

export function managerForwardToDirectorLine(id: string): LineReport | null {
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "awaiting_manager") return null;
  list[i] = touch(list[i], {
    stage: "awaiting_director",
    ...clearSendBack(list[i]),
  });
  saveRaw(list);
  return list[i];
}

export function directorApproveToNationalQueueLine(id: string): LineReport | null {
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "awaiting_director") return null;
  const r = list[i];
  appendLineReportToImsPipeline({
    title: r.title,
    summary: r.summary,
    reportType: r.reportType,
    directorateId: r.directorateId,
    directorateName: r.directorateName,
    unitName: r.unitName,
    authorRole: r.authorRole as ImsAuthorRole,
    authorName: r.authorName,
    metrics: r.metrics,
  });
  list.splice(i, 1);
  saveRaw(list);
  return r;
}

export function sendBackFromManagerLine(id: string, note: string): LineReport | null {
  const trimmed = note.trim();
  if (trimmed.length < MIN_SENDBACK_NOTE_LENGTH) return null;
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "awaiting_manager") return null;
  const now = new Date().toISOString();
  list[i] = touch(list[i], {
    stage: "revision_requested",
    sendBackNote: trimmed,
    sendBackByName: "Manager (web demo)",
    sendBackByRole: "manager",
    sendBackAt: now,
  });
  saveRaw(list);
  return list[i];
}

export function sendBackFromDirectorLine(id: string, note: string): LineReport | null {
  const trimmed = note.trim();
  if (trimmed.length < MIN_SENDBACK_NOTE_LENGTH) return null;
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "awaiting_director") return null;
  const r = list[i];
  const now = new Date().toISOString();
  list[i] = touch(r, {
    stage: "revision_requested",
    sendBackNote: trimmed,
    sendBackByName: "Director (web demo)",
    sendBackByRole: "director",
    sendBackAt: now,
  });
  saveRaw(list);
  return list[i];
}

/** Demo only: simulate unit head fixing the report and resubmitting to the manager queue. */
export function simulateUnitHeadResubmitLine(id: string): LineReport | null {
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "revision_requested") return null;
  if (list[i].authorRole !== "unit_head") return null;
  list[i] = touch(list[i], {
    stage: "awaiting_manager",
    ...clearSendBack(list[i]),
  });
  saveRaw(list);
  return list[i];
}

/** Demo only: manager resubmits after director send-back. */
export function simulateManagerResubmitLine(id: string): LineReport | null {
  const list = loadRaw();
  const i = list.findIndex((x) => x.id === id);
  if (i < 0) return null;
  if (list[i].stage !== "revision_requested") return null;
  if (list[i].authorRole !== "manager") return null;
  list[i] = touch(list[i], {
    stage: "awaiting_director",
    ...clearSendBack(list[i]),
  });
  saveRaw(list);
  return list[i];
}

export function lineStageLabel(s: LineReportStage): string {
  switch (s) {
    case "awaiting_manager":
      return "Awaiting manager";
    case "awaiting_director":
      return "Awaiting director";
    case "revision_requested":
      return "Returned for revision";
    default:
      return s;
  }
}
