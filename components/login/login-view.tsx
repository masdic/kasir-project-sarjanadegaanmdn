"use client";

import { useState } from "react";
import { ShieldCheck, Store } from "lucide-react";
import { KasirLogin } from "@/components/login/kasir-login";
import { OwnerLogin } from "@/components/login/owner-login";

type Mode = "kasir" | "owner";

const TABS: { id: Mode; label: string; icon: typeof Store }[] = [
  { id: "kasir", label: "Kasir", icon: Store },
  { id: "owner", label: "Owner", icon: ShieldCheck },
];

export function LoginView() {
  const [mode, setMode] = useState<Mode>("kasir");

  return (
    <main className="flex min-h-dvh flex-col bg-background md:flex-row">
      <section className="flex flex-col justify-between gap-6 bg-primary px-6 py-8 text-primary-foreground md:w-2/5 md:px-10 md:py-12">
        <div className="flex items-center gap-3">
          <div className="flex size-11 items-center justify-center rounded-xl bg-primary-foreground text-lg font-bold text-primary">
            SD
          </div>
          <div className="leading-tight">
            <p className="font-semibold">Sarjana Degan</p>
            <p className="text-sm opacity-80">Mobile POS</p>
          </div>
        </div>
        <div className="hidden md:block">
          <h1 className="text-balance text-3xl font-semibold leading-tight">
            Kelapa muda segar, kasir yang cepat.
          </h1>
          <p className="mt-3 max-w-sm text-pretty text-sm leading-relaxed opacity-80">
            Masuk sebagai kasir cabang untuk mulai berjualan, atau sebagai owner untuk melihat
            laporan semua cabang.
          </p>
        </div>
        <p className="hidden text-xs opacity-70 md:block">Madiun · 2 Cabang</p>
      </section>

      <section className="flex flex-1 items-start justify-center px-4 py-8 md:items-center">
        <div className="w-full max-w-sm">
          <h2 className="text-xl font-semibold">Masuk</h2>
          <p className="mt-1 text-sm text-muted-foreground">Pilih jenis akun Anda.</p>

          <div
            role="tablist"
            aria-label="Jenis akun"
            className="mt-5 grid grid-cols-2 gap-1 rounded-xl bg-muted p-1"
          >
            {TABS.map(({ id, label, icon: Icon }) => {
              const selected = mode === id;
              return (
                <button
                  key={id}
                  type="button"
                  role="tab"
                  id={`tab-${id}`}
                  aria-selected={selected}
                  aria-controls={`panel-${id}`}
                  onClick={() => setMode(id)}
                  className={`flex items-center justify-center gap-2 rounded-lg py-2.5 text-sm font-medium transition-colors ${
                    selected
                      ? "bg-card text-foreground shadow-sm"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  <Icon className="size-4" aria-hidden="true" />
                  {label}
                </button>
              );
            })}
          </div>

          <div role="tabpanel" id={`panel-${mode}`} aria-labelledby={`tab-${mode}`} className="mt-6">
            {mode === "kasir" ? <KasirLogin /> : <OwnerLogin />}
          </div>

          <p className="mt-6 rounded-lg border border-dashed border-border px-3 py-2 text-center text-xs text-muted-foreground">
            Mode tampilan: PIN dan password belum dicek. Login sungguhan aktif setelah database
            tersambung.
          </p>
        </div>
      </section>
    </main>
  );
}
