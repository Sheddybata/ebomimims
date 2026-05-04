"use client";

import { useState } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import ReportsTable from "@/components/ReportsTable";
import { Report } from "@/types/reports";

const allReports: Report[] = [
  {
    id: "1",
    module: "IBBN",
    title: "Membership Growth Report - Q1 2024",
    description: "Comprehensive report on membership growth across all Wards, LGAs, and States",
    submittedBy: "National Coordinator",
    submittedAt: "2024-01-15",
    status: "pending",
    priority: "high",
    data: {
      type: "membership_growth",
      wards: 150,
      lgas: 45,
      states: 12,
      membershipCount: 50000,
    },
  },
  {
    id: "2",
    module: "Tanjuriel",
    title: "ROI Analysis - Medical Unit",
    description: "Quarterly ROI and cash flow analysis for the Medical unit",
    submittedBy: "Business Manager",
    submittedAt: "2024-01-14",
    status: "pending",
    priority: "high",
    data: {
      unit: "medical",
      roi: 15.5,
      cashFlow: 250000,
    },
  },
  {
    id: "3",
    module: "DISEF",
    title: "Beneficiary Database Update",
    description: "Updated beneficiary records with geographic coverage mapping",
    submittedBy: "Foundation Director",
    submittedAt: "2024-01-13",
    status: "approved",
    priority: "medium",
    data: {
      type: "beneficiary_update",
      beneficiaryCount: 5000,
      location: "Lagos State",
    },
  },
  {
    id: "4",
    module: "EBOMIM",
    title: "Intercessory Focus Memo - January",
    description: "Strategic prayer focus for the month of January",
    submittedBy: "Ministry Coordinator",
    submittedAt: "2024-01-12",
    status: "pending",
    priority: "medium",
    data: {
      type: "intercessory_memo",
      memoContent: "Focus on national unity and economic stability",
    },
  },
  {
    id: "5",
    module: "Education",
    title: "Student Fees Collection Report",
    description: "Monthly fees collection report for both K-12 schools",
    submittedBy: "School Administrator",
    submittedAt: "2024-01-11",
    status: "pending",
    priority: "low",
    data: {
      type: "fees_collection",
      feesAmount: 450000,
      studentCount: 1500,
    },
  },
];

export default function ReportsPage() {
  const [reports, setReports] = useState<Report[]>(allReports);
  const [filter, setFilter] = useState<"all" | "pending" | "approved" | "rejected">("all");
  const [moduleFilter, setModuleFilter] = useState<string>("all");

  const filteredReports = reports.filter((report) => {
    const statusMatch = filter === "all" || report.status === filter;
    const moduleMatch = moduleFilter === "all" || report.module === moduleFilter;
    return statusMatch && moduleMatch;
  });

  const handleApprove = (id: string) => {
    setReports((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: "approved" as const } : r))
    );
  };

  const handleReject = (id: string) => {
    setReports((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: "rejected" as const } : r))
    );
  };

  const handleView = (id: string) => {
    const report = reports.find((r) => r.id === id);
    if (report) {
      alert(`Viewing report: ${report.title}\n\nDescription: ${report.description || "N/A"}\nModule: ${report.module}\nStatus: ${report.status}`);
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Reports Management</h1>
          <p className="text-gray-600">Review and approve reports from all modules</p>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm p-4 flex flex-wrap gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select
              value={filter}
              onChange={(e) => setFilter(e.target.value as any)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="all">All</option>
              <option value="pending">Pending</option>
              <option value="approved">Approved</option>
              <option value="rejected">Rejected</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Module</label>
            <select
              value={moduleFilter}
              onChange={(e) => setModuleFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="all">All Modules</option>
              <option value="IBBN">IBBN</option>
              <option value="Tanjuriel">Tanjuriel</option>
              <option value="DISEF">DISEF</option>
              <option value="EBOMIM">EBOMIM</option>
              <option value="Education">Education</option>
            </select>
          </div>
        </div>

        {/* Reports Table */}
        <ReportsTable
          reports={filteredReports}
          onApprove={handleApprove}
          onReject={handleReject}
          onView={handleView}
        />
      </div>
    </DashboardLayout>
  );
}

