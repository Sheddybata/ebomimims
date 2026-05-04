"use client";

import { useState, useRef } from "react";
import { Upload, X, File, Image as ImageIcon } from "lucide-react";

interface FileUploadProps {
  accept?: string;
  maxSize?: number; // in MB
  maxFiles?: number;
  onFilesChange?: (files: File[]) => void;
  currentFiles?: string[];
  label?: string;
}

export default function FileUpload({
  accept = "image/*,.pdf,.doc,.docx",
  maxSize = 5,
  maxFiles = 5,
  onFilesChange,
  currentFiles = [],
  label = "Upload Files",
}: FileUploadProps) {
  const [files, setFiles] = useState<File[]>([]);
  const [errors, setErrors] = useState<string[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const validateFile = (file: File): string | null => {
    // Check size
    if (file.size > maxSize * 1024 * 1024) {
      return `File "${file.name}" exceeds maximum size of ${maxSize}MB`;
    }

    // Check file count
    if (files.length >= maxFiles) {
      return `Maximum ${maxFiles} files allowed`;
    }

    return null;
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFiles = Array.from(e.target.files || []);
    const newErrors: string[] = [];
    const validFiles: File[] = [];

    selectedFiles.forEach((file) => {
      const error = validateFile(file);
      if (error) {
        newErrors.push(error);
      } else {
        validFiles.push(file);
      }
    });

    if (newErrors.length > 0) {
      setErrors(newErrors);
      setTimeout(() => setErrors([]), 5000);
    }

    if (validFiles.length > 0) {
      const updatedFiles = [...files, ...validFiles].slice(0, maxFiles);
      setFiles(updatedFiles);
      if (onFilesChange) {
        onFilesChange(updatedFiles);
      }
    }

    // Reset input
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const removeFile = (index: number) => {
    const updatedFiles = files.filter((_, i) => i !== index);
    setFiles(updatedFiles);
    if (onFilesChange) {
      onFilesChange(updatedFiles);
    }
  };

  const getFileIcon = (fileName: string) => {
    const ext = fileName.split(".").pop()?.toLowerCase();
    if (["jpg", "jpeg", "png", "gif", "webp"].includes(ext || "")) {
      return <ImageIcon size={16} />;
    }
    return <File size={16} />;
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes < 1024) return bytes + " B";
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB";
    return (bytes / (1024 * 1024)).toFixed(1) + " MB";
  };

  return (
    <div className="space-y-3">
      <label className="block text-sm font-medium text-gray-700">{label}</label>
      
      {errors.length > 0 && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-2 rounded-lg text-sm">
          {errors.map((error, index) => (
            <div key={index}>{error}</div>
          ))}
        </div>
      )}

      <div
        className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-primary-400 transition-colors cursor-pointer"
        onClick={() => fileInputRef.current?.click()}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept={accept}
          multiple
          onChange={handleFileSelect}
          className="hidden"
        />
        <Upload className="mx-auto h-12 w-12 text-gray-400 mb-2" />
        <p className="text-sm text-gray-600">
          Click to upload or drag and drop
        </p>
        <p className="text-xs text-gray-500 mt-1">
          {accept} (Max {maxSize}MB, {maxFiles} files)
        </p>
      </div>

      {(files.length > 0 || currentFiles.length > 0) && (
        <div className="space-y-2">
          {files.map((file, index) => (
            <div
              key={index}
              className="flex items-center justify-between bg-gray-50 px-4 py-2 rounded-lg"
            >
              <div className="flex items-center gap-3 flex-1 min-w-0">
                {getFileIcon(file.name)}
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-700 truncate">{file.name}</p>
                  <p className="text-xs text-gray-500">{formatFileSize(file.size)}</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => removeFile(index)}
                className="p-1 hover:bg-red-100 rounded text-red-600 transition-colors"
              >
                <X size={16} />
              </button>
            </div>
          ))}
          
          {currentFiles.map((fileName, index) => (
            <div
              key={`existing-${index}`}
              className="flex items-center justify-between bg-blue-50 px-4 py-2 rounded-lg"
            >
              <div className="flex items-center gap-3 flex-1 min-w-0">
                {getFileIcon(fileName)}
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-700 truncate">{fileName}</p>
                  <p className="text-xs text-gray-500">Previously uploaded</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}


