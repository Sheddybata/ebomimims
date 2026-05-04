/**
 * Demo NDA "compliance" view: which directorates have filed a weekly line report (mock).
 * Not wired to real submissions — toggles persist in localStorage for demos.
 */

export interface ComplianceDirectorateRow {
  id: string;
  name: string;
}

/** Directorates that have a defined reporting framework in the mobile app (+ others for visibility). */
export const COMPLIANCE_DIRECTORATE_ROWS: ComplianceDirectorateRow[] = [
  { id: "missions_evangelism", name: "Directorate of Missions and Evangelism" },
  { id: "intercession_prayer", name: "Directorate of Intercession and Prayer (under National Coordinator)" },
  { id: "programs_publicity", name: "Directorate of Programs and Publicity" },
  { id: "finance_treasury_supply", name: "Directorate of Finance, Treasury, Purchase & Supply" },
  { id: "security_defense", name: "Directorate of Security and Defense" },
  { id: "electricity_infrastructure_facilities", name: "Directorate of Electricity, Infrastructure & Facility Maintenance" },
  { id: "administration_national_intl", name: "Directorate of Administration (National & International)" },
  { id: "discipleship_mentorship", name: "Directorate of Discipleship and Mentorship" },
  { id: "education_schools", name: "Directorate of Education and Schools" },
];

const STORAGE_KEY = "ims_weekly_compliance_overrides_v1";

type Overrides = Record<string, { submitted: boolean; at?: string }>;

function defaultSubmitted(id: string): boolean {
  // Demo pattern: some submitted, some missing
  const missing = new Set([
    "education_schools",
    "discipleship_mentorship",
    "administration_national_intl",
  ]);
  return !missing.has(id);
}

function loadOverrides(): Overrides {
  if (typeof window === "undefined") return {};
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return {};
    const p = JSON.parse(raw) as Overrides;
    return p && typeof p === "object" ? p : {};
  } catch {
    return {};
  }
}

function saveOverrides(o: Overrides) {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(o));
}

export interface ComplianceRowState extends ComplianceDirectorateRow {
  submitted: boolean;
  submittedAt: string | null;
}

export function getComplianceRows(): ComplianceRowState[] {
  const o = loadOverrides();
  return COMPLIANCE_DIRECTORATE_ROWS.map((r) => {
    const hit = o[r.id];
    const submitted = hit ? hit.submitted : defaultSubmitted(r.id);
    const submittedAt = submitted ? hit?.at ?? null : null;
    return { ...r, submitted, submittedAt };
  });
}

export function toggleComplianceSubmitted(id: string): ComplianceRowState[] {
  const rows = getComplianceRows();
  const current = rows.find((x) => x.id === id);
  const nextVal = !(current?.submitted ?? false);
  const o = loadOverrides();
  o[id] = {
    submitted: nextVal,
    at: nextVal ? new Date().toISOString() : undefined,
  };
  saveOverrides(o);
  return getComplianceRows();
}

export function resetComplianceDemo(): void {
  if (typeof window === "undefined") return;
  localStorage.removeItem(STORAGE_KEY);
}
