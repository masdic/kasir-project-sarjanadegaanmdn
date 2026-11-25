import { Printer, Share2 } from "lucide-react";
import { STORE, formatRupiah, transactionTotal, type Transaction } from "@/lib/data";

export function Receipt({ transaction }: { transaction: Transaction }) {
  const total = transactionTotal(transaction);

  return (
    <article aria-label={`Struk ${transaction.invoice}`} className="flex flex-col gap-3">
      <div className="flex flex-col gap-3 rounded-xl border border-dashed border-border bg-card p-5 font-mono text-xs">
        <div className="text-center">
          <p className="text-sm font-bold">{STORE.name.toUpperCase()}</p>
          <p className="text-muted-foreground">{STORE.branch}</p>
          <p className="text-muted-foreground">{STORE.phone}</p>
        </div>
        <div className="flex justify-between border-y border-dashed border-border py-2 text-muted-foreground">
          <span>{transaction.invoice}</span>
          <span>{transaction.time}</span>
        </div>
        <ul className="flex flex-col gap-2">
          {transaction.items.map((item) => (
            <li key={item.productName}>
              <p>{item.productName}</p>
              <div className="flex justify-between text-muted-foreground">
                <span>
                  {item.quantity} × {formatRupiah(item.price)}
                </span>
                <span className="text-foreground">{formatRupiah(item.price * item.quantity)}</span>
              </div>
            </li>
          ))}
        </ul>
        <div className="flex flex-col gap-1 border-t border-dashed border-border pt-2">
          <div className="flex justify-between font-bold">
            <span>TOTAL</span>
            <span>{formatRupiah(total)}</span>
          </div>
          <div className="flex justify-between">
            <span>Bayar ({transaction.method})</span>
            <span>{formatRupiah(transaction.paid)}</span>
          </div>
          <div className="flex justify-between">
            <span>Kembali</span>
            <span>{formatRupiah(transaction.paid - total)}</span>
          </div>
        </div>
        <p className="border-t border-dashed border-border pt-2 text-center text-muted-foreground">
          {STORE.footer}
        </p>
      </div>
      <div className="grid grid-cols-2 gap-2">
        <button
          type="button"
          className="flex items-center justify-center gap-2 rounded-lg border border-border bg-card py-2.5 text-sm font-medium hover:bg-muted"
        >
          <Share2 className="size-4" aria-hidden="true" />
          Bagikan
        </button>
        <button
          type="button"
          className="flex items-center justify-center gap-2 rounded-lg bg-primary py-2.5 text-sm font-medium text-primary-foreground"
        >
          <Printer className="size-4" aria-hidden="true" />
          Cetak
        </button>
      </div>
    </article>
  );
}
