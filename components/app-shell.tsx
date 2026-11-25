"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BarChart3, Boxes, ReceiptText, ShoppingCart, Wallet } from "lucide-react";
import { STORE } from "@/lib/data";
import { HeaderClock } from "@/components/header-clock";

const NAV_ITEMS = [
  { href: "/", label: "Kasir", icon: ShoppingCart },
  { href: "/riwayat", label: "Riwayat", icon: ReceiptText },
  { href: "/stok", label: "Stok", icon: Boxes },
  { href: "/pengeluaran", label: "Pengeluaran", icon: Wallet },
  { href: "/laporan", label: "Laporan", icon: BarChart3 },
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="flex min-h-dvh">
      <aside className="hidden w-60 shrink-0 flex-col border-r border-border bg-card md:flex">
        <div className="flex items-center gap-3 px-5 py-5">
          <div className="flex size-10 items-center justify-center rounded-xl bg-primary text-lg font-bold text-primary-foreground">
            SD
          </div>
          <div className="leading-tight">
            <p className="font-semibold">{STORE.name}</p>
            <p className="text-xs text-muted-foreground">Mobile POS</p>
          </div>
        </div>
        <nav aria-label="Menu utama" className="flex flex-col gap-1 px-3">
          {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
            const active = pathname === href;
            return (
              <Link
                key={href}
                href={href}
                aria-current={active ? "page" : undefined}
                className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors ${
                  active
                    ? "bg-primary-soft text-primary"
                    : "text-muted-foreground hover:bg-muted hover:text-foreground"
                }`}
              >
                <Icon className="size-5" aria-hidden="true" />
                {label}
              </Link>
            );
          })}
        </nav>
      </aside>

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex items-center justify-between gap-4 border-b border-border bg-card px-4 py-3 md:px-6">
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold md:text-base">{STORE.branch}</p>
            <p className="truncate text-xs text-muted-foreground">{STORE.address}</p>
          </div>
          <HeaderClock />
        </header>

        <main className="flex-1 pb-20 md:pb-0">{children}</main>
      </div>

      <nav
        aria-label="Menu utama"
        className="fixed inset-x-0 bottom-0 z-30 flex border-t border-border bg-card md:hidden"
      >
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const active = pathname === href;
          return (
            <Link
              key={href}
              href={href}
              aria-current={active ? "page" : undefined}
              className={`flex flex-1 flex-col items-center gap-1 py-2.5 text-[11px] font-medium ${
                active ? "text-primary" : "text-muted-foreground"
              }`}
            >
              <Icon className="size-5" aria-hidden="true" />
              {label}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
