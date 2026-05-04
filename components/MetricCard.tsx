import Image from "next/image";
import { ArrowUpRight, ArrowDownRight, Minus } from "lucide-react";

interface MetricCardProps {
  title: string;
  value: string;
  icon?: React.ReactNode;
  imageSrc?: string;
  bgColor?: string;
  trend?: "up" | "down" | "neutral";
  trendValue?: string;
  subtitle?: string;
  /** Smaller typography for dense lists (e.g. pipeline report cards). */
  compact?: boolean;
}

export default function MetricCard({ 
  title, 
  value, 
  icon,
  imageSrc,
  bgColor = "bg-blue-50",
  trend,
  trendValue,
  subtitle,
  compact = false,
}: MetricCardProps) {
  const trendColors = {
    up: "text-green-600",
    down: "text-red-600",
    neutral: "text-gray-500"
  };

  const trendBgColors = {
    up: "bg-green-50",
    down: "bg-red-50",
    neutral: "bg-gray-50"
  };

  return (
    <div
      className={`bg-white rounded-lg shadow-sm border border-transparent hover:border-gray-200/80 group overflow-hidden transition-all duration-200 ${
        compact ? "p-3 hover:shadow-md" : "p-4 hover:shadow-lg cursor-pointer"
      }`}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="flex-1 min-w-0">
          <p className={`text-gray-600 mb-1 font-medium ${compact ? "text-[10px] leading-tight" : "text-xs"}`}>
            {title}
          </p>
          <div className="flex items-baseline gap-2 mb-1 flex-wrap">
            <p className={`font-bold text-gray-800 tabular-nums ${compact ? "text-lg leading-tight" : "text-2xl"}`}>
              {value}
            </p>
            {trend && trendValue && (
              <div className={`flex items-center gap-1 px-1.5 py-0.5 rounded-md text-xs font-semibold ${trendBgColors[trend]} ${trendColors[trend]}`}>
                {trend === "up" ? (
                  <ArrowUpRight size={12} className="font-bold" />
                ) : trend === "down" ? (
                  <ArrowDownRight size={12} className="font-bold" />
                ) : (
                  <Minus size={12} className="font-bold" />
                )}
                <span>{trendValue}</span>
              </div>
            )}
          </div>
          {subtitle && (
            <p className="text-xs text-gray-500 mt-1 font-normal">{subtitle}</p>
          )}
        </div>
        <div
          className={`${bgColor} rounded-lg opacity-80 flex-shrink-0 transition-opacity duration-300 group-hover:opacity-100 flex items-center justify-center ${
            compact ? "p-1.5" : "p-2"
          }`}
        >
          {imageSrc ? (
            <Image 
              src={imageSrc} 
              alt={title}
              width={36}
              height={36}
              className="object-contain"
            />
          ) : (
            icon
          )}
        </div>
      </div>
    </div>
  );
}

