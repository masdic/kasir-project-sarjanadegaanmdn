"use client";

import { useState } from "react";
import { Search } from "lucide-react";
import { formatRupiah, type Category, type Product } from "@/lib/data";

const FILTERS: ("Semua" | Category)[] = ["Semua", "Kelapa", "Es Cup", "Lainnya"];

type Props = {
  products: Product[];
  cart: Record<number, number>;
  onAdd: (product: Product) => void;
};

export function ProductGrid({ products, cart, onAdd }: Props) {
  const [filter, setFilter] = useState<(typeof FILTERS)[number]>("Semua");
  const [query, setQuery] = useState("");

  const visible = products.filter(
    (p) =>
      (filter === "Semua" || p.category === filter) &&
      p.name.toLowerCase().includes(query.toLowerCase()),
  );

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex gap-2 overflow-x-auto" role="group" aria-label="Filter kategori">
          {FILTERS.map((f) => (
            <button
              key={f}
              type="button"
              onClick={() => setFilter(f)}
              aria-pressed={filter === f}
              className={`shrink-0 rounded-full border px-4 py-1.5 text-sm font-medium transition-colors ${
                filter === f
                  ? "border-primary bg-primary text-primary-foreground"
                  : "border-border bg-card text-muted-foreground hover:text-foreground"
              }`}
            >
              {f}
            </button>
          ))}
        </div>
        <label className="relative sm:w-64">
          <span className="sr-only">Cari produk</span>
          <Search
            className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground"
            aria-hidden="true"
          />
          <input
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Cari produk..."
            className="w-full rounded-lg border border-border bg-card py-2 pr-3 pl-9 text-sm outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
          />
        </label>
      </div>

      <ul className="grid grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-4">
        {visible.map((p) => {
          const inCart = cart[p.id] ?? 0;
          const soldOut = p.stock === 0;
          const lowStock = p.stock > 0 && p.stock <= 5;
          return (
            <li key={p.id}>
              <button
                type="button"
                disabled={soldOut || inCart >= p.stock}
                onClick={() => onAdd(p)}
                className={`relative flex h-full w-full flex-col gap-3 rounded-xl border bg-card p-3 text-left transition-all active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-50 ${
                  inCart ? "border-primary ring-2 ring-primary/20" : "border-border hover:border-primary/50"
                }`}
              >
                <div className="flex items-start justify-between gap-2">
                  <span className="flex size-11 items-center justify-center rounded-lg bg-primary-soft text-sm font-bold text-primary">
                    {p.name
                      .split(" ")
                      .slice(0, 2)
                      .map((w) => w[0])
                      .join("")}
                  </span>
                  {inCart > 0 && (
                    <span className="rounded-full bg-primary px-2 py-0.5 text-xs font-semibold text-primary-foreground">
                      {inCart}
                    </span>
                  )}
                </div>
                <div className="flex flex-1 flex-col gap-1">
                  <p className="text-sm leading-snug font-medium">{p.name}</p>
                  <p className="font-semibold text-primary">{formatRupiah(p.price)}</p>
                </div>
                <span
                  className={`w-fit rounded-md px-2 py-0.5 text-xs font-medium ${
                    soldOut
                      ? "bg-muted text-danger"
                      : lowStock
                        ? "bg-warning-soft text-warning"
                        : "bg-muted text-muted-foreground"
                  }`}
                >
                  {soldOut ? "Habis" : `Stok ${p.stock} ${p.unit}`}
                </span>
              </button>
            </li>
          );
        })}
      </ul>

      {visible.length === 0 && (
        <p className="py-12 text-center text-sm text-muted-foreground">Produk tidak ditemukan.</p>
      )}
    </div>
  );
}
