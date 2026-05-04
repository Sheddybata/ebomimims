/**
 * Human-readable labels for structured report metrics (pipeline / dashboards).
 * Keep in sync with `mobile/lib/data/metric_labels.dart` (same keys).
 */
export const REPORTING_METRIC_LABELS: Record<string, string> = {
  locations_reached: "Number of locations reached (street outreach)",
  souls_won: "Total souls won",
  contacts_captured: "Total contact details captured",
  rural_stations_needs: "Rural stations — current needs (list main gaps)",
  household_visits: "Number of household visits completed",
  community_leader_engagement:
    "Community leader engagement (who reached; follow-up)",
  venue_readiness_pct: "Venue readiness % (pre-event checklist)",
  total_attendance: "Total attendance count (event / crusade)",
  sound_technical_status: "Sound & technical status (issues resolved / open)",
  converts_called_48h: "Number of converts contacted within 48 hours",
  converts_to_discipleship: "Number of converts handed to Discipleship",
  session_log:
    "Daily prayer sessions — times started/ended (week summary)",
  intercessor_attendance: "Attendance of intercessors (count or roster note)",
  new_intercessors_db: "New intercessors added to national database",
  prophetic_content: "Key prophetic words/visions (summary or transcript)",
  fast_participants: "Members participating in national fast",
  order_of_service_status:
    "Order of Service scripts — progress (drafted/approved; pending items)",
  calendar_clashes:
    "Upcoming dates across directorates — list & clash flags",
  ad_spend_total: "Ad spend total (currency)",
  social_impressions: "Social media impressions",
  social_likes: "Social media likes / engagements",
  flyers_distributed: "Flyers or materials distributed",
  last_program_attendance: "Attendance — last program",
  post_program_feedback: "Post-program feedback summary",
  ledger_balance: "Ledger balance (as of report date)",
  unposted_transactions: "Unposted transactions (references / descriptions)",
  tithes_offerings_seeds: "Tithes, offerings, seeds collected (break down totals)",
  deposit_reference: "Bank deposit confirmation / slip reference",
  quotes_received_count: "Quotes received for pending requests (count)",
  vendor_performance: "Vendor performance ratings (brief)",
  stock_levels: "Stock levels of key consumables",
  damaged_lost_assets: "Damaged or lost assets (list)",
  vip_movement_log: "VIP movement log (G.O./SRP) — schedule & deviations",
  travel_threat_assessment: "Threat assessment for upcoming travel",
  incident_count: "Incidents logged (count)",
  incident_log_detail: "Incident log detail (thefts, disruptions, arrests; refs)",
  cctv_status: "CCTV status (e.g. zones online/total)",
  pre_event_checklist_pct: "Pre-event security checklist % complete",
  event_incidents: "Program/event incidents & resolutions",
  intelligence_brief: "External security intelligence affecting ministry",
  risk_register_updates: "Risk register (new / closed items)",
  generator_run_hours: "Generator run-hours",
  fuel_consumed_liters: "Diesel / gas consumption (liters)",
  solar_battery_status: "Solar / battery / inverter status",
  repairs_completed_count: "Completed repairs (count)",
  pending_maintenance: "Pending maintenance requests",
  photo_references: "Photo evidence references (before/after)",
  work_orders_completed: "Work orders completed",
  work_orders_open: "Work orders open",
  utility_outages: "Utility outages & resolutions",
  equipment_breakdowns: "Equipment breakdowns (count)",
  spare_parts_stock: "Spare parts / critical stock status",
  attendance_count: "Total Attendance",
  offering_total: "Total Offering (Amount)",
  testimonies_summary: "Testimonies & Ministry Updates",
};

function titleCaseFromSnake(key: string): string {
  return key
    .replace(/_/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

/** Fallback template fields from `buildFallbackReportingFramework` (mobile). */
function labelForFallbackKey(key: string): string | null {
  if (key.endsWith("_primary_count")) return "Primary count / volume";
  if (key.endsWith("_secondary_metric"))
    return "Secondary metric or % (optional)";
  if (key.endsWith("_narrative"))
    return "Narrative, quality, risks, follow-up";
  return null;
}

export function metricDisplayLabel(key: string): string {
  const direct = REPORTING_METRIC_LABELS[key];
  if (direct) return direct;
  const fallback = labelForFallbackKey(key);
  if (fallback) return fallback;
  return titleCaseFromSnake(key);
}
