"use client";

import { useCallback, useEffect, useState } from "react";
import ProtectedRoute from "@/components/ProtectedRoute";
import ExecutivePortalLayout from "@/components/ExecutivePortalLayout";
import ImsPipelineColumn from "@/components/ims/ImsPipelineColumn";
import ImsReportReviewDialog from "@/components/ims/ImsReportReviewDialog";
import { ALLOW_AGO_PORTAL } from "@/lib/ims-reports/executiveRoles";
import {
  imsStageLabels,
  filterImsPipelineByStage,
  type ImsPipelineReport,
} from "@/lib/ims-reports/pipelineStore";
import {
  agoForwardReportToGo,
  agoReturnReportForRevision,
  getSupabasePipelineReports,
} from "@/lib/ims-reports/supabasePipelineStore";
import { ArrowRight, RefreshCw } from "lucide-react";

export default function ExecutiveAgoPage() {
  const [reports, setReports] = useState<ImsPipelineReport[]>([]);
  const [reviewReport, setReviewReport] = useState<ImsPipelineReport | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [loadError, setLoadError] = useState("");
  const refresh = useCallback(async () => {
    setLoadError("");
    try {
      const remoteReports = await getSupabasePipelineReports();
      setReports(remoteReports);
    } catch (error) {
      setReports([]);
      setLoadError(error instanceof Error ? error.message : "Unable to load Supabase reports.");
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const agoQueue = filterImsPipelineByStage(reports, "awaiting_ago");

  return (
    <ProtectedRoute allowedRoles={ALLOW_AGO_PORTAL}>
      <ExecutivePortalLayout role="ago" headline="Reports for AGO action">
        <div className="mx-auto max-w-6xl space-y-6">
          <p className="text-sm text-gray-600">
            Review the full report body and metrics approved by the NDA, then send cleared items to the
            General Overseer for final approval.
          </p>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => void refresh()}
              className="px-3 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 inline-flex items-center gap-2"
            >
              <RefreshCw size={16} />
              Refresh
            </button>
          </div>
          {loadError ? (
            <div className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-900">
              Unable to load submitted reports from Supabase: {loadError}
            </div>
          ) : null}
          <ImsPipelineColumn
            title={imsStageLabels.awaiting_ago}
            description="AGO reviews and sends upward to the General Overseer."
            reports={agoQueue}
            accent="border-l-4 border-amber-500"
            actions={(r) => (
              <button
                type="button"
                onClick={() => setReviewReport(r)}
                className="mt-3 w-full sm:w-auto px-3 py-1.5 text-xs font-semibold bg-amber-600 text-white rounded-lg hover:bg-amber-700 inline-flex items-center justify-center gap-1"
              >
                Review and send to GO
                <ArrowRight size={14} />
              </button>
            )}
          />
        </div>
        {reviewReport ? (
          <ImsReportReviewDialog
            report={reviewReport}
            title="Send this report to GO?"
            decisionSummary="Sending will move this report out of the AGO queue and into the General Overseer queue for final review."
            confirmLabel="Send to GO"
            confirmClassName="bg-amber-600 hover:bg-amber-700"
            returnLabel="Return to author chain"
            isBusy={isProcessing}
            onCancel={() => {
              if (!isProcessing) setReviewReport(null);
            }}
            onConfirm={async () => {
              setIsProcessing(true);
              try {
                await agoForwardReportToGo(reviewReport.id);
                setReviewReport(null);
                await refresh();
              } finally {
                setIsProcessing(false);
              }
            }}
            onReturn={async (note) => {
              setIsProcessing(true);
              try {
                await agoReturnReportForRevision(reviewReport.id, note);
                setReviewReport(null);
                await refresh();
              } finally {
                setIsProcessing(false);
              }
            }}
          />
        ) : null}
      </ExecutivePortalLayout>
    </ProtectedRoute>
  );
}
