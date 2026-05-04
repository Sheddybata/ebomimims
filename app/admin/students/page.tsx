"use client";

import DashboardLayout from "@/components/DashboardLayout";
import MetricCard from "@/components/MetricCard";
import { GraduationCap, Users, UserCheck, BookOpen } from "lucide-react";

export default function StudentsPage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Students Management</h1>
          <p className="text-gray-600">Manage student data, enrollment, and academic records</p>
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
            title="New Enrollments"
            value="250"
            icon={<Users size={32} />}
            bgColor="bg-blue-50"
          />
          <MetricCard
            title="Active Students"
            value="14.5K"
            icon={<UserCheck size={32} />}
            bgColor="bg-green-50"
          />
          <MetricCard
            title="Courses Enrolled"
            value="45"
            icon={<BookOpen size={32} />}
            bgColor="bg-orange-50"
          />
        </div>

        {/* Student Table Placeholder */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-gray-800">Student Records</h3>
            <button className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors">
              Add New Student
            </button>
          </div>
          <div className="h-96 flex items-center justify-center bg-gray-50 rounded-lg">
            <p className="text-gray-500">Student table will be integrated with Supabase data</p>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

