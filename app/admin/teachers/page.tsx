"use client";

import DashboardLayout from "@/components/DashboardLayout";
import MetricCard from "@/components/MetricCard";
import { GraduationCap, Users, BookOpen, Award } from "lucide-react";

export default function TeachersPage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Teachers Management</h1>
          <p className="text-gray-600">Manage teacher profiles, assignments, and performance</p>
        </div>

        {/* Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <MetricCard
            title="Total Teachers"
            value="2.0K"
            icon={<GraduationCap size={32} />}
            bgColor="bg-blue-50"
          />
          <MetricCard
            title="Active Teachers"
            value="1.9K"
            icon={<Users size={32} />}
            bgColor="bg-green-50"
          />
          <MetricCard
            title="Subjects Taught"
            value="25"
            icon={<BookOpen size={32} />}
            bgColor="bg-purple-50"
          />
          <MetricCard
            title="Certified"
            value="1.8K"
            icon={<Award size={32} />}
            bgColor="bg-orange-50"
          />
        </div>

        {/* Teacher Table Placeholder */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-gray-800">Teacher Records</h3>
            <button className="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors">
              Add New Teacher
            </button>
          </div>
          <div className="h-96 flex items-center justify-center bg-gray-50 rounded-lg">
            <p className="text-gray-500">Teacher table will be integrated with Supabase data</p>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

