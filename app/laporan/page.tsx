import { PageHeader } from "@/components/page-header";
import { MetricCard } from "@/components/laporan/metric-card";
import { EXPENSES, TRANSACTIONS, formatRupiah, transactionTotal } from "@/lib/data";

export const metadata = { title: "Laporan Harian · Sarjana Degan POS" };

export default function LaporanPage() {
  const omzet = TRANSACTIONS.reduce((s, tx) => s + transactionTotal(tx), 0);
  const pengeluaran = EXPENSES.reduce((s, e) => s + e.amount, 0);
  const tunai = TRANSACTIONS.filter((t) => t.method === "TUNAI").reduce((s, t) => s + transactionTotal(t), 0);

  const bestSellers = Object.entries(
    TRANSACTIONS.flatMap((t) => t.items).reduce<Record<string, number>>((acc, item) => {
      acc[item.productName] = (acc[item.productName] ?? 0) + item.quantity;
      return acc;
    }, {}),
  ).sort((a, b) => b[1] - a[1]);
  const maxSold = bestSellers[0]?.[1] ?? 1;

  return (
    <div className="flex flex-col gap-5 p-4 md:p-6">
      <PageHeader title="Laporan Harian" description="Ringkasan omzet, pengeluaran, dan sisa kas hari ini." />

      <div className="grid gap-3 sm:grid-cols-3">
        <MetricCard label="Total Omzet" value={formatRupiah(omzet)} hint={`${TRANSACTIONS.length} transaksi`} />
        <MetricCard label="Total Pengeluaran" value={formatRupiah(pengeluaran)} hint={`${EXPENSES.length} catatan`} tone="danger" />
        <MetricCard label="Sisa Kas Bersih" value={formatRupiah(omzet - pengeluaran)} hint="Omzet dikurangi pengeluaran" tone="primary" />
      </div>

      <div className="grid gap-5 lg:grid-cols-2">
        <section aria-labelledby="best-title" className="flex flex-col gap-4 rounded-xl border border-border bg-card p-5">
          <h2 id="best-title" className="font-semibold">Produk Terlaris</h2>
          <ul className="flex flex-col gap-3">
            {bestSellers.map(([name, qty]) => (
              <li key={name} className="flex flex-col gap-1.5">
                <div className="flex justify-between text-sm">
                  <span>{name}</span>
                  <span className="font-semibold tabular-nums">{qty}</span>
                </div>
                <div className="h-2 overflow-hidden rounded-full bg-muted">
                  <div className="h-full rounded-full bg-primary" style={{ width: `${(qty / maxSold) * 100}%` }} />
                </div>
              </li>
            ))}
          </ul>
        </section>

        <section aria-labelledby="method-title" className="flex flex-col gap-4 rounded-xl border border-border bg-card p-5">
          <h2 id="method-title" className="font-semibold">Metode Pembayaran</h2>
          <dl className="flex flex-col divide-y divide-border">
            <div className="flex justify-between py-3 text-sm">
              <dt className="text-muted-foreground">Tunai</dt>
              <dd className="font-semibold tabular-nums">{formatRupiah(tunai)}</dd>
            </div>
            <div className="flex justify-between py-3 text-sm">
              <dt className="text-muted-foreground">QRIS / Transfer</dt>
              <dd className="font-semibold tabular-nums">{formatRupiah(omzet - tunai)}</dd>
            </div>
            <div className="flex justify-between py-3 text-sm">
              <dt className="text-muted-foreground">Uang tunai di laci (setelah pengeluaran)</dt>
              <dd className="font-semibold tabular-nums">{formatRupiah(tunai - pengeluaran)}</dd>
            </div>
          </dl>
        </section>
      </div>
    </div>
  );
}
