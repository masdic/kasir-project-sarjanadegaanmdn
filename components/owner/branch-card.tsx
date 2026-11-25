import type { Branch } from "@/lib/data";

type BranchCardProps = {
  branch: Branch;
  share: number;
  formatMoney: (value: number) => string;
};

export function BranchCard({ branch, share, formatMoney }: BranchCardProps) {
  const percent = Math.round(share * 100);

  return (
    <article className="flex flex-col gap-4 rounded-xl border border-border bg-card p-5">
      <div>
        <h3 className="font-semibold">
          {branch.name} <span className="font-normal text-muted-foreground">- {branch.area}</span>
        </h3>
        <p className="text-xs text-muted-foreground">{branch.address}</p>
      </div>

      <div>
        <p className="text-xs text-muted-foreground">Omzet hari ini</p>
        <p className="text-2xl font-semibold text-primary">{formatMoney(branch.todayRevenue)}</p>
        <div className="mt-2 flex items-center gap-2">
          <div
            className="h-2 flex-1 overflow-hidden rounded-full bg-muted"
            role="progressbar"
            aria-label={`Porsi omzet ${branch.name}`}
            aria-valuenow={percent}
            aria-valuemin={0}
            aria-valuemax={100}
          >
            <div className="h-full rounded-full bg-primary" style={{ width: `${percent}%` }} />
          </div>
          <span className="text-xs font-medium text-muted-foreground">{`${percent}%`}</span>
        </div>
      </div>

      <dl className="grid grid-cols-2 gap-3 border-t border-border pt-4 text-sm">
        <div>
          <dt className="text-xs text-muted-foreground">Transaksi</dt>
          <dd className="font-semibold">{branch.todayTransactions}</dd>
        </div>
        <div>
          <dt className="text-xs text-muted-foreground">Stok menipis</dt>
          <dd className={`font-semibold ${branch.lowStockItems > 0 ? "text-amber-700" : ""}`}>
            {`${branch.lowStockItems} produk`}
          </dd>
        </div>
      </dl>
    </article>
  );
}
