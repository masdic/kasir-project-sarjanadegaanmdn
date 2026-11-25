import type { Metadata } from "next";
import { LoginView } from "@/components/login/login-view";

export const metadata: Metadata = {
  title: "Masuk · Sarjana Degan POS",
};

export default function LoginPage() {
  return <LoginView />;
}
