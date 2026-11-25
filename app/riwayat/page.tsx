import { PageHeader } from "@/components/page-header";
import { RiwayatView } from "@/components/riwayat/riwayat-view";
import { TRANSACTIONS } from "@/lib/data";

export const metadata = { title: "Riwayat Transaksi · Sarjana Degan POS" };

export default function RiwayatPage() {
  return (
    <div className="flex flex-col gap-5 p-4 md:p-6">
      <PageHeader title="Riwayat Transaksi" description="Daftar penjualan hari ini. Ketuk untuk melihat struk." />
      <RiwayatView transactions={TRANSACTIONS} />
    </div>
  );
}
