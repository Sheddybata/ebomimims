"use client";

import { useCallback, useEffect, useState } from "react";
import ProtectedRoute from "@/components/ProtectedRoute";
import ExecutivePortalLayout from "@/components/ExecutivePortalLayout";
import ImsPipelineColumn from "@/components/ims/ImsPipelineColumn";
import ImsReportReviewDialog from "@/components/ims/ImsReportReviewDialog";
import { ALLOW_NDA_PORTAL } from "@/lib/ims-reports/executiveRoles";
import {
  imsStageLabels,
  filterImsPipelineByStage,
  type ImsPipelineReport,
} from "@/lib/ims-reports/pipelineStore";
import {
  getSupabasePipelineReports,
  ndaForwardReportToAgo,
  ndaReturnReportForRevision,
} from "@/lib/ims-reports/supabasePipelineStore";
import { ArrowRight, RefreshCw } from "lucide-react";

export default function ExecutiveNdaPage() {
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

  const national = filterImsPipelineByStage(reports, "awaiting_administration");

  return (
    <ProtectedRoute allowedRoles={ALLOW_NDA_PORTAL}>
      <ExecutivePortalLayout role="nda" headline="Reports awaiting your review">
        <div className="mx-auto max-w-6xl space-y-6">
          <p className="text-sm text-gray-600">
            National Director of Administration (NDA): review the full report body and metrics, then forward
            cleared items to the Assistant General Overseer.
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
            title={imsStageLabels.awaiting_administration}
            description="Receives directorate reports escalated from directors on mobile."
            reports={national}
            accent="border-l-4 border-red-500"
            actions={(r) => (
              <button
                type="button"
                onClick={() => setReviewReport(r)}
                className="mt-3 w-full sm:w-auto px-3 py-1.5 text-xs font-semibold bg-red-600 text-white rounded-lg hover:bg-red-700 inline-flex items-center justify-center gap-1"
              >
                Review and forward to AGO
                <ArrowRight size={14} />
              </button>
            )}
          />
        </div>
        {reviewReport ? (
          <ImsReportReviewDialog
            report={reviewReport}
            title="Forward this report to AGO?"
            decisionSummary="Forwarding will move this report out of the NDA queue and into the AGO queue for the next executive review."
            confirmLabel="Forward to AGO"
            confirmClassName="bg-red-600 hover:bg-red-700"
            returnLabel="Return to author chain"
            isBusy={isProcessing}
            onCancel={() => {
              if (!isProcessing) setReviewReport(null);
            }}
            onConfirm={async () => {
              setIsProcessing(true);
              try {
                await ndaForwardReportToAgo(reviewReport.id);
                setReviewReport(null);
                await refresh();
              } finally {
                setIsProcessing(false);
              }
            }}
            onReturn={async (note) => {
              setIsProcessing(true);
              try {
                await ndaReturnReportForRevision(reviewReport.id, note);
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
