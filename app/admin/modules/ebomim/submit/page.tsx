"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import DashboardLayout from "@/components/DashboardLayout";
import ProtectedRoute from "@/components/ProtectedRoute";
import {
  FileText,
  DollarSign,
  Users,
  Calendar,
  Send,
  X,
  Plus,
  Trash2,
  Save,
  AlertCircle,
  CheckCircle2,
} from "lucide-react";

type TabType = "financial" | "attendance" | "reports" | "ministry";

export default function EBOMIMSubmitPage() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<TabType>("financial");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);
  const [submitError, setSubmitError] = useState("");

  // Financial Form State
  const [financialForm, setFinancialForm] = useState({
    type: "Tithes" as "Tithes" | "Offering" | "Seed",
    amount: "",
    paymentMethod: "cash" as "cash" | "transfer" | "card",
    date: new Date().toISOString().split("T")[0],
    programName: "",
    programType: "Sunday Service" as string,
    referenceNumber: "",
    collectedBy: "",
    notes: "",
  });

  // Attendance Form State
  const [attendanceForm, setAttendanceForm] = useState({
    programName: "",
    programType: "Sunday Service" as string,
    date: new Date().toISOString().split("T")[0],
    totalAttendance: "",
    maleCount: "",
    femaleCount: "",
    childrenCount: "",
    firstTimers: "",
    coordinators: "",
    location: "",
    notes: "",
  });

  // Report Form State
  const [reportForm, setReportForm] = useState({
    reportType: "coordinator_report" as "coordinator_report" | "prayer_army_report" | "intercessory_memo" | "ministry_activity",
    title: "",
    coordinatorName: "",
    date: new Date().toISOString().split("T")[0],
    priority: "medium" as "low" | "medium" | "high",
    content: "",
    prayerArmySize: "",
    activeMembers: "",
    sessionsHeld: "",
    zones: [] as string[],
    newZone: "",
    attachments: [] as string[],
  });

  // Ministry Activity Form State
  const [ministryActivity, setMinistryActivity] = useState({
    activityType: "prayer_meeting" as string,
    activityName: "",
    date: new Date().toISOString().split("T")[0],
    startTime: "",
    endTime: "",
    location: "",
    coordinator: "",
    participants: "",
    theme: "",
    speaker: "",
    testimonies: "",
    nextSteps: "",
    budget: "",
    expenses: "",
  });

  const handleFinancialSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitError("");
    setSubmitSuccess(false);

    try {
      // Simulate API call - Replace with Supabase
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      console.log("Financial Record:", financialForm);
      
      // Reset form
      setFinancialForm({
        type: "Tithes",
        amount: "",
        paymentMethod: "cash",
        date: new Date().toISOString().split("T")[0],
        programName: "",
        programType: "Sunday Service",
        referenceNumber: "",
        collectedBy: "",
        notes: "",
      });

      setSubmitSuccess(true);
      setTimeout(() => setSubmitSuccess(false), 3000);
    } catch (err) {
      setSubmitError("Failed to submit financial record. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleAttendanceSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitError("");
    setSubmitSuccess(false);

    try {
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      console.log("Attendance Record:", attendanceForm);
      
      setAttendanceForm({
        programName: "",
        programType: "Sunday Service",
        date: new Date().toISOString().split("T")[0],
        totalAttendance: "",
        maleCount: "",
        femaleCount: "",
        childrenCount: "",
        firstTimers: "",
        coordinators: "",
        location: "",
        notes: "",
      });

      setSubmitSuccess(true);
      setTimeout(() => setSubmitSuccess(false), 3000);
    } catch (err) {
      setSubmitError("Failed to submit attendance record. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleReportSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitError("");
    setSubmitSuccess(false);

    try {
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      console.log("Report:", reportForm);
      
      setReportForm({
        reportType: "coordinator_report",
        title: "",
        coordinatorName: "",
        date: new Date().toISOString().split("T")[0],
        priority: "medium",
        content: "",
        prayerArmySize: "",
        activeMembers: "",
        sessionsHeld: "",
        zones: [],
        newZone: "",
        attachments: [],
      });

      setSubmitSuccess(true);
      setTimeout(() => setSubmitSuccess(false), 3000);
    } catch (err) {
      setSubmitError("Failed to submit report. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleMinistryActivitySubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitError("");
    setSubmitSuccess(false);

    try {
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      console.log("Ministry Activity:", ministryActivity);
      
      setMinistryActivity({
        activityType: "prayer_meeting",
        activityName: "",
        date: new Date().toISOString().split("T")[0],
        startTime: "",
        endTime: "",
        location: "",
        coordinator: "",
        participants: "",
        theme: "",
        speaker: "",
        testimonies: "",
        nextSteps: "",
        budget: "",
        expenses: "",
      });

      setSubmitSuccess(true);
      setTimeout(() => setSubmitSuccess(false), 3000);
    } catch (err) {
      setSubmitError("Failed to submit ministry activity. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const addZone = () => {
    if (reportForm.newZone.trim()) {
      setReportForm({
        ...reportForm,
        zones: [...reportForm.zones, reportForm.newZone.trim()],
        newZone: "",
      });
    }
  };

  const removeZone = (index: number) => {
    setReportForm({
      ...reportForm,
      zones: reportForm.zones.filter((_, i) => i !== index),
    });
  };

  const tabs = [
    { id: "financial", label: "Financial Records", icon: <DollarSign size={18} /> },
    { id: "attendance", label: "Attendance", icon: <Users size={18} /> },
    { id: "reports", label: "Reports", icon: <FileText size={18} /> },
    { id: "ministry", label: "Ministry Activity", icon: <Calendar size={18} /> },
  ];

  return (
    <ProtectedRoute>
      <DashboardLayout>
        <div className="space-y-6">
          {/* Header */}
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <h1 className="text-2xl font-bold text-gray-800 mb-2">Submit Report - EBOMIM</h1>
              <p className="text-gray-600">Submit financial records, attendance, reports, and ministry activities</p>
            </div>
            <button
              onClick={() => router.push("/admin/modules/ebomim")}
              className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg text-sm font-semibold hover:bg-gray-200 flex items-center gap-2 transition-all"
            >
              <X size={16} />
              Cancel
            </button>
          </div>

          {/* Success/Error Messages */}
          {submitSuccess && (
            <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg flex items-center gap-2">
              <CheckCircle2 size={20} />
              <span>Report submitted successfully!</span>
            </div>
          )}
          {submitError && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg flex items-center gap-2">
              <AlertCircle size={20} />
              <span>{submitError}</span>
            </div>
          )}

          {/* Tabs */}
          <div className="border-b border-gray-200">
            <nav className="flex space-x-8 overflow-x-auto">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as TabType)}
                  className={`flex items-center gap-2 py-4 px-1 border-b-2 font-medium text-sm whitespace-nowrap transition-colors ${
                    activeTab === tab.id
                      ? "border-primary-600 text-primary-600"
                      : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                  }`}
                >
                  {tab.icon}
                  {tab.label}
                </button>
              ))}
            </nav>
          </div>

          {/* Financial Records Form */}
          {activeTab === "financial" && (
            <form onSubmit={handleFinancialSubmit} className="bg-white rounded-lg shadow-sm p-6 space-y-6">
              <div>
                <h2 className="text-lg font-semibold text-gray-800 mb-4">Financial Records</h2>
                <p className="text-sm text-gray-600 mb-6">Record tithes, offerings, and seeds</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Record Type <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={financialForm.type}
                    onChange={(e) => setFinancialForm({ ...financialForm, type: e.target.value as any })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="Tithes">Tithes</option>
                    <option value="Offering">Offering</option>
                    <option value="Seed">Seed</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Amount (₦) <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    value={financialForm.amount}
                    onChange={(e) => setFinancialForm({ ...financialForm, amount: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0.00"
                    required
                    min="0"
                    step="0.01"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Payment Method <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={financialForm.paymentMethod}
                    onChange={(e) => setFinancialForm({ ...financialForm, paymentMethod: e.target.value as any })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="cash">Cash</option>
                    <option value="transfer">Bank Transfer</option>
                    <option value="card">Card Payment</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Date <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="date"
                    value={financialForm.date}
                    onChange={(e) => setFinancialForm({ ...financialForm, date: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Program Type <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={financialForm.programType}
                    onChange={(e) => setFinancialForm({ ...financialForm, programType: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="Sunday Service">Sunday Service</option>
                    <option value="Midweek Service">Midweek Service</option>
                    <option value="Prayer Meeting">Prayer Meeting</option>
                    <option value="Revival Service">Revival Service</option>
                    <option value="Youth Program">Youth Program</option>
                    <option value="Women's Meeting">Women's Meeting</option>
                    <option value="Men's Meeting">Men's Meeting</option>
                    <option value="Special Program">Special Program</option>
                    <option value="Other">Other</option>
                  </select>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Program Name <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={financialForm.programName}
                    onChange={(e) => setFinancialForm({ ...financialForm, programName: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="e.g., Sunday Service - January 15, 2024"
                    required
                  />
                </div>

                {financialForm.paymentMethod !== "cash" && (
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Reference Number / Transaction ID
                    </label>
                    <input
                      type="text"
                      value={financialForm.referenceNumber}
                      onChange={(e) => setFinancialForm({ ...financialForm, referenceNumber: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                      placeholder="Enter transaction reference"
                    />
                  </div>
                )}

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Collected By <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={financialForm.collectedBy}
                    onChange={(e) => setFinancialForm({ ...financialForm, collectedBy: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter your name or coordinator name"
                    required
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">Additional Notes</label>
                  <textarea
                    value={financialForm.notes}
                    onChange={(e) => setFinancialForm({ ...financialForm, notes: e.target.value })}
                    rows={3}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Any additional information or notes..."
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-4 pt-4 border-t">
                <button
                  type="button"
                  onClick={() => router.push("/admin/modules/ebomim")}
                  className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 transition-colors"
                >
                  {isSubmitting ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white"></div>
                      Submitting...
                    </>
                  ) : (
                    <>
                      <Send size={16} />
                      Submit Record
                    </>
                  )}
                </button>
              </div>
            </form>
          )}

          {/* Attendance Form */}
          {activeTab === "attendance" && (
            <form onSubmit={handleAttendanceSubmit} className="bg-white rounded-lg shadow-sm p-6 space-y-6">
              <div>
                <h2 className="text-lg font-semibold text-gray-800 mb-4">Attendance Records</h2>
                <p className="text-sm text-gray-600 mb-6">Record attendance for programs and meetings</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Program Type <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={attendanceForm.programType}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, programType: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="Sunday Service">Sunday Service</option>
                    <option value="Midweek Service">Midweek Service</option>
                    <option value="Prayer Meeting">Prayer Meeting</option>
                    <option value="Revival Service">Revival Service</option>
                    <option value="Youth Program">Youth Program</option>
                    <option value="Women's Meeting">Women's Meeting</option>
                    <option value="Men's Meeting">Men's Meeting</option>
                    <option value="Special Program">Special Program</option>
                    <option value="Other">Other</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Date <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="date"
                    value={attendanceForm.date}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, date: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Program Name <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={attendanceForm.programName}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, programName: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="e.g., Sunday Service - January 15, 2024"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Total Attendance <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="number"
                    value={attendanceForm.totalAttendance}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, totalAttendance: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0"
                    required
                    min="0"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
                  <input
                    type="text"
                    value={attendanceForm.location}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, location: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="e.g., Main Auditorium, Lagos"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Male Count</label>
                  <input
                    type="number"
                    value={attendanceForm.maleCount}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, maleCount: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0"
                    min="0"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Female Count</label>
                  <input
                    type="number"
                    value={attendanceForm.femaleCount}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, femaleCount: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0"
                    min="0"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Children Count</label>
                  <input
                    type="number"
                    value={attendanceForm.childrenCount}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, childrenCount: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0"
                    min="0"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">First Timers</label>
                  <input
                    type="number"
                    value={attendanceForm.firstTimers}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, firstTimers: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0"
                    min="0"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Number of Coordinators</label>
                  <input
                    type="number"
                    value={attendanceForm.coordinators}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, coordinators: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0"
                    min="0"
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">Additional Notes</label>
                  <textarea
                    value={attendanceForm.notes}
                    onChange={(e) => setAttendanceForm({ ...attendanceForm, notes: e.target.value })}
                    rows={3}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Any additional information about the attendance..."
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-4 pt-4 border-t">
                <button
                  type="button"
                  onClick={() => router.push("/admin/modules/ebomim")}
                  className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 transition-colors"
                >
                  {isSubmitting ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white"></div>
                      Submitting...
                    </>
                  ) : (
                    <>
                      <Send size={16} />
                      Submit Attendance
                    </>
                  )}
                </button>
              </div>
            </form>
          )}

          {/* Reports Form */}
          {activeTab === "reports" && (
            <form onSubmit={handleReportSubmit} className="bg-white rounded-lg shadow-sm p-6 space-y-6">
              <div>
                <h2 className="text-lg font-semibold text-gray-800 mb-4">Coordinator Reports</h2>
                <p className="text-sm text-gray-600 mb-6">Submit coordinator reports, prayer army updates, and intercessory memos</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Report Type <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={reportForm.reportType}
                    onChange={(e) => setReportForm({ ...reportForm, reportType: e.target.value as any })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="coordinator_report">Coordinator Report</option>
                    <option value="prayer_army_report">Prayer Army Report</option>
                    <option value="intercessory_memo">Intercessory Memo</option>
                    <option value="ministry_activity">Ministry Activity Report</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Priority <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={reportForm.priority}
                    onChange={(e) => setReportForm({ ...reportForm, priority: e.target.value as any })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                  </select>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Report Title <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={reportForm.title}
                    onChange={(e) => setReportForm({ ...reportForm, title: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter report title"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Coordinator Name <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={reportForm.coordinatorName}
                    onChange={(e) => setReportForm({ ...reportForm, coordinatorName: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter your name"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Date <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="date"
                    value={reportForm.date}
                    onChange={(e) => setReportForm({ ...reportForm, date: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>

                {(reportForm.reportType === "prayer_army_report" || reportForm.reportType === "coordinator_report") && (
                  <>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Prayer Army Size</label>
                      <input
                        type="number"
                        value={reportForm.prayerArmySize}
                        onChange={(e) => setReportForm({ ...reportForm, prayerArmySize: e.target.value })}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                        placeholder="0"
                        min="0"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Active Members</label>
                      <input
                        type="number"
                        value={reportForm.activeMembers}
                        onChange={(e) => setReportForm({ ...reportForm, activeMembers: e.target.value })}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                        placeholder="0"
                        min="0"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">Sessions Held (This Period)</label>
                      <input
                        type="number"
                        value={reportForm.sessionsHeld}
                        onChange={(e) => setReportForm({ ...reportForm, sessionsHeld: e.target.value })}
                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                        placeholder="0"
                        min="0"
                      />
                    </div>

                    <div className="md:col-span-2">
                      <label className="block text-sm font-medium text-gray-700 mb-2">Zones Covered</label>
                      <div className="flex gap-2 mb-2">
                        <input
                          type="text"
                          value={reportForm.newZone}
                          onChange={(e) => setReportForm({ ...reportForm, newZone: e.target.value })}
                          onKeyPress={(e) => e.key === "Enter" && (e.preventDefault(), addZone())}
                          className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                          placeholder="Enter zone name and press Enter or click Add"
                        />
                        <button
                          type="button"
                          onClick={addZone}
                          className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 flex items-center gap-2"
                        >
                          <Plus size={16} />
                          Add
                        </button>
                      </div>
                      {reportForm.zones.length > 0 && (
                        <div className="flex flex-wrap gap-2">
                          {reportForm.zones.map((zone, index) => (
                            <span
                              key={index}
                              className="inline-flex items-center gap-2 px-3 py-1 bg-primary-100 text-primary-700 rounded-full text-sm"
                            >
                              {zone}
                              <button
                                type="button"
                                onClick={() => removeZone(index)}
                                className="hover:text-primary-900"
                              >
                                <X size={14} />
                              </button>
                            </span>
                          ))}
                        </div>
                      )}
                    </div>
                  </>
                )}

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Report Content <span className="text-red-500">*</span>
                  </label>
                  <textarea
                    value={reportForm.content}
                    onChange={(e) => setReportForm({ ...reportForm, content: e.target.value })}
                    rows={8}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter detailed report content..."
                    required
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-4 pt-4 border-t">
                <button
                  type="button"
                  onClick={() => router.push("/admin/modules/ebomim")}
                  className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 transition-colors"
                >
                  {isSubmitting ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white"></div>
                      Submitting...
                    </>
                  ) : (
                    <>
                      <Send size={16} />
                      Submit Report
                    </>
                  )}
                </button>
              </div>
            </form>
          )}

          {/* Ministry Activity Form */}
          {activeTab === "ministry" && (
            <form onSubmit={handleMinistryActivitySubmit} className="bg-white rounded-lg shadow-sm p-6 space-y-6">
              <div>
                <h2 className="text-lg font-semibold text-gray-800 mb-4">Ministry Activity</h2>
                <p className="text-sm text-gray-600 mb-6">Record ministry activities, programs, and events</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Activity Type <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={ministryActivity.activityType}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, activityType: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  >
                    <option value="prayer_meeting">Prayer Meeting</option>
                    <option value="bible_study">Bible Study</option>
                    <option value="revival">Revival Service</option>
                    <option value="outreach">Outreach Program</option>
                    <option value="training">Training Program</option>
                    <option value="conference">Conference</option>
                    <option value="crusade">Crusade</option>
                    <option value="other">Other</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Date <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="date"
                    value={ministryActivity.date}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, date: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    required
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Activity Name <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    value={ministryActivity.activityName}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, activityName: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter activity name"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Start Time</label>
                  <input
                    type="time"
                    value={ministryActivity.startTime}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, startTime: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">End Time</label>
                  <input
                    type="time"
                    value={ministryActivity.endTime}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, endTime: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
                  <input
                    type="text"
                    value={ministryActivity.location}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, location: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter location"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Coordinator</label>
                  <input
                    type="text"
                    value={ministryActivity.coordinator}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, coordinator: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter coordinator name"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Number of Participants</label>
                  <input
                    type="number"
                    value={ministryActivity.participants}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, participants: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0"
                    min="0"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Speaker/Teacher</label>
                  <input
                    type="text"
                    value={ministryActivity.speaker}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, speaker: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter speaker/teacher name"
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">Theme/Topic</label>
                  <input
                    type="text"
                    value={ministryActivity.theme}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, theme: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Enter theme or topic"
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">Testimonies & Highlights</label>
                  <textarea
                    value={ministryActivity.testimonies}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, testimonies: e.target.value })}
                    rows={4}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Share testimonies and highlights from the activity..."
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-2">Next Steps & Follow-up</label>
                  <textarea
                    value={ministryActivity.nextSteps}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, nextSteps: e.target.value })}
                    rows={3}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="Outline next steps and follow-up actions..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Budget (₦)</label>
                  <input
                    type="number"
                    value={ministryActivity.budget}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, budget: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0.00"
                    min="0"
                    step="0.01"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Actual Expenses (₦)</label>
                  <input
                    type="number"
                    value={ministryActivity.expenses}
                    onChange={(e) => setMinistryActivity({ ...ministryActivity, expenses: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                    placeholder="0.00"
                    min="0"
                    step="0.01"
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-4 pt-4 border-t">
                <button
                  type="button"
                  onClick={() => router.push("/admin/modules/ebomim")}
                  className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 transition-colors"
                >
                  {isSubmitting ? (
                    <>
                      <div className="animate-spin rounded-full h-4 w-4 border-t-2 border-b-2 border-white"></div>
                      Submitting...
                    </>
                  ) : (
                    <>
                      <Send size={16} />
                      Submit Activity
                    </>
                  )}
                </button>
              </div>
            </form>
          )}
        </div>
      </DashboardLayout>
    </ProtectedRoute>
  );
}

