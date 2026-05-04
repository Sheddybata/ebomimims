"use client";

import DashboardLayout from "@/components/DashboardLayout";
import MetricCard from "@/components/MetricCard";
import { MapPin, Users, TrendingUp, FileText } from "lucide-react";

export default function IBBNModulePage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">IBBN Module</h1>
          <p className="text-gray-600">Political/National - Membership tracking and strategic directives</p>
        </div>

        {/* Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <MetricCard
            title="Total Membership"
            value="50.0K"
            icon={<Users size={32} />}
            bgColor="bg-blue-50"
          />
          <MetricCard
            title="Wards"
            value="150"
            icon={<MapPin size={32} />}
            bgColor="bg-purple-50"
          />
          <MetricCard
            title="LGAs"
            value="45"
            icon={<MapPin size={32} />}
            bgColor="bg-green-50"
          />
          <MetricCard
            title="States"
            value="12"
            icon={<MapPin size={32} />}
            bgColor="bg-orange-50"
          />
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* National Intelligence Feed */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-800">National Intelligence Feed</h3>
              <FileText className="text-primary-600" size={24} />
            </div>
            <div className="space-y-4">
              <div className="p-4 bg-gray-50 rounded-lg">
                <p className="font-medium text-gray-800 mb-2">Membership Growth - Lagos State</p>
                <p className="text-sm text-gray-600">
                  Significant membership increase of 15% in Q4 2023 across all LGAs.
                </p>
                <p className="text-xs text-gray-400 mt-2">2 hours ago</p>
              </div>
              <div className="p-4 bg-gray-50 rounded-lg">
                <p className="font-medium text-gray-800 mb-2">Strategic Initiative - Abuja</p>
                <p className="text-sm text-gray-600">
                  New ward formation in Garki area with 200+ new members.
                </p>
                <p className="text-xs text-gray-400 mt-2">5 hours ago</p>
              </div>
            </div>
          </div>

          {/* Strategic Directives */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-800">Strategic Directives</h3>
              <TrendingUp className="text-primary-600" size={24} />
            </div>
            <div className="space-y-4">
              <div className="p-4 bg-primary-50 rounded-lg border-l-4 border-primary-600">
                <p className="font-medium text-gray-800 mb-2">Q1 2024 Focus</p>
                <p className="text-sm text-gray-600">
                  Increase membership by 20% across all states. Priority on youth engagement.
                </p>
                <p className="text-xs text-gray-400 mt-2">Sent to all State Leaders</p>
              </div>
              <div className="p-4 bg-primary-50 rounded-lg border-l-4 border-primary-600">
                <p className="font-medium text-gray-800 mb-2">National Convention</p>
                <p className="text-sm text-gray-600">
                  Preparations for the upcoming national convention in March 2024.
                </p>
                <p className="text-xs text-gray-400 mt-2">Sent to all State Leaders</p>
              </div>
            </div>
          </div>
        </div>

        {/* Membership Growth Chart Placeholder */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Membership Growth by Region</h3>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg">
            <p className="text-gray-500">Chart will be integrated with Supabase data</p>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

