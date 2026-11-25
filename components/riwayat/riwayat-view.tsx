"use client";

import { useState } from "react";
import { ChevronRight } from "lucide-react";
import { formatRupiah, transactionTotal, type Transaction } from "@/lib/data";
import { Receipt } from "./receipt";

export function RiwayatView({ transactions }: { transactions: Transaction[] }) {
  const [selected, setSelected] = useState<Transaction | null>(transactions[0] ?? null);

  return (
    <div className="flex flex-col gap-5 lg:flex-row lg:items-start">
      <ul className="flex flex-1 flex-col divide-y divide-border overflow-hidden rounded-xl border border-border bg-card">
        {transactions.map((tx) => {
          const active = selected?.invoice === tx.invoice;
          return (
            <li key={tx.invoice}>
              <button
                type="button"
                onClick={() => setSelected(tx)}
                aria-current={active ? "true" : undefined}
                className={`flex w-full items-center gap-4 px-4 py-3.5 text-left transition-colors ${
                  active ? "bg-primary-soft" : "hover:bg-muted"
                }`}
              >
                <span className="font-mono text-sm text-muted-foreground tabular-nums">{tx.time}</span>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium">{tx.invoice}</p>
                  <p className="text-xs text-muted-foreground">
                    {tx.items.reduce((s, i) => s + i.quantity, 0)} item
                  </p>
                </div>
                <span
                  className={`rounded-md px-2 py-0.5 text-xs font-medium ${
                    tx.method === "TUNAI" ? "bg-muted text-muted-foreground" : "bg-primary-soft text-primary"
                  }`}
                >
                  {tx.method}
                </span>
                <span className="w-24 text-right text-sm font-semibold tabular-nums">
                  {formatRupiah(transactionTotal(tx))}
                </span>
                <ChevronRight className="size-4 text-muted-foreground" aria-hidden="true" />
              </button>
            </li>
          );
        })}
      </ul>

      {selected && (
        <div className="lg:sticky lg:top-6 lg:w-80">
          <Receipt transaction={selected} />
        </div>
      )}
    </div>
  );
}
