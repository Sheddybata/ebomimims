import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Information Management System",
  description: "Admin dashboard for managing reports across all modules",
  icons: {
    icon: [{ url: "/arms/ebomi.jpg", type: "image/jpeg" }],
    apple: "/arms/ebomi.jpg",
    shortcut: "/arms/ebomi.jpg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  );
}

