// Utility functions for draft saving and management

export interface DraftData {
  formType: string;
  tabType: string;
  moduleName: string;
  data: any;
  lastSaved: string;
  version: number;
}

const DRAFT_PREFIX = "draft_";

export const saveDraft = (tabType: string, moduleName: string, formData: any, formType: string = "submit") => {
  try {
    const draftKey = `${DRAFT_PREFIX}${moduleName}_${tabType}`;
    const existingDraft = getDraft(tabType, moduleName);
    
    const draft: DraftData = {
      formType,
      tabType,
      moduleName,
      data: formData,
      lastSaved: new Date().toISOString(),
      version: existingDraft ? existingDraft.version + 1 : 1,
    };
    
    localStorage.setItem(draftKey, JSON.stringify(draft));
    return true;
  } catch (error) {
    console.error("Error saving draft:", error);
    return false;
  }
};

export const getDraft = (tabType: string, moduleName: string): DraftData | null => {
  try {
    const draftKey = `${DRAFT_PREFIX}${moduleName}_${tabType}`;
    const draftStr = localStorage.getItem(draftKey);
    if (!draftStr) return null;
    
    return JSON.parse(draftStr) as DraftData;
  } catch (error) {
    console.error("Error loading draft:", error);
    return null;
  }
};

export const deleteDraft = (tabType: string, moduleName: string) => {
  try {
    const draftKey = `${DRAFT_PREFIX}${moduleName}_${tabType}`;
    localStorage.removeItem(draftKey);
    return true;
  } catch (error) {
    console.error("Error deleting draft:", error);
    return false;
  }
};

export const getAllDrafts = (moduleName: string): DraftData[] => {
  try {
    const drafts: DraftData[] = [];
    const prefix = `${DRAFT_PREFIX}${moduleName}_`;
    
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && key.startsWith(prefix)) {
        const draftStr = localStorage.getItem(key);
        if (draftStr) {
          drafts.push(JSON.parse(draftStr) as DraftData);
        }
      }
    }
    
    return drafts.sort((a, b) => 
      new Date(b.lastSaved).getTime() - new Date(a.lastSaved).getTime()
    );
  } catch (error) {
    console.error("Error loading drafts:", error);
    return [];
  }
};

export const clearAllDrafts = (moduleName: string) => {
  try {
    const prefix = `${DRAFT_PREFIX}${moduleName}_`;
    const keysToRemove: string[] = [];
    
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && key.startsWith(prefix)) {
        keysToRemove.push(key);
      }
    }
    
    keysToRemove.forEach(key => localStorage.removeItem(key));
    return true;
  } catch (error) {
    console.error("Error clearing drafts:", error);
    return false;
  }
};

// Helper to normalize module names for consistent storage
export const normalizeModuleName = (moduleName: string): string => {
  const normalized = moduleName.toLowerCase();
  // Map common variations
  if (normalized.includes("education") || normalized.includes("school") || normalized.includes("ebomi school")) {
    return "education";
  }
  return normalized;
};

