"use client";

import { useState, useEffect, useRef } from "react";
import DashboardLayout from "@/components/DashboardLayout";
import MetricCard from "@/components/MetricCard";
import ReconciliationModal from "@/components/ReconciliationModal";
import {
  TrendingUp,
  TrendingDown,
  PieChart,
  Plus,
  CheckCircle2,
  FileText,
  Download,
  RefreshCw,
  Search,
  Filter,
  Calendar,
  Building2,
  ArrowRight,
  Wallet,
  Receipt,
  AlertCircle,
  X,
  Eye,
  ChevronDown,
  ChevronRight,
} from "lucide-react";
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  PieChart as RechartsPieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from "recharts";

// Currency formatter
const formatNaira = (amount: number) => {
  if (amount >= 1000000) {
    return `₦${(amount / 1000000).toFixed(2)}M`;
  } else if (amount >= 1000) {
    return `₦${(amount / 1000).toFixed(1)}K`;
  }
  return `₦${amount.toLocaleString()}`;
};

// Sample data - replace with Supabase queries
const revenueData = [
  { month: "Jan", revenue: 2500000, budget: 2400000, expenses: 1400000 },
  { month: "Feb", revenue: 2800000, budget: 2500000, expenses: 1500000 },
  { month: "Mar", revenue: 3200000, budget: 2600000, expenses: 1600000 },
  { month: "Apr", revenue: 2900000, budget: 2700000, expenses: 1700000 },
  { month: "May", revenue: 3100000, budget: 2800000, expenses: 1650000 },
  { month: "Jun", revenue: 3300000, budget: 3000000, expenses: 1800000 },
];

const moduleRevenue = [
  { name: "Tanjuriel", revenue: 2500000, budget: 2300000, actual: 2500000 },
  { name: "Education", revenue: 450000, budget: 500000, actual: 450000 },
  { name: "EBOMIM", revenue: 350000, budget: 300000, actual: 350000 },
  { name: "DISEF", revenue: 200000, budget: 180000, actual: 200000 },
  { name: "Other", revenue: 50000, budget: 40000, actual: 50000 },
];

const expenseCategories = [
  { name: "Operations", amount: 800000, budget: 750000, color: "#ef4444" },
  { name: "Programs", amount: 600000, budget: 650000, color: "#f97316" },
  { name: "Administration", amount: 400000, budget: 380000, color: "#eab308" },
];

const transactions = [
  {
    id: 1,
    date: "2024-01-15",
    description: "Tuition Fees - School A",
    module: "Education",
    category: "Revenue",
    amount: 425000,
    type: "income",
    status: "completed",
    paymentMethod: "transfer",
  },
  {
    id: 2,
    date: "2024-01-14",
    description: "Medical Services - Tanjuriel",
    module: "Tanjuriel",
    category: "Revenue",
    amount: 180000,
    type: "income",
    status: "completed",
    paymentMethod: "cash",
  },
  {
    id: 3,
    date: "2024-01-14",
    description: "Operations - Office Supplies",
    module: "Administration",
    category: "Operations",
    amount: -45000,
    type: "expense",
    status: "pending",
    paymentMethod: "transfer",
  },
  {
    id: 4,
    date: "2024-01-13",
    description: "Tithes Collection - Sunday Service",
    module: "EBOMIM",
    category: "Revenue",
    amount: 125000,
    type: "income",
    status: "completed",
    paymentMethod: "cash",
  },
  {
    id: 5,
    date: "2024-01-13",
    description: "Offering - Youth Program",
    module: "EBOMIM",
    category: "Revenue",
    amount: 85000,
    type: "income",
    status: "completed",
    paymentMethod: "transfer",
  },
  {
    id: 6,
    date: "2024-01-12",
    description: "Seed - January Revival",
    module: "EBOMIM",
    category: "Revenue",
    amount: 200000,
    type: "income",
    status: "completed",
    paymentMethod: "transfer",
  },
  {
    id: 7,
    date: "2024-01-12",
    description: "Program Costs - DISEF",
    module: "DISEF",
    category: "Programs",
    amount: -120000,
    type: "expense",
    status: "pending",
    paymentMethod: "transfer",
  },
  {
    id: 8,
    date: "2024-01-11",
    description: "Staff Salaries",
    module: "Administration",
    category: "Administration",
    amount: -550000,
    type: "expense",
    status: "completed",
    paymentMethod: "transfer",
  },
];

const bankAccounts = [
  {
    id: 1,
    name: "Main Operating Account",
    bank: "Access Bank",
    accountNumber: "****1234",
    balance: 3500000,
    lastReconciled: "2024-01-10",
    status: "reconciled",
    outstandingChecks: 2,
    outstandingReceipts: 1,
  },
  {
    id: 2,
    name: "Savings Account",
    bank: "GTBank",
    accountNumber: "****5678",
    balance: 1200000,
    lastReconciled: "2024-01-08",
    status: "pending",
    outstandingChecks: 5,
    outstandingReceipts: 3,
  },
  {
    id: 3,
    name: "EBOMIM Tithes Account",
    bank: "UBA",
    accountNumber: "****9012",
    balance: 850000,
    lastReconciled: "2024-01-12",
    status: "reconciled",
    outstandingChecks: 0,
    outstandingReceipts: 2,
  },
];

// Naira Icon Component
const NairaIcon = ({ size = 24 }: { size?: number }) => (
  <div className="flex items-center justify-center font-bold text-green-600" style={{ fontSize: size }}>
    ₦
  </div>
);

export default function FinancialPage() {
  const [timePeriod, setTimePeriod] = useState<"month" | "quarter" | "year">("month");
  const [selectedModule, setSelectedModule] = useState<string>("all");
  const [selectedCategory, setSelectedCategory] = useState<string>("all");
  const [dateRange, setDateRange] = useState<{ start: string; end: string }>({
    start: "",
    end: "",
  });
  const [searchQuery, setSearchQuery] = useState("");
  const [expandedMetrics, setExpandedMetrics] = useState<Set<string>>(new Set());
  const [selectedCurrency, setSelectedCurrency] = useState("NGN");
  const [showAddTransaction, setShowAddTransaction] = useState(false);
  const [expandedAccounts, setExpandedAccounts] = useState<Set<number>>(new Set());
  const [showReconciliationModal, setShowReconciliationModal] = useState(false);
  const [selectedAccountForReconciliation, setSelectedAccountForReconciliation] = useState<typeof bankAccounts[0] | null>(null);

  const handleRefresh = () => {
    window.location.reload();
  };

  const handleExport = () => {
    alert("Export functionality will be implemented with Supabase integration");
  };

  const handleGenerateReport = () => {
    alert("Report generation will be implemented with Supabase integration");
  };

  const handleAddTransaction = () => {
    setShowAddTransaction(true);
  };

  const handleOpenReconciliation = (account?: typeof bankAccounts[0]) => {
    if (account) {
      setSelectedAccountForReconciliation(account);
    } else {
      // If no account specified, use the first account (or you can show a selector)
      setSelectedAccountForReconciliation(bankAccounts[0]);
    }
    setShowReconciliationModal(true);
  };

  const handleCloseReconciliation = () => {
    setShowReconciliationModal(false);
    setSelectedAccountForReconciliation(null);
  };

  const handleCompleteReconciliation = (reconciliationData: any) => {
    // Update the account's reconciliation status
    console.log("Reconciliation completed:", reconciliationData);
    // In a real app, this would update the database via Supabase
    alert(`Reconciliation completed for ${reconciliationData.accountId}. This will be saved to the database.`);
    // Update local state if needed
    // You can refresh the accounts data here
  };

  const toggleMetricExpand = (metric: string) => {
    const newExpanded = new Set(expandedMetrics);
    if (newExpanded.has(metric)) {
      newExpanded.delete(metric);
    } else {
      newExpanded.add(metric);
    }
    setExpandedMetrics(newExpanded);
  };

  const toggleAccountExpand = (accountId: number) => {
    const newExpanded = new Set(expandedAccounts);
    if (newExpanded.has(accountId)) {
      newExpanded.delete(accountId);
    } else {
      newExpanded.add(accountId);
    }
    setExpandedAccounts(newExpanded);
  };

  // Filter transactions
  const filteredTransactions = transactions.filter((tx) => {
    if (selectedModule !== "all" && tx.module !== selectedModule) return false;
    if (selectedCategory !== "all" && tx.category !== selectedCategory) return false;
    if (searchQuery && !tx.description.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    if (dateRange.start && tx.date < dateRange.start) return false;
    if (dateRange.end && tx.date > dateRange.end) return false;
    return true;
  });

  const totalRevenue = 3200000;
  const totalExpenses = 1800000;
  const netProfit = totalRevenue - totalExpenses;
  const profitMargin = ((netProfit / totalRevenue) * 100).toFixed(1);

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-2">Financial Command Center</h1>
            <p className="text-gray-600">Track revenue, expenses, and financial performance across all modules</p>
          </div>

          {/* Quick Actions Toolbar */}
          <div className="flex items-center gap-2 flex-wrap">
            <button
              onClick={handleAddTransaction}
              className="px-4 py-2 bg-primary-600 text-white rounded-lg text-sm font-semibold hover:bg-primary-700 flex items-center gap-2 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <Plus size={16} />
              Add Transaction
            </button>
            <button
              onClick={() => alert("Expense approval interface will open")}
              className="px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-semibold hover:bg-green-700 flex items-center gap-2 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <CheckCircle2 size={16} />
              Approve Expense
            </button>
            <button
              onClick={handleGenerateReport}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-semibold hover:bg-blue-700 flex items-center gap-2 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <FileText size={16} />
              Generate Report
            </button>
            <button
              onClick={handleExport}
              className="px-4 py-2 bg-purple-600 text-white rounded-lg text-sm font-semibold hover:bg-purple-700 flex items-center gap-2 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <Download size={16} />
              Export Data
            </button>
            <button
              onClick={handleRefresh}
              className="px-4 py-2 bg-gray-600 text-white rounded-lg text-sm font-semibold hover:bg-gray-700 flex items-center gap-2 transition-all duration-200 shadow-sm hover:shadow-md"
            >
              <RefreshCw size={16} />
              Refresh
            </button>
          </div>
        </div>

        {/* Time Period Filter */}
        <div className="flex items-center gap-2 bg-gray-100 rounded-lg p-1 w-fit">
          <button
            onClick={() => setTimePeriod("month")}
            className={`px-4 py-2 rounded-md text-sm font-semibold transition-all ${
              timePeriod === "month" ? "bg-primary-600 text-white shadow-sm" : "text-gray-700 hover:bg-gray-200"
            }`}
          >
            Month
          </button>
          <button
            onClick={() => setTimePeriod("quarter")}
            className={`px-4 py-2 rounded-md text-sm font-semibold transition-all ${
              timePeriod === "quarter" ? "bg-primary-600 text-white shadow-sm" : "text-gray-700 hover:bg-gray-200"
            }`}
          >
            Quarter
          </button>
          <button
            onClick={() => setTimePeriod("year")}
            className={`px-4 py-2 rounded-md text-sm font-semibold transition-all ${
              timePeriod === "year" ? "bg-primary-600 text-white shadow-sm" : "text-gray-700 shadow-sm"
            }`}
          >
            Year
          </button>
        </div>

        {/* Key Metrics with Drill-Down */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div
            className="bg-white rounded-lg shadow-sm p-4 hover:shadow-lg transition-all duration-300 cursor-pointer border border-transparent hover:border-gray-200 group"
            onClick={() => toggleMetricExpand("revenue")}
          >
            <div className="flex items-start justify-between gap-3">
              <div className="flex-1 min-w-0">
                <p className="text-xs text-gray-600 mb-1.5 font-medium">Total Revenue</p>
                <div className="flex items-baseline gap-2 mb-1">
                  <p className="text-2xl font-bold text-gray-800">{formatNaira(totalRevenue)}</p>
                  <div className="flex items-center gap-1 px-1.5 py-0.5 rounded-md text-xs font-semibold bg-green-50 text-green-600">
                    <TrendingUp size={12} />
                    <span>+12.5%</span>
                  </div>
                </div>
                <p className="text-xs text-gray-500">vs last period</p>
              </div>
              <div className="bg-green-50 p-2 rounded-lg opacity-70 group-hover:opacity-90 flex items-center justify-center">
                <NairaIcon size={32} />
              </div>
            </div>
            {expandedMetrics.has("revenue") && (
              <div className="mt-4 pt-4 border-t border-gray-200">
                <div className="space-y-2 text-xs">
                  {moduleRevenue.map((mod) => (
                    <div key={mod.name} className="flex justify-between items-center">
                      <span className="text-gray-600">{mod.name}:</span>
                      <span className="font-semibold text-gray-800">{formatNaira(mod.revenue)}</span>
                    </div>
                  ))}
                  <button className="w-full mt-2 text-primary-600 hover:text-primary-700 font-semibold flex items-center justify-center gap-1">
                    View Details <ArrowRight size={14} />
                  </button>
                </div>
              </div>
            )}
          </div>

          <div
            className="bg-white rounded-lg shadow-sm p-4 hover:shadow-lg transition-all duration-300 cursor-pointer border border-transparent hover:border-gray-200 group"
            onClick={() => toggleMetricExpand("expenses")}
          >
            <div className="flex items-start justify-between gap-3">
              <div className="flex-1 min-w-0">
                <p className="text-xs text-gray-600 mb-1.5 font-medium">Total Expenses</p>
                <div className="flex items-baseline gap-2 mb-1">
                  <p className="text-2xl font-bold text-gray-800">{formatNaira(totalExpenses)}</p>
                  <div className="flex items-center gap-1 px-1.5 py-0.5 rounded-md text-xs font-semibold bg-red-50 text-red-600">
                    <TrendingDown size={12} />
                    <span>-5.2%</span>
                  </div>
                </div>
                <p className="text-xs text-gray-500">vs last period</p>
              </div>
              <div className="bg-red-50 p-2 rounded-lg opacity-70 group-hover:opacity-90 flex items-center justify-center">
                <TrendingDown size={32} className="text-red-600" />
              </div>
            </div>
            {expandedMetrics.has("expenses") && (
              <div className="mt-4 pt-4 border-t border-gray-200">
                <div className="space-y-2 text-xs">
                  {expenseCategories.map((cat) => (
                    <div key={cat.name} className="flex justify-between items-center">
                      <span className="text-gray-600">{cat.name}:</span>
                      <span className="font-semibold text-gray-800">{formatNaira(cat.amount)}</span>
                    </div>
                  ))}
                  <button className="w-full mt-2 text-primary-600 hover:text-primary-700 font-semibold flex items-center justify-center gap-1">
                    View Details <ArrowRight size={14} />
                  </button>
                </div>
              </div>
            )}
          </div>

          <div
            className="bg-white rounded-lg shadow-sm p-4 hover:shadow-lg transition-all duration-300 cursor-pointer border border-transparent hover:border-gray-200 group"
            onClick={() => toggleMetricExpand("profit")}
          >
            <div className="flex items-start justify-between gap-3">
              <div className="flex-1 min-w-0">
                <p className="text-xs text-gray-600 mb-1.5 font-medium">Net Profit</p>
                <div className="flex items-baseline gap-2 mb-1">
                  <p className="text-2xl font-bold text-gray-800">{formatNaira(netProfit)}</p>
                  <div className="flex items-center gap-1 px-1.5 py-0.5 rounded-md text-xs font-semibold bg-blue-50 text-blue-600">
                    <TrendingUp size={12} />
                    <span>+18.3%</span>
                  </div>
                </div>
                <p className="text-xs text-gray-500">vs last period</p>
              </div>
              <div className="bg-blue-50 p-2 rounded-lg opacity-70 group-hover:opacity-90 flex items-center justify-center">
                <TrendingUp size={32} className="text-blue-600" />
              </div>
            </div>
            {expandedMetrics.has("profit") && (
              <div className="mt-4 pt-4 border-t border-gray-200">
                <div className="space-y-2 text-xs">
                  <div className="flex justify-between items-center">
                    <span className="text-gray-600">Margin:</span>
                    <span className="font-semibold text-gray-800">{profitMargin}%</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-600">Growth Rate:</span>
                    <span className="font-semibold text-green-600">+18.3%</span>
                  </div>
                  <button className="w-full mt-2 text-primary-600 hover:text-primary-700 font-semibold flex items-center justify-center gap-1">
                    View Details <ArrowRight size={14} />
                  </button>
                </div>
              </div>
            )}
          </div>

          <div
            className="bg-white rounded-lg shadow-sm p-4 hover:shadow-lg transition-all duration-300 cursor-pointer border border-transparent hover:border-gray-200 group"
            onClick={() => toggleMetricExpand("margin")}
          >
            <div className="flex items-start justify-between gap-3">
              <div className="flex-1 min-w-0">
                <p className="text-xs text-gray-600 mb-1.5 font-medium">Profit Margin</p>
                <div className="flex items-baseline gap-2 mb-1">
                  <p className="text-2xl font-bold text-gray-800">{profitMargin}%</p>
                </div>
                <p className="text-xs text-gray-500">Operating efficiency</p>
              </div>
              <div className="bg-purple-50 p-2 rounded-lg opacity-70 group-hover:opacity-90 flex items-center justify-center">
                <PieChart size={32} className="text-purple-600" />
              </div>
            </div>
            {expandedMetrics.has("margin") && (
              <div className="mt-4 pt-4 border-t border-gray-200">
                <div className="space-y-2 text-xs">
                  <div className="flex justify-between items-center">
                    <span className="text-gray-600">Target:</span>
                    <span className="font-semibold text-gray-800">40%</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-600">Status:</span>
                    <span className="font-semibold text-green-600">Above Target</span>
                  </div>
                  <button className="w-full mt-2 text-primary-600 hover:text-primary-700 font-semibold flex items-center justify-center gap-1">
                    View Details <ArrowRight size={14} />
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Budget vs Actual Tracking */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Budget vs Actual</h3>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={revenueData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" opacity={0.2} />
              <XAxis dataKey="month" tick={{ fontSize: 12, fill: "#6b7280" }} />
              <YAxis
                tick={{ fontSize: 12, fill: "#6b7280" }}
                tickFormatter={(value) => formatNaira(value)}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: "rgba(255, 255, 255, 0.98)",
                  border: "1px solid #e5e7eb",
                  borderRadius: "12px",
                  fontSize: "12px",
                  padding: "12px 16px",
                }}
                formatter={(value: number) => formatNaira(value)}
              />
              <Legend wrapperStyle={{ fontSize: "12px", paddingTop: "12px" }} />
              <Area
                type="monotone"
                dataKey="budget"
                stackId="1"
                stroke="#8b5cf6"
                fill="#8b5cf6"
                fillOpacity={0.3}
                name="Budget"
              />
              <Area
                type="monotone"
                dataKey="revenue"
                stackId="1"
                stroke="#10b981"
                fill="#10b981"
                fillOpacity={0.6}
                name="Actual Revenue"
              />
              <Area
                type="monotone"
                dataKey="expenses"
                stackId="2"
                stroke="#ef4444"
                fill="#ef4444"
                fillOpacity={0.4}
                name="Actual Expenses"
              />
            </AreaChart>
          </ResponsiveContainer>
          <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
            {moduleRevenue.map((mod) => {
              const variance = mod.actual - mod.budget;
              const variancePercent = ((variance / mod.budget) * 100).toFixed(1);
              const isOver = variance > 0;
              return (
                <div key={mod.name} className="p-4 bg-gray-50 rounded-lg">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-sm font-semibold text-gray-800">{mod.name}</span>
                    <span
                      className={`text-xs font-semibold px-2 py-1 rounded ${
                        isOver ? "bg-green-100 text-green-700" : "bg-red-100 text-red-700"
                      }`}
                    >
                      {isOver ? "+" : ""}
                      {variancePercent}%
                    </span>
                  </div>
                  <div className="space-y-1 text-xs">
                    <div className="flex justify-between">
                      <span className="text-gray-600">Budget:</span>
                      <span className="font-medium">{formatNaira(mod.budget)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Actual:</span>
                      <span className="font-medium">{formatNaira(mod.actual)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Variance:</span>
                      <span className={`font-semibold ${isOver ? "text-green-600" : "text-red-600"}`}>
                        {formatNaira(Math.abs(variance))}
                      </span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Financial Breakdown Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Revenue by Module</h3>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={moduleRevenue}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" opacity={0.2} />
                <XAxis dataKey="name" tick={{ fontSize: 11, fill: "#6b7280" }} />
                <YAxis tick={{ fontSize: 11, fill: "#6b7280" }} tickFormatter={(value) => formatNaira(value)} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(255, 255, 255, 0.98)",
                    border: "1px solid #e5e7eb",
                    borderRadius: "12px",
                    fontSize: "12px",
                  }}
                  formatter={(value: number) => formatNaira(value)}
                />
                <Bar dataKey="revenue" fill="#10b981" name="Revenue" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Expense Categories</h3>
            <ResponsiveContainer width="100%" height={250}>
              <RechartsPieChart>
                <Pie
                  data={expenseCategories}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="amount"
                >
                  {expenseCategories.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip formatter={(value: number) => formatNaira(value)} />
              </RechartsPieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Accounts Reconciliation */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-800">Accounts Reconciliation</h3>
            <button
              onClick={() => handleOpenReconciliation()}
              className="px-3 py-1.5 bg-primary-600 text-white rounded-lg text-sm font-semibold hover:bg-primary-700 flex items-center gap-2"
            >
              <Receipt size={14} />
              Reconcile Account
            </button>
          </div>
          <div className="space-y-4">
            {bankAccounts.map((account) => (
              <div key={account.id} className="border border-gray-200 rounded-lg p-4">
                <div
                  className="flex items-center justify-between cursor-pointer"
                  onClick={() => toggleAccountExpand(account.id)}
                >
                  <div className="flex-1">
                    <div className="flex items-center gap-3">
                      <div className={`p-2 rounded-lg ${
                        account.status === "reconciled" ? "bg-green-50" : "bg-yellow-50"
                      }`}>
                        <Wallet size={20} className={
                          account.status === "reconciled" ? "text-green-600" : "text-yellow-600"
                        } />
                      </div>
                      <div>
                        <h4 className="font-semibold text-gray-800">{account.name}</h4>
                        <p className="text-xs text-gray-600">
                          {account.bank} • {account.accountNumber}
                        </p>
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    <div className="text-right">
                      <p className="text-sm text-gray-600">Balance</p>
                      <p className="text-lg font-bold text-gray-800">{formatNaira(account.balance)}</p>
                    </div>
                    <div className={`px-3 py-1 rounded-full text-xs font-semibold ${
                      account.status === "reconciled"
                        ? "bg-green-100 text-green-700"
                        : "bg-yellow-100 text-yellow-700"
                    }`}>
                      {account.status === "reconciled" ? "Reconciled" : "Pending"}
                    </div>
                    {expandedAccounts.has(account.id) ? (
                      <ChevronDown size={20} className="text-gray-400" />
                    ) : (
                      <ChevronRight size={20} className="text-gray-400" />
                    )}
                  </div>
                </div>
                {expandedAccounts.has(account.id) && (
                  <div className="mt-4 pt-4 border-t border-gray-200 space-y-3">
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      <div>
                        <p className="text-xs text-gray-600 mb-1">Last Reconciled</p>
                        <p className="text-sm font-semibold text-gray-800">
                          {new Date(account.lastReconciled).toLocaleDateString()}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs text-gray-600 mb-1">Outstanding Checks</p>
                        <p className="text-sm font-semibold text-yellow-600">{account.outstandingChecks}</p>
                      </div>
                      <div>
                        <p className="text-xs text-gray-600 mb-1">Outstanding Receipts</p>
                        <p className="text-sm font-semibold text-blue-600">{account.outstandingReceipts}</p>
                      </div>
                      <div>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleOpenReconciliation(account);
                          }}
                          className="w-full px-3 py-2 bg-primary-600 text-white rounded-lg text-sm font-semibold hover:bg-primary-700 flex items-center justify-center gap-2"
                        >
                          <Receipt size={14} />
                          Reconcile
                        </button>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Currency Support */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Currency Management</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="p-4 bg-gray-50 rounded-lg">
              <label className="block text-sm font-semibold text-gray-700 mb-2">Primary Currency</label>
              <select
                value={selectedCurrency}
                onChange={(e) => setSelectedCurrency(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="NGN">Naira (NGN) - ₦</option>
                <option value="USD">US Dollar (USD) - $</option>
                <option value="GBP">British Pound (GBP) - £</option>
                <option value="EUR">Euro (EUR) - €</option>
              </select>
            </div>
            <div className="p-4 bg-gray-50 rounded-lg">
              <label className="block text-sm font-semibold text-gray-700 mb-2">Exchange Rate (USD)</label>
              <div className="text-2xl font-bold text-gray-800">₦1,500</div>
              <p className="text-xs text-gray-600 mt-1">Last updated: {new Date().toLocaleDateString()}</p>
            </div>
            <div className="p-4 bg-gray-50 rounded-lg">
              <label className="block text-sm font-semibold text-gray-700 mb-2">Multi-Currency Transactions</label>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Total (NGN):</span>
                  <span className="font-semibold">{formatNaira(3500000)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Total (USD):</span>
                  <span className="font-semibold">$2,333</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Interactive Filters & Transaction Table */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-4">
            <h3 className="text-lg font-semibold text-gray-800">Recent Transactions</h3>
            
            {/* Interactive Filters */}
            <div className="flex items-center gap-2 flex-wrap">
              <div className="relative">
                <Search size={16} className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search transactions..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                />
              </div>
              <select
                value={selectedModule}
                onChange={(e) => setSelectedModule(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="all">All Modules</option>
                <option value="Tanjuriel">Tanjuriel</option>
                <option value="Education">Education</option>
                <option value="EBOMIM">EBOMIM</option>
                <option value="DISEF">DISEF</option>
                <option value="Administration">Administration</option>
              </select>
              <select
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="all">All Categories</option>
                <option value="Revenue">Revenue</option>
                <option value="Operations">Operations</option>
                <option value="Programs">Programs</option>
                <option value="Administration">Administration</option>
              </select>
              <input
                type="date"
                placeholder="Start Date"
                value={dateRange.start}
                onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
              <input
                type="date"
                placeholder="End Date"
                value={dateRange.end}
                onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              />
              {(searchQuery || selectedModule !== "all" || selectedCategory !== "all" || dateRange.start || dateRange.end) && (
                <button
                  onClick={() => {
                    setSearchQuery("");
                    setSelectedModule("all");
                    setSelectedCategory("all");
                    setDateRange({ start: "", end: "" });
                  }}
                  className="px-3 py-2 bg-gray-100 text-gray-700 rounded-lg text-sm font-semibold hover:bg-gray-200 flex items-center gap-1"
                >
                  <X size={14} />
                  Clear
                </button>
              )}
            </div>
          </div>

          {/* Transaction Table */}
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Date
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Description
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Module
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Category
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Payment Method
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">
                    Amount
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
                {filteredTransactions.map((tx) => (
                  <tr key={tx.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                      {new Date(tx.date).toLocaleDateString()}
                    </td>
                    <td className="px-4 py-3 text-sm font-medium text-gray-800">{tx.description}</td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                      <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-semibold">
                        {tx.module}
                      </span>
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">{tx.category}</td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600 capitalize">
                      {tx.paymentMethod}
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap text-sm font-semibold">
                      <span className={tx.type === "income" ? "text-green-600" : "text-red-600"}>
                        {tx.type === "income" ? "+" : ""}
                        {formatNaira(tx.amount)}
                      </span>
                    </td>
                    <td className="px-4 py-3 whitespace-nowrap">
                      <span
                        className={`px-2 py-1 rounded-full text-xs font-semibold ${
                          tx.status === "completed"
                            ? "bg-green-100 text-green-700"
                            : "bg-yellow-100 text-yellow-700"
                        }`}
                      >
                        {tx.status}
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
            {filteredTransactions.length === 0 && (
              <div className="text-center py-8 text-gray-500">No transactions found matching your filters.</div>
            )}
          </div>
        </div>

        {/* Financial Trends Chart */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Financial Trends</h3>
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={revenueData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" opacity={0.2} />
              <XAxis dataKey="month" tick={{ fontSize: 12, fill: "#6b7280" }} />
              <YAxis
                tick={{ fontSize: 12, fill: "#6b7280" }}
                tickFormatter={(value) => formatNaira(value)}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: "rgba(255, 255, 255, 0.98)",
                  border: "1px solid #e5e7eb",
                  borderRadius: "12px",
                  fontSize: "12px",
                }}
                formatter={(value: number) => formatNaira(value)}
              />
              <Legend wrapperStyle={{ fontSize: "12px", paddingTop: "12px" }} />
              <Line
                type="monotone"
                dataKey="revenue"
                stroke="#10b981"
                strokeWidth={3}
                name="Revenue"
                dot={{ r: 5 }}
                activeDot={{ r: 7 }}
              />
              <Line
                type="monotone"
                dataKey="expenses"
                stroke="#ef4444"
                strokeWidth={3}
                name="Expenses"
                dot={{ r: 5 }}
                activeDot={{ r: 7 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        {/* Reconciliation Modal */}
        <ReconciliationModal
          account={selectedAccountForReconciliation}
          isOpen={showReconciliationModal}
          onClose={handleCloseReconciliation}
          onComplete={handleCompleteReconciliation}
        />
      </div>
    </DashboardLayout>
  );
}
