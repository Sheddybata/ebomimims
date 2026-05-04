"use client";

import { ReactNode } from "react";

interface FormFieldProps {
  label: string;
  required?: boolean;
  error?: string;
  children: ReactNode;
  helpText?: string;
}

export default function FormField({ label, required = false, error, children, helpText }: FormFieldProps) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {label} {required && <span className="text-red-500">*</span>}
      </label>
      <div className={error ? "border-red-300 rounded-lg" : ""}>
        {children}
      </div>
      {error && (
        <p className="mt-1 text-sm text-red-600 flex items-center gap-1">
          <span className="text-red-500">•</span>
          {error}
        </p>
      )}
      {helpText && !error && (
        <p className="mt-1 text-xs text-gray-500">{helpText}</p>
      )}
    </div>
  );
}


