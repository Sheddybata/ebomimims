"use client";

import { supabase } from "@/lib/supabase/client";
import type {
  ImsAuthorRole,
  ImsPipelineReport,
  ImsPipelineStage,
  ImsPipelineTimelineAction,
} from "@/lib/ims-reports/pipelineStore";

type ReportMetricRow = {
  metric_key: string;
  metric_value: string;
};

type TimelineRow = {
  id: string;
  action: string;
  label: string;
  actor_role: string;
  actor_name: string;
  note: string | null;
  created_at: string;
};

type SupabaseReportRow = {
  id: string;
  title: string;
  body: string;
  report_type: string;
  stage: string;
  author_role: string;
  returned_note: string | null;
  returned_at: string | null;
  created_at: string;
  updated_at: string;
  directorates: { code: string; name: string } | null;
  units: { code: string; name: string } | null;
  reference_states: { id: string; name: string } | null;
  report_metrics: ReportMetricRow[];
  report_timeline: TimelineRow[];
};

type DirectorateRow = {
  id: string;
  code: string;
  name: string;
};

type WeeklyReportRow = {
  directorate_id: string;
  created_at: string;
};

export type SupabaseWeeklyComplianceRow = {
  id: string;
  name: string;
  submitted: boolean;
  submittedAt: string | null;
};

export type ExecutiveHistoryRole = "nda" | "ago" | "general_overseer";

const REPORT_SELECT = `
  id,
  title,
  body,
  report_type,
  stage,
  author_role,
  returned_note,
  returned_at,
  created_at,
  updated_at,
  directorates(code, name),
  units(code, name),
  reference_states(id, name),
  report_metrics(metric_key, metric_value),
  report_timeline(id, action, label, actor_role, actor_name, note, created_at)
`;

export async function getSupabasePipelineReports(): Promise<ImsPipelineReport[]> {
  const { data, error } = await supabase
    .from("reports")
    .select(REPORT_SELECT)
    .in("stage", [
      "awaiting_administration",
      "awaiting_ago",
      "awaiting_general_overseer",
      "returned_for_revision",
      "approved",
    ])
    .order("updated_at", { ascending: false });

  if (error) throw error;
  return ((data ?? []) as unknown as SupabaseReportRow[]).map(mapReport);
}

export async function getSupabaseExecutiveHistory(
  role: ExecutiveHistoryRole,
): Promise<ImsPipelineReport[]> {
  const reports = await getSupabasePipelineReports();
  return reports.filter((report) => isExecutiveHistoryReport(report, role));
}

export async function getSupabaseWeeklyComplianceRows(): Promise<SupabaseWeeklyComplianceRow[]> {
  const weekStart = startOfWeekIso();
  const [{ data: directorates, error: directoratesError }, { data: reports, error: reportsError }] =
    await Promise.all([
      supabase
        .from("directorates")
        .select("id, code, name")
        .eq("is_active", true)
        .order("name", { ascending: true }),
      supabase
        .from("reports")
        .select("directorate_id, created_at")
        .gte("created_at", weekStart)
        .order("created_at", { ascending: false }),
    ]);

  if (directoratesError) throw directoratesError;
  if (reportsError) throw reportsError;

  const latestByDirectorate = new Map<string, string>();
  ((reports ?? []) as WeeklyReportRow[]).forEach((report) => {
    if (!latestByDirectorate.has(report.directorate_id)) {
      latestByDirectorate.set(report.directorate_id, report.created_at);
    }
  });

  return ((directorates ?? []) as DirectorateRow[]).map((directorate) => {
    const submittedAt = latestByDirectorate.get(directorate.id) ?? null;
    return {
      id: directorate.code,
      name: directorate.name,
      submitted: submittedAt != null,
      submittedAt,
    };
  });
}

export async function ndaForwardReportToAgo(reportId: string) {
  const { error } = await supabase.rpc("nda_forward_report_to_ago", {
    p_report_id: reportId,
  });
  if (error) throw error;
}

export async function ndaReturnReportForRevision(reportId: string, note: string) {
  const { error } = await supabase.rpc("nda_return_report_for_revision", {
    p_report_id: reportId,
    p_note: note,
  });
  if (error) throw error;
}

export async function agoForwardReportToGo(reportId: string) {
  const { error } = await supabase.rpc("ago_forward_report_to_go", {
    p_report_id: reportId,
  });
  if (error) throw error;
}

export async function agoReturnReportForRevision(reportId: string, note: string) {
  const { error } = await supabase.rpc("ago_return_report_for_revision", {
    p_report_id: reportId,
    p_note: note,
  });
  if (error) throw error;
}

export async function goApproveReport(reportId: string) {
  const { error } = await supabase.rpc("go_approve_report", {
    p_report_id: reportId,
  });
  if (error) throw error;
}

export async function goReturnReportForRevision(reportId: string, note: string) {
  const { error } = await supabase.rpc("go_return_report_for_revision", {
    p_report_id: reportId,
    p_note: note,
  });
  if (error) throw error;
}

function isExecutiveHistoryReport(report: ImsPipelineReport, role: ExecutiveHistoryRole) {
  const timeline = report.timeline ?? [];
  switch (role) {
    case "nda":
      return (
        report.stage !== "awaiting_administration" &&
        timeline.some((event) => event.action === "submitted_to_nda")
      );
    case "ago":
      return (
        report.stage !== "awaiting_ago" &&
        timeline.some((event) => event.action === "forwarded_to_ago")
      );
    case "general_overseer":
      return (
        report.stage !== "awaiting_general_overseer" &&
        timeline.some((event) => event.action === "forwarded_to_go")
      );
  }
}

function mapReport(row: SupabaseReportRow): ImsPipelineReport {
  const isState = row.author_role === "state_coordinator";
  return {
    id: row.id,
    title: row.title,
    summary: row.body,
    reportType: row.report_type,
    directorateId: isState ? (row.reference_states?.id ?? "") : (row.directorates?.code ?? ""),
    directorateName: isState ? (row.reference_states?.name ?? "State") : (row.directorates?.name ?? "Directorate"),
    unitName: isState ? "State Ministry" : (row.units?.name ?? null),
    authorRole: mapAuthorRole(row.author_role),
    authorName: "Report author",
    stage: mapStage(row.stage),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
    ...(row.returned_note
      ? {
          returnedNote: row.returned_note,
          returnedAt: row.returned_at ?? row.updated_at,
        }
      : {}),
    metrics: Object.fromEntries(
      (row.report_metrics ?? []).map((metric) => [
        metric.metric_key,
        metric.metric_value,
      ]),
    ),
    timeline: (row.report_timeline ?? [])
      .map((event) => ({
        id: event.id,
        action: mapTimelineAction(event.action),
        label: event.label,
        actorRole: event.actor_role as ImsPipelineReport["timeline"][number]["actorRole"],
        actorName: event.actor_name,
        ...(event.note ? { note: event.note } : {}),
        createdAt: event.created_at,
      }))
      .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()),
  };
}

function mapAuthorRole(role: string): ImsAuthorRole {
  if (role === "manager") return "manager";
  if (role === "director") return "director";
  if (role === "state_coordinator") return "state_coordinator";
  return "unit_head";
}

function mapStage(stage: string): ImsPipelineStage {
  switch (stage) {
    case "awaiting_ago":
      return "awaiting_ago";
    case "awaiting_general_overseer":
      return "awaiting_general_overseer";
    case "returned_for_revision":
      return "returned_for_revision";
    case "approved":
      return "approved";
    default:
      return "awaiting_administration";
  }
}

function mapTimelineAction(action: string): ImsPipelineTimelineAction {
  switch (action) {
    case "forwarded_to_ago":
      return "forwarded_to_ago";
    case "forwarded_to_go":
      return "forwarded_to_go";
    case "approved_by_go":
      return "approved_by_go";
    case "returned_for_revision":
      return "returned_for_revision";
    case "resubmitted":
      return "resubmitted";
    default:
      return "submitted_to_nda";
  }
}

function startOfWeekIso() {
  const now = new Date();
  const start = new Date(now);
  const day = start.getDay();
  const daysSinceMonday = (day + 6) % 7;
  start.setDate(start.getDate() - daysSinceMonday);
  start.setHours(0, 0, 0, 0);
  return start.toISOString();
}
