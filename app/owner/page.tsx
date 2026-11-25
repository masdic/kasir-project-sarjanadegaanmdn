import type { Metadata } from "next";
import { OwnerDashboard } from "@/components/owner/owner-dashboard";

export const metadata: Metadata = {
  title: "Dashboard Owner · Sarjana Degan POS",
};

export default function OwnerPage() {
  return <OwnerDashboard />;
}
