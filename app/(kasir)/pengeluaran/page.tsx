import { PageHeader } from "@/components/page-header";
import { ExpenseView } from "@/components/pengeluaran/expense-view";
import { EXPENSES } from "@/lib/data";

export const metadata = { title: "Pengeluaran · Sarjana Degan POS" };

export default function PengeluaranPage() {
  return (
    <div className="flex flex-col gap-5 p-4 md:p-6">
      <PageHeader
        title="Buku Pengeluaran"
        description="Catat kas keluar lapak seperti es batu, cup, sedotan, dan plastik."
      />
      <ExpenseView initialExpenses={EXPENSES} />
    </div>
  );
}
