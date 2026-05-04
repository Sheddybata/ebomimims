"use client";

import DashboardLayout from "@/components/DashboardLayout";
import MetricCard from "@/components/MetricCard";
import { GraduationCap, Users, DollarSign, BookOpen } from "lucide-react";

export default function EducationModulePage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Education Module</h1>
          <p className="text-gray-600">K-12 Schools - Student data and fees collection management</p>
        </div>

        {/* Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <MetricCard
            title="Total Students"
            value="15.0K"
            icon={<GraduationCap size={32} />}
            bgColor="bg-purple-50"
          />
          <MetricCard
            title="Total Teachers"
            value="2.0K"
            icon={<Users size={32} />}
            bgColor="bg-blue-50"
          />
          <MetricCard
            title="Fees Collected"
            value="$450K"
            icon={<DollarSign size={32} />}
            bgColor="bg-green-50"
          />
          <MetricCard
            title="Active Courses"
            value="45"
            icon={<BookOpen size={32} />}
            bgColor="bg-orange-50"
          />
        </div>

        {/* School Overview */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Primary School</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">Students:</span>
                <span className="font-semibold">8,500</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Teachers:</span>
                <span className="font-semibold">1,200</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Fees Collected:</span>
                <span className="font-semibold text-green-600">$250,000</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Collection Rate:</span>
                <span className="font-semibold">85%</span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Secondary School</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">Students:</span>
                <span className="font-semibold">6,500</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Teachers:</span>
                <span className="font-semibold">800</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Fees Collected:</span>
                <span className="font-semibold text-green-600">$200,000</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Collection Rate:</span>
                <span className="font-semibold">82%</span>
              </div>
            </div>
          </div>
        </div>

        {/* Financial Integration */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Financial Integration with Tanjuriel</h3>
          <div className="space-y-3">
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-gray-700">Total Fees Revenue</span>
              <span className="font-semibold text-green-600">$450,000</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-gray-700">Transferred to Tanjuriel</span>
              <span className="font-semibold">$400,000</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-gray-700">School Operations</span>
              <span className="font-semibold">$50,000</span>
            </div>
          </div>
        </div>

        {/* Administrative Reports Placeholder */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Administrative Reports</h3>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg">
            <p className="text-gray-500">Administrative reports will be integrated with Supabase data</p>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

