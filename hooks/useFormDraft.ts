import { useEffect, useRef, useCallback } from "react";
import { saveDraft, getDraft, deleteDraft } from "@/lib/draftStorage";

interface UseFormDraftOptions {
  moduleName: string;
  tabType: string;
  formData: any;
  enabled?: boolean;
  autoSaveInterval?: number; // milliseconds
}

export const useFormDraft = ({
  moduleName,
  tabType,
  formData,
  enabled = true,
  autoSaveInterval = 10000, // 10 seconds default
}: UseFormDraftOptions) => {
  const autoSaveTimerRef = useRef<NodeJS.Timeout | null>(null);
  const lastSavedRef = useRef<any>(null);

  // Load draft on mount
  const loadDraft = useCallback((): any => {
    if (!enabled) return null;
    const draft = getDraft(tabType, moduleName);
    if (draft && draft.data) {
      return draft.data;
    }
    return null;
  }, [tabType, moduleName, enabled]);

  // Save draft manually
  const saveDraftNow = useCallback(() => {
    if (!enabled) return false;
    // Check if data has changed
    const dataStr = JSON.stringify(formData);
    const lastSavedStr = JSON.stringify(lastSavedRef.current);
    if (dataStr === lastSavedStr) return false; // No changes

    const saved = saveDraft(tabType, moduleName, formData);
    if (saved) {
      lastSavedRef.current = JSON.parse(dataStr);
    }
    return saved;
  }, [tabType, moduleName, formData, enabled]);

  // Auto-save functionality
  useEffect(() => {
    if (!enabled) return;

    // Clear existing timer
    if (autoSaveTimerRef.current) {
      clearInterval(autoSaveTimerRef.current);
    }

    // Set up auto-save interval
    autoSaveTimerRef.current = setInterval(() => {
      saveDraftNow();
    }, autoSaveInterval);

    return () => {
      if (autoSaveTimerRef.current) {
        clearInterval(autoSaveTimerRef.current);
      }
    };
  }, [enabled, autoSaveInterval, saveDraftNow]);

  // Save on unmount
  useEffect(() => {
    return () => {
      if (enabled) {
        saveDraftNow();
      }
    };
  }, [enabled, saveDraftNow]);

  // Clear draft
  const clearDraft = useCallback(() => {
    return deleteDraft(tabType, moduleName);
  }, [tabType, moduleName]);

  return {
    loadDraft,
    saveDraft: saveDraftNow,
    clearDraft,
  };
};


