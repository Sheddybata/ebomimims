"use client";

import { useCallback, useEffect, useState } from "react";
import ProtectedRoute from "@/components/ProtectedRoute";
import ExecutivePortalLayout from "@/components/ExecutivePortalLayout";
import ImsPipelineColumn from "@/components/ims/ImsPipelineColumn";
import ImsReportReviewDialog from "@/components/ims/ImsReportReviewDialog";
import { ALLOW_GO_PORTAL } from "@/lib/ims-reports/executiveRoles";
import {
  imsStageLabels,
  filterImsPipelineByStage,
  type ImsPipelineReport,
} from "@/lib/ims-reports/pipelineStore";
import {
  getSupabasePipelineReports,
  goApproveReport,
  goReturnReportForRevision,
} from "@/lib/ims-reports/supabasePipelineStore";
import { CheckCircle2, RefreshCw } from "lucide-react";

export default function ExecutiveGeneralOverseerPage() {
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

  const goQueue = filterImsPipelineByStage(reports, "awaiting_general_overseer");

  return (
    <ProtectedRoute allowedRoles={ALLOW_GO_PORTAL}>
      <ExecutivePortalLayout role="general_overseer" headline="Pending your approval">
        <div className="mx-auto max-w-6xl space-y-6">
          <p className="text-sm text-gray-600">
            Review the full report body and metrics forwarded by the AGO, then give final approval.
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
            title={imsStageLabels.awaiting_general_overseer}
            description="Final approval desk for the General Overseer."
            reports={goQueue}
            accent="border-l-4 border-violet-500"
            actions={(r) => (
              <button
                type="button"
                onClick={() => setReviewReport(r)}
                className="mt-3 w-full sm:w-auto px-3 py-1.5 text-xs font-semibold bg-violet-600 text-white rounded-lg hover:bg-violet-700 inline-flex items-center justify-center gap-1"
              >
                <CheckCircle2 size={14} />
                Review and approve
              </button>
            )}
          />
        </div>
        {reviewReport ? (
          <ImsReportReviewDialog
            report={reviewReport}
            title="Approve this report?"
            decisionSummary="Approving will close this report as approved and create outcome inbox notices for the author chain."
            confirmLabel="Approve report"
            confirmClassName="bg-violet-600 hover:bg-violet-700"
            returnLabel="Return to author chain"
            isBusy={isProcessing}
            onCancel={() => {
              if (!isProcessing) setReviewReport(null);
            }}
            onConfirm={async () => {
              setIsProcessing(true);
              try {
                await goApproveReport(reviewReport.id);
                setReviewReport(null);
                await refresh();
              } finally {
                setIsProcessing(false);
              }
            }}
            onReturn={async (note) => {
              setIsProcessing(true);
              try {
                await goReturnReportForRevision(reviewReport.id, note);
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
