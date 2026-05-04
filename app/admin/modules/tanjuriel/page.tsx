"use client";

import DashboardLayout from "@/components/DashboardLayout";
import MetricCard from "@/components/MetricCard";
import { Building2, DollarSign, TrendingUp, AlertTriangle } from "lucide-react";

export default function TanjurielModulePage() {
  return (
    <DashboardLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Tanjuriel Module</h1>
          <p className="text-gray-600">Business/Economic - Business unit monitoring and financial tracking</p>
        </div>

        {/* Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <MetricCard
            title="Total Revenue"
            value="$2.5M"
            icon={<DollarSign size={32} />}
            bgColor="bg-green-50"
          />
          <MetricCard
            title="Business Units"
            value="4"
            icon={<Building2 size={32} />}
            bgColor="bg-blue-50"
          />
          <MetricCard
            title="Average ROI"
            value="15.5%"
            icon={<TrendingUp size={32} />}
            bgColor="bg-purple-50"
          />
          <MetricCard
            title="Risk Alerts"
            value="2"
            icon={<AlertTriangle size={32} />}
            bgColor="bg-orange-50"
          />
        </div>

        {/* Business Units */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Medical Unit</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">ROI:</span>
                <span className="font-semibold text-green-600">18.2%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Cash Flow:</span>
                <span className="font-semibold">$250,000</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Status:</span>
                <span className="px-2 py-1 bg-green-100 text-green-800 rounded-full text-sm">Healthy</span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Agro-Alliance Unit</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">ROI:</span>
                <span className="font-semibold text-green-600">12.5%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Cash Flow:</span>
                <span className="font-semibold">$180,000</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Status:</span>
                <span className="px-2 py-1 bg-green-100 text-green-800 rounded-full text-sm">Healthy</span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Transport Unit</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">ROI:</span>
                <span className="font-semibold text-yellow-600">8.3%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Cash Flow:</span>
                <span className="font-semibold">$120,000</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Status:</span>
                <span className="px-2 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm">Monitor</span>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Hospitality Unit</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">ROI:</span>
                <span className="font-semibold text-green-600">22.1%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Cash Flow:</span>
                <span className="font-semibold">$320,000</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Status:</span>
                <span className="px-2 py-1 bg-green-100 text-green-800 rounded-full text-sm">Excellent</span>
              </div>
            </div>
          </div>
        </div>

        {/* Growth Plans Placeholder */}
        <div className="bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Risk-Mitigated Growth Plans</h3>
          <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg">
            <p className="text-gray-500">Growth plans will be integrated with Supabase data</p>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

