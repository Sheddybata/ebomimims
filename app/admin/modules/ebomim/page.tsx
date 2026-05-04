"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import MetricCard from "@/components/MetricCard";
import { Users, FileText, Heart, Calendar, Plus, Search, Filter, Eye, Download } from "lucide-react";

// Currency formatter
const formatNaira = (amount: number) => {
  if (amount >= 1000000) {
    return `₦${(amount / 1000000).toFixed(2)}M`;
  } else if (amount >= 1000) {
    return `₦${(amount / 1000).toFixed(1)}K`;
  }
  return `₦${amount.toLocaleString()}`;
};

// Sample tithes, offering, and seed data
const financialRecords = [
  {
    id: 1,
    type: "Tithes",
    amount: 125000,
    paymentMethod: "cash",
    date: "2024-01-15",
    programName: "Sunday Service - January 15",
    collectedBy: "Lagos Coordinator",
    status: "recorded",
  },
  {
    id: 2,
    type: "Offering",
    amount: 85000,
    paymentMethod: "transfer",
    date: "2024-01-14",
    programName: "Youth Program - Evening Service",
    collectedBy: "Abuja Coordinator",
    status: "recorded",
  },
  {
    id: 3,
    type: "Seed",
    amount: 200000,
    paymentMethod: "transfer",
    date: "2024-01-13",
    programName: "January Revival - Breakthrough Night",
    collectedBy: "Kano Coordinator",
    status: "recorded",
  },
  {
    id: 4,
    type: "Tithes",
    amount: 150000,
    paymentMethod: "cash",
    date: "2024-01-12",
    programName: "Sunday Service - January 12",
    collectedBy: "Lagos Coordinator",
    status: "recorded",
  },
  {
    id: 5,
    type: "Offering",
    amount: 95000,
    paymentMethod: "transfer",
    date: "2024-01-11",
    programName: "Midweek Service - Word & Prayer",
    collectedBy: "Rivers Coordinator",
    status: "pending",
  },
  {
    id: 6,
    type: "Seed",
    amount: 175000,
    paymentMethod: "cash",
    date: "2024-01-10",
    programName: "New Year Thanksgiving Service",
    collectedBy: "Oyo Coordinator",
    status: "recorded",
  },
  {
    id: 7,
    type: "Tithes",
    amount: 110000,
    paymentMethod: "transfer",
    date: "2024-01-08",
    programName: "Sunday Service - January 8",
    collectedBy: "Lagos Coordinator",
    status: "recorded",
  },
  {
    id: 8,
    type: "Offering",
    amount: 75000,
    paymentMethod: "cash",
    date: "2024-01-07",
    programName: "Prayer Meeting - Intercessory",
    collectedBy: "Abuja Coordinator",
    status: "recorded",
  },
];

export default function EBOMIMModulePage() {
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState("");
  const [filterType, setFilterType] = useState<string>("all");
  const [filterPaymentMethod, setFilterPaymentMethod] = useState<string>("all");
  const [filterStatus, setFilterStatus] = useState<string>("all");

  // Calculate totals
  const totalTithes = financialRecords
    .filter((r) => r.type === "Tithes" && r.status === "recorded")
    .reduce((sum, r) => sum + r.amount, 0);
  const totalOffering = financialRecords
    .filter((r) => r.type === "Offering" && r.status === "recorded")
    .reduce((sum, r) => sum + r.amount, 0);
  const totalSeed = financialRecords
    .filter((r) => r.type === "Seed" && r.status === "recorded")
    .reduce((sum, r) => sum + r.amount, 0);
  const totalRevenue = totalTithes + totalOffering + totalSeed;

  // Filter records
  const filteredRecords = financialRecords.filter((record) => {
    if (searchQuery && !record.programName.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    if (filterType !== "all" && record.type !== filterType) return false;
    if (filterPaymentMethod !== "all" && record.paymentMethod !== filterPaymentMethod) return false;
    if (filterStatus !== "all" && record.status !== filterStatus) return false;
    return true;
  });

  const handleAddRecord = () => {
    router.push("/admin/modules/ebomim/submit");
  };

  const handleExport = () => {
    alert("Export functionality will be implemented with Supabase integration");
  };

  return (
    <ProtectedRoute requireAdmin={true}>
      <DashboardLayout>
      <div className="space-y-6">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-2">EBOMIM Module</h1>
            <p className="text-gray-600">Ministry/Spiritual - Coordinator and prayer army management</p>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={handleAddRecord}
              className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm font-semibold hover:bg-primary-700 flex items-center gap-2 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <Plus size={16} />
              Add Record
            </button>
            <button
              onClick={handleExport}
              className="px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-semibold hover:bg-green-700 flex items-center gap-2 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <Download size={16} />
              Export
            </button>
          </div>
        </div>

        {/* Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <MetricCard
            title="Total Tithes"
            value={formatNaira(totalTithes)}
            icon={<div className="text-2xl font-bold text-green-600">₦</div>}
            bgColor="bg-green-50"
            trend="up"
            trendValue="+8.2%"
          />
          <MetricCard
            title="Total Offering"
            value={formatNaira(totalOffering)}
            icon={<div className="text-2xl font-bold text-blue-600">₦</div>}
            bgColor="bg-blue-50"
            trend="up"
            trendValue="+12.5%"
          />
          <MetricCard
            title="Total Seed"
            value={formatNaira(totalSeed)}
            icon={<div className="text-2xl font-bold text-purple-600">₦</div>}
            bgColor="bg-purple-50"
            trend="up"
            trendValue="+15.3%"
          />
          <MetricCard
            title="Total Revenue"
            value={formatNaira(totalRevenue)}
            icon={<div className="text-2xl font-bold text-primary-600">₦</div>}
            bgColor="bg-primary-50"
            trend="up"
            trendValue="+11.2%"
          />
        </div>

        {/* Additional Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <MetricCard
            title="Total Coordinators"
            value="120"
            icon={<Users size={32} />}
            bgColor="bg-blue-50"
          />
          <MetricCard
            title="Prayer Army"
            value="5.0K"
            icon={<Heart size={32} />}
            bgColor="bg-purple-50"
          />
          <MetricCard
            title="Active Reports"
            value="45"
            icon={<FileText size={32} />}
            bgColor="bg-green-50"
          />
        </div>

        {/* Tithes, Offering & Seed Tracking */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-4">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-1">Tithes, Offering & Seed Tracking</h3>
              <p className="text-sm text-gray-600">Track all financial contributions with date and program details</p>
            </div>
          </div>

          {/* Filters */}
          <div className="flex items-center gap-2 flex-wrap mb-4">
            <div className="relative flex-1 min-w-[200px]">
              <Search size={16} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search by program name..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
            </div>
            <select
              value={filterType}
              onChange={(e) => setFilterType(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="all">All Types</option>
              <option value="Tithes">Tithes</option>
              <option value="Offering">Offering</option>
              <option value="Seed">Seed</option>
            </select>
            <select
              value={filterPaymentMethod}
              onChange={(e) => setFilterPaymentMethod(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="all">All Methods</option>
              <option value="cash">Cash</option>
              <option value="transfer">Transfer</option>
            </select>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="all">All Status</option>
              <option value="recorded">Recorded</option>
              <option value="pending">Pending</option>
            </select>
          </div>

          {/* Records Table */}
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Date
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Type
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Program Name
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Payment Method
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Amount
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Collected By
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredRecords.map((record) => (
                  <tr key={record.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                      {new Date(record.date).toLocaleDateString()}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <span
                        className={`px-2 py-1 rounded-full text-xs font-semibold ${
                          record.type === "Tithes"
                            ? "bg-green-100 text-green-700"
                            : record.type === "Offering"
                            ? "bg-blue-100 text-blue-700"
                            : "bg-purple-100 text-purple-700"
                        }`}
                      >
                        {record.type}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm font-medium text-gray-800 max-w-xs truncate">
                      {record.programName}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600 capitalize">
                      {record.paymentMethod}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm font-semibold text-green-600">
                      {formatNaira(record.amount)}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">{record.collectedBy}</td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <span
                        className={`px-2 py-1 rounded-full text-xs font-semibold ${
                          record.status === "recorded"
                            ? "bg-green-100 text-green-700"
                            : "bg-yellow-100 text-yellow-700"
                        }`}
                      >
                        {record.status}
                      </span>
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm">
                      <button className="text-primary-600 hover:text-primary-700 flex items-center gap-1">
                        <Eye size={14} />
                        View
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {filteredRecords.length === 0 && (
              <div className="text-center py-8 text-gray-500">No records found matching your filters.</div>
            )}
          </div>

          {/* Summary Stats */}
          <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4 pt-6 border-t border-gray-200">
            <div className="p-4 bg-green-50 rounded-lg">
              <p className="text-xs text-gray-600 mb-1">Total Tithes (This Period)</p>
              <p className="text-xl font-bold text-green-600">{formatNaira(totalTithes)}</p>
              <p className="text-xs text-gray-500 mt-1">
                {financialRecords.filter((r) => r.type === "Tithes").length} records
              </p>
            </div>
            <div className="p-4 bg-blue-50 rounded-lg">
              <p className="text-xs text-gray-600 mb-1">Total Offering (This Period)</p>
              <p className="text-xl font-bold text-blue-600">{formatNaira(totalOffering)}</p>
              <p className="text-xs text-gray-500 mt-1">
                {financialRecords.filter((r) => r.type === "Offering").length} records
              </p>
            </div>
            <div className="p-4 bg-purple-50 rounded-lg">
              <p className="text-xs text-gray-600 mb-1">Total Seed (This Period)</p>
              <p className="text-xl font-bold text-purple-600">{formatNaira(totalSeed)}</p>
              <p className="text-xs text-gray-500 mt-1">
                {financialRecords.filter((r) => r.type === "Seed").length} records
              </p>
            </div>
          </div>
        </div>

        {/* Coordinator Reports */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Recent Coordinator Reports</h3>
            <div className="space-y-4">
              <div className="p-4 bg-gray-50 rounded-lg">
                <div className="flex justify-between items-start mb-2">
                  <p className="font-medium text-gray-800">Lagos State Coordinator</p>
                  <span className="text-xs text-gray-500">2 days ago</span>
                </div>
                <p className="text-sm text-gray-600">
                  Monthly ministry activities report covering 15 zones with active prayer meetings.
                </p>
              </div>
              <div className="p-4 bg-gray-50 rounded-lg">
                <div className="flex justify-between items-start mb-2">
                  <p className="font-medium text-gray-800">Abuja FCT Coordinator</p>
                  <span className="text-xs text-gray-500">3 days ago</span>
                </div>
                <p className="text-sm text-gray-600">
                  Intercessory prayer sessions increased by 20% this month.
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Intercessory Focus Memos</h3>
            <div className="space-y-4">
              <div className="p-4 bg-primary-50 rounded-lg border-l-4 border-primary-600">
                <p className="font-medium text-gray-800 mb-2">January 2024 Focus</p>
                <p className="text-sm text-gray-600">
                  Focus on national unity, economic stability, and youth empowerment. All prayer armies to intensify
                  intercession.
                </p>
                <p className="text-xs text-gray-400 mt-2">Distributed to all coordinators</p>
              </div>
              <div className="p-4 bg-primary-50 rounded-lg border-l-4 border-primary-600">
                <p className="font-medium text-gray-800 mb-2">December 2023 Focus</p>
                <p className="text-sm text-gray-600">
                  End of year thanksgiving and preparation for new year initiatives.
                </p>
                <p className="text-xs text-gray-400 mt-2">Distributed to all coordinators</p>
              </div>
            </div>
          </div>
        </div>

        {/* Prayer Army Distribution */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Prayer Army Distribution by Region</h3>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg">
            <p className="text-gray-500">Chart will be integrated with Supabase data</p>
          </div>
        </div>
      </div>
    </DashboardLayout>
    </ProtectedRoute>
  );
}
