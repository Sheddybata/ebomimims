"use client";

import DashboardLayout from "@/components/DashboardLayout";
import MetricCard from "@/components/MetricCard";
import { Users, MapPin, DollarSign, BarChart3 } from "lucide-react";

export default function DISEFModulePage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">DISEF Module</h1>
          <p className="text-gray-600">Foundation/Social Impact - Beneficiary management and impact tracking</p>
        </div>

        {/* Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <MetricCard
            title="Total Beneficiaries"
            value="5.0K"
            icon={<Users size={32} />}
            bgColor="bg-blue-50"
          />
          <MetricCard
            title="Locations Covered"
            value="25"
            icon={<MapPin size={32} />}
            bgColor="bg-green-50"
          />
          <MetricCard
            title="Funding Utilized"
            value="$1.2M"
            icon={<DollarSign size={32} />}
            bgColor="bg-purple-50"
          />
          <MetricCard
            title="Impact Score"
            value="8.5/10"
            icon={<BarChart3 size={32} />}
            bgColor="bg-orange-50"
          />
        </div>

        {/* Beneficiary Overview */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Geographic Coverage</h3>
            <div className="space-y-3">
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="font-medium text-gray-800">Lagos State</span>
                <span className="text-sm text-gray-600">1,200 beneficiaries</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="font-medium text-gray-800">Abuja FCT</span>
                <span className="text-sm text-gray-600">800 beneficiaries</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="font-medium text-gray-800">Kano State</span>
                <span className="text-sm text-gray-600">950 beneficiaries</span>
              </div>
              <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                <span className="font-medium text-gray-800">Rivers State</span>
                <span className="text-sm text-gray-600">650 beneficiaries</span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Funding Utilization</h3>
            <div className="space-y-4">
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm text-gray-600">Education Programs</span>
                  <span className="text-sm font-semibold">45%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-primary-600 h-2 rounded-full" style={{ width: "45%" }}></div>
                </div>
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm text-gray-600">Healthcare Initiatives</span>
                  <span className="text-sm font-semibold">30%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-green-600 h-2 rounded-full" style={{ width: "30%" }}></div>
                </div>
              </div>
              <div>
                <div className="flex justify-between mb-2">
                  <span className="text-sm text-gray-600">Community Development</span>
                  <span className="text-sm font-semibold">25%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div className="bg-blue-600 h-2 rounded-full" style={{ width: "25%" }}></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Impact Snapshots Placeholder */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Impact Snapshots</h3>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg">
            <p className="text-gray-500">Impact snapshots will be integrated with Supabase data</p>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

