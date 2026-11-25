"use client";

import { Minus, Plus, ShoppingCart, Trash2, X } from "lucide-react";
import { formatRupiah, type Product } from "@/lib/data";

export type CartLine = { product: Product; quantity: number };

type Props = {
  lines: CartLine[];
  total: number;
  onChange: (product: Product, delta: number) => void;
  onClear: () => void;
  onPay: () => void;
  onClose?: () => void;
};

export function CartPanel({ lines, total, onChange, onClear, onPay, onClose }: Props) {
  return (
    <div className="flex w-full flex-col">
      <div className="flex items-center justify-between border-b border-border px-5 py-4">
        <h2 className="font-semibold">Keranjang</h2>
        <div className="flex items-center gap-1">
          {lines.length > 0 && (
            <button
              type="button"
              onClick={onClear}
              className="flex items-center gap-1 rounded-md px-2 py-1 text-xs font-medium text-danger hover:bg-muted"
            >
              <Trash2 className="size-3.5" aria-hidden="true" />
              Kosongkan
            </button>
          )}
          {onClose && (
            <button
              type="button"
              onClick={onClose}
              aria-label="Tutup keranjang"
              className="rounded-md p-1.5 text-muted-foreground hover:bg-muted"
            >
              <X className="size-5" aria-hidden="true" />
            </button>
          )}
        </div>
      </div>

      {lines.length === 0 ? (
        <div className="flex flex-1 flex-col items-center justify-center gap-2 p-8 text-center text-muted-foreground">
          <ShoppingCart className="size-10" aria-hidden="true" />
          <p className="text-sm">Keranjang masih kosong.</p>
          <p className="text-xs">Ketuk produk di sebelah kiri untuk menambahkan.</p>
        </div>
      ) : (
        <ul className="flex-1 divide-y divide-border overflow-y-auto px-5">
          {lines.map(({ product, quantity }) => (
            <li key={product.id} className="flex items-center gap-3 py-3">
              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-medium">{product.name}</p>
                <p className="text-xs text-muted-foreground">
                  {formatRupiah(product.price)} × {quantity}
                </p>
              </div>
              <div className="flex items-center gap-1">
                <button
                  type="button"
                  onClick={() => onChange(product, -1)}
                  aria-label={`Kurangi ${product.name}`}
                  className="flex size-8 items-center justify-center rounded-md border border-border hover:bg-muted"
                >
                  <Minus className="size-4" aria-hidden="true" />
                </button>
                <span className="w-7 text-center text-sm font-semibold tabular-nums">{quantity}</span>
                <button
                  type="button"
                  onClick={() => onChange(product, 1)}
                  disabled={quantity >= product.stock}
                  aria-label={`Tambah ${product.name}`}
                  className="flex size-8 items-center justify-center rounded-md border border-border hover:bg-muted disabled:opacity-40"
                >
                  <Plus className="size-4" aria-hidden="true" />
                </button>
              </div>
              <p className="w-20 text-right text-sm font-semibold tabular-nums">
                {formatRupiah(product.price * quantity)}
              </p>
            </li>
          ))}
        </ul>
      )}

      <div className="flex flex-col gap-3 border-t border-border p-5">
        <div className="flex items-center justify-between">
          <span className="text-sm text-muted-foreground">Total</span>
          <span className="text-2xl font-bold tabular-nums">{formatRupiah(total)}</span>
        </div>
        <button
          type="button"
          onClick={onPay}
          disabled={lines.length === 0}
          className="w-full rounded-xl bg-primary py-4 text-base font-semibold text-primary-foreground transition-opacity hover:opacity-90 disabled:opacity-40"
        >
          BAYAR SEKARANG
        </button>
      </div>
    </div>
  );
}
