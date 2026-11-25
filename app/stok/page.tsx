import { PageHeader } from "@/components/page-header";
import { ProductionForm } from "@/components/stok/production-form";
import { StockTable } from "@/components/stok/stock-table";
import { PRODUCTS } from "@/lib/data";

export const metadata = { title: "Stok & Produksi · Sarjana Degan POS" };

export default function StokPage() {
  const coconutStock = PRODUCTS.find((p) => p.name === "Kelapa Muda Ijo")?.stock ?? 0;
  const cupStock = PRODUCTS.filter((p) => p.category === "Es Cup").reduce((s, p) => s + p.stock, 0);

  return (
    <div className="flex flex-col gap-5 p-4 md:p-6">
      <PageHeader
        title="Stok & Produksi Es Cup"
        description="Pantau sisa stok dan catat produksi es cup dari kelapa (1 butir = 3 cup)."
      />
      <div className="grid gap-3 sm:grid-cols-2">
        <div className="rounded-xl border border-border bg-card p-5">
          <p className="text-sm text-muted-foreground">Sisa Kelapa Muda</p>
          <p className="text-3xl font-bold tabular-nums">
            {coconutStock} <span className="text-base font-medium text-muted-foreground">butir</span>
          </p>
        </div>
        <div className="rounded-xl border border-border bg-card p-5">
          <p className="text-sm text-muted-foreground">Sisa Es Cup (semua rasa)</p>
          <p className="text-3xl font-bold tabular-nums">
            {cupStock} <span className="text-base font-medium text-muted-foreground">cup</span>
          </p>
        </div>
      </div>
      <div className="flex flex-col gap-5 lg:flex-row lg:items-start">
        <div className="flex-1">
          <StockTable products={PRODUCTS} />
        </div>
        <div className="lg:w-80">
          <ProductionForm maxCoconut={coconutStock} />
        </div>
      </div>
    </div>
  );
}
