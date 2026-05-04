import type { ImsAuthorRole, ImsPipelineReport } from "./pipelineStore";

export type ExecutiveInboxStatus = "approved" | "returned_for_revision";
export type ExecutiveActorRole = "nda" | "ago" | "general_overseer";

export interface ExecutiveReportInboxNotice {
  id: string;
  reportId: string;
  reportTitle: string;
  recipientRole: ImsAuthorRole;
  recipientName: string;
  status: ExecutiveInboxStatus;
  actorRole: ExecutiveActorRole;
  actorLabel: string;
  note: string | null;
  createdAt: string;
}

const STORAGE_KEY = "ims_executive_report_inbox_v1";

const actorLabels: Record<ExecutiveActorRole, string> = {
  nda: "National Director of Administration",
  ago: "Assistant General Overseer",
  general_overseer: "General Overseer",
};

function loadRaw(): ExecutiveReportInboxNotice[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw) as ExecutiveReportInboxNotice[];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function saveRaw(list: ExecutiveReportInboxNotice[]) {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
}

function recipientsFor(report: ImsPipelineReport): Array<Pick<ExecutiveReportInboxNotice, "recipientRole" | "recipientName">> {
  if (report.authorRole === "unit_head") {
    return [
      { recipientRole: "unit_head", recipientName: report.authorName },
      { recipientRole: "manager", recipientName: "Manager responsible" },
      { recipientRole: "director", recipientName: "Director responsible" },
    ];
  }
  if (report.authorRole === "manager") {
    return [
      { recipientRole: "manager", recipientName: report.authorName },
      { recipientRole: "director", recipientName: "Director responsible" },
    ];
  }
  return [{ recipientRole: "director", recipientName: report.authorName }];
}

function addNotices(
  report: ImsPipelineReport,
  status: ExecutiveInboxStatus,
  actorRole: ExecutiveActorRole,
  note: string | null,
) {
  const list = loadRaw();
  const now = new Date().toISOString();
  const newItems = recipientsFor(report).map((recipient, index) => ({
    id: `notice-${Date.now()}-${index}-${Math.random().toString(36).slice(2, 8)}`,
    reportId: report.id,
    reportTitle: report.title,
    recipientRole: recipient.recipientRole,
    recipientName: recipient.recipientName,
    status,
    actorRole,
    actorLabel: actorLabels[actorRole],
    note,
    createdAt: now,
  }));
  saveRaw([...newItems, ...list]);
}

export function addApprovedReportNotices(report: ImsPipelineReport) {
  addNotices(report, "approved", "general_overseer", null);
}

export function addReturnedReportNotices(
  report: ImsPipelineReport,
  actorRole: ExecutiveActorRole,
  note: string,
) {
  addNotices(report, "returned_for_revision", actorRole, note.trim());
}

export function getExecutiveReportInboxNotices(): ExecutiveReportInboxNotice[] {
  return loadRaw();
}

export function clearExecutiveReportInboxNotices() {
  saveRaw([]);
}
