"use client";

import { BarChart3, Hash } from "lucide-react";
import MetricCard from "@/components/MetricCard";
import { metricDisplayLabel } from "@/lib/metricLabels";

/** Dashboard-style metric tiles for pipeline / reports (matches admin dashboard feel). */
export default function PipelineMetricsDashboard({
  metrics,
}: {
  metrics: Record<string, string>;
}) {
  const entries = Object.entries(metrics).filter(([, v]) => v != null && String(v).trim() !== "");
  if (entries.length === 0) return null;
  const compactMetricEntries = entries.filter(([, v]) => {
    const value = String(v).trim();
    return value.length <= 32 && !value.includes("\n");
  });
  const longMetricEntries = entries.filter(([, v]) => {
    const value = String(v).trim();
    return value.length > 32 || value.includes("\n");
  });

  const bgColors = [
    "bg-sky-50",
    "bg-emerald-50",
    "bg-amber-50",
    "bg-violet-50",
    "bg-rose-50",
    "bg-teal-50",
  ];

  return (
    <div className="mt-3 rounded-xl border border-gray-200/90 bg-gradient-to-br from-slate-50/95 via-white to-red-50/25 p-3 shadow-[inset_0_1px_0_0_rgba(0,0,0,0.04)]">
      <p className="text-[10px] font-semibold uppercase tracking-wide text-gray-500 mb-2.5 flex items-center gap-1.5">
        <span className="flex h-6 w-6 items-center justify-center rounded-md bg-primary-600/10 text-primary-700">
          <BarChart3 size={14} strokeWidth={2.5} />
        </span>
        Structured metrics
      </p>
      {compactMetricEntries.length > 0 ? (
        <div className="grid grid-cols-2 sm:grid-cols-2 lg:grid-cols-3 gap-2">
          {compactMetricEntries.map(([k, v], i) => (
            <MetricCard
              key={k}
              title={metricDisplayLabel(k)}
              value={String(v).trim()}
              bgColor={bgColors[i % bgColors.length]}
              icon={<Hash size={16} className="text-gray-600" />}
              compact
            />
          ))}
        </div>
      ) : null}
      {longMetricEntries.length > 0 ? (
        <div className={compactMetricEntries.length > 0 ? "mt-2 space-y-2" : "space-y-2"}>
          {longMetricEntries.map(([k, v]) => (
            <div key={k} className="rounded-lg border border-gray-100 bg-white p-2.5">
              <p className="text-[10px] font-semibold text-gray-500 leading-snug">
                {metricDisplayLabel(k)}
              </p>
              <p className="mt-1 text-xs text-gray-800 leading-relaxed whitespace-pre-wrap break-words">
                {String(v).trim()}
              </p>
            </div>
          ))}
        </div>
      ) : null}
    </div>
  );
}
