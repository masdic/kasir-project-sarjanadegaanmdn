import Link from "next/link";
import { AlertTriangle, LogOut, MapPin, ReceiptText, TrendingUp } from "lucide-react";
import { BRANCHES } from "@/lib/data";
import { HeaderClock } from "@/components/header-clock";
import { BranchCard } from "@/components/owner/branch-card";

const rupiah = new Intl.NumberFormat("id-ID", {
  style: "currency",
  currency: "IDR",
  maximumFractionDigits: 0,
});

export function OwnerDashboard() {
  const totalRevenue = BRANCHES.reduce((sum, branch) => sum + branch.todayRevenue, 0);
  const totalTransactions = BRANCHES.reduce((sum, branch) => sum + branch.todayTransactions, 0);
  const totalLowStock = BRANCHES.reduce((sum, branch) => sum + branch.lowStockItems, 0);

  return (
    <div className="flex min-h-dvh flex-col">
      <header className="flex items-center justify-between gap-4 border-b border-border bg-card px-4 py-3 md:px-6">
        <div className="flex items-center gap-3">
          <div className="flex size-10 items-center justify-center rounded-xl bg-primary font-bold text-primary-foreground">
            SD
          </div>
          <div className="leading-tight">
            <p className="text-sm font-semibold md:text-base">Dashboard Owner</p>
            <p className="text-xs text-muted-foreground">Semua cabang</p>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <HeaderClock />
          <Link
            href="/login"
            className="flex items-center gap-2 rounded-lg border border-border px-3 py-2 text-sm font-medium hover:bg-muted"
          >
            <LogOut className="size-4" aria-hidden="true" />
            <span className="hidden sm:inline">Keluar</span>
          </Link>
        </div>
      </header>

      <main className="flex flex-1 flex-col gap-6 p-4 md:p-6">
        <section aria-labelledby="ringkasan-title">
          <h1 id="ringkasan-title" className="text-lg font-semibold">
            Ringkasan Hari Ini
          </h1>
          <div className="mt-3 grid gap-3 sm:grid-cols-3">
            <SummaryTile
              icon={TrendingUp}
              label="Total omzet"
              value={rupiah.format(totalRevenue)}
            />
            <SummaryTile
              icon={ReceiptText}
              label="Total transaksi"
              value={`${totalTransactions} transaksi`}
            />
            <SummaryTile
              icon={AlertTriangle}
              label="Stok menipis"
              value={`${totalLowStock} produk`}
              warning={totalLowStock > 0}
            />
          </div>
        </section>

        <section aria-labelledby="cabang-title">
          <h2 id="cabang-title" className="flex items-center gap-2 text-lg font-semibold">
            <MapPin className="size-5 text-primary" aria-hidden="true" />
            Per Cabang
          </h2>
          <div className="mt-3 grid gap-3 md:grid-cols-2">
            {BRANCHES.map((branch) => (
              <BranchCard
                key={branch.id}
                branch={branch}
                share={totalRevenue ? branch.todayRevenue / totalRevenue : 0}
                formatMoney={rupiah.format}
              />
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}

function SummaryTile({
  icon: Icon,
  label,
  value,
  warning = false,
}: {
  icon: typeof TrendingUp;
  label: string;
  value: string;
  warning?: boolean;
}) {
  return (
    <div className="flex items-center gap-3 rounded-xl border border-border bg-card p-4">
      <div
        className={`flex size-10 items-center justify-center rounded-lg ${
          warning ? "bg-amber-100 text-amber-700" : "bg-primary-soft text-primary"
        }`}
      >
        <Icon className="size-5" aria-hidden="true" />
      </div>
      <div>
        <p className="text-xs text-muted-foreground">{label}</p>
        <p className="text-lg font-semibold">{value}</p>
      </div>
    </div>
  );
}
