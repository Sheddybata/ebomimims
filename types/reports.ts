export type ReportStatus = "pending" | "approved" | "rejected";
export type Priority = "low" | "medium" | "high";

export interface Report {
  id: string;
  module: Module;
  title: string;
  description?: string;
  submittedBy: string;
  submittedAt: string;
  status: ReportStatus;
  priority: Priority;
  data?: Record<string, any>;
}

export type Module = "IBBN" | "Tanjuriel" | "DISEF" | "EBOMIM" | "Education";

export interface IBBNReport extends Report {
  module: "IBBN";
  data: {
    type: "membership_growth" | "intelligence_feed" | "strategic_directive";
    wards?: number;
    lgas?: number;
    states?: number;
    membershipCount?: number;
    content?: string;
  };
}

export interface TanjurielReport extends Report {
  module: "Tanjuriel";
  data: {
    unit: "medical" | "agro_alliance" | "transport" | "hospitality";
    roi?: number;
    cashFlow?: number;
    riskMitigation?: string;
  };
}

export interface DISEFReport extends Report {
  module: "DISEF";
  data: {
    type: "beneficiary_update" | "coverage_mapping" | "funding_utilization" | "impact_snapshot";
    beneficiaryCount?: number;
    location?: string;
    fundingAmount?: number;
    impactMetrics?: Record<string, number>;
  };
}

export interface EBOMIMReport extends Report {
  module: "EBOMIM";
  data: {
    type: "coordinator_report" | "prayer_army_report" | "intercessory_memo";
    coordinatorName?: string;
    prayerArmySize?: number;
    memoContent?: string;
  };
}

export interface EducationReport extends Report {
  module: "Education";
  data: {
    type: "student_data" | "fees_collection" | "administrative";
    studentCount?: number;
    feesAmount?: number;
    schoolId?: string;
  };
}

