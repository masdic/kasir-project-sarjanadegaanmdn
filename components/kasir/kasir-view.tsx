"use client";

import { useMemo, useState } from "react";
import { ShoppingCart } from "lucide-react";
import { formatRupiah, type Product } from "@/lib/data";
import { ProductGrid } from "./product-grid";
import { CartPanel, type CartLine } from "./cart-panel";
import { PaymentDialog } from "./payment-dialog";

export function KasirView({ products }: { products: Product[] }) {
  const [cart, setCart] = useState<Record<number, number>>({});
  const [paymentOpen, setPaymentOpen] = useState(false);
  const [cartOpenMobile, setCartOpenMobile] = useState(false);

  const lines: CartLine[] = useMemo(
    () =>
      products
        .filter((p) => cart[p.id])
        .map((p) => ({ product: p, quantity: cart[p.id] })),
    [products, cart],
  );

  const total = lines.reduce((sum, l) => sum + l.product.price * l.quantity, 0);
  const itemCount = lines.reduce((sum, l) => sum + l.quantity, 0);

  function changeQuantity(product: Product, delta: number) {
    setCart((prev) => {
      const next = Math.min(Math.max((prev[product.id] ?? 0) + delta, 0), product.stock);
      const copy = { ...prev };
      if (next === 0) delete copy[product.id];
      else copy[product.id] = next;
      return copy;
    });
  }

  function handlePaid() {
    setCart({});
    setPaymentOpen(false);
    setCartOpenMobile(false);
  }

  return (
    <div className="flex h-full flex-col lg:flex-row">
      <section aria-label="Katalog produk" className="flex-1 p-4 md:p-6">
        <ProductGrid products={products} cart={cart} onAdd={(p) => changeQuantity(p, 1)} />
      </section>

      <aside
        aria-label="Keranjang belanja"
        className="hidden w-96 shrink-0 border-l border-border bg-card lg:flex"
      >
        <CartPanel
          lines={lines}
          total={total}
          onChange={changeQuantity}
          onClear={() => setCart({})}
          onPay={() => setPaymentOpen(true)}
        />
      </aside>

      {itemCount > 0 && (
        <div className="fixed inset-x-0 bottom-16 z-20 p-3 lg:hidden">
          <button
            type="button"
            onClick={() => setCartOpenMobile(true)}
            className="flex w-full items-center justify-between rounded-xl bg-primary px-4 py-3.5 text-primary-foreground shadow-lg"
          >
            <span className="flex items-center gap-2 text-sm font-medium">
              <ShoppingCart className="size-5" aria-hidden="true" />
              {itemCount} item
            </span>
            <span className="font-semibold">Lihat Keranjang · {formatRupiah(total)}</span>
          </button>
        </div>
      )}

      {cartOpenMobile && (
        <div className="fixed inset-0 z-40 flex flex-col justify-end bg-foreground/40 lg:hidden">
          <button
            type="button"
            aria-label="Tutup keranjang"
            className="flex-1"
            onClick={() => setCartOpenMobile(false)}
          />
          <div className="flex max-h-[85dvh] rounded-t-2xl bg-card">
            <CartPanel
              lines={lines}
              total={total}
              onChange={changeQuantity}
              onClear={() => setCart({})}
              onPay={() => setPaymentOpen(true)}
              onClose={() => setCartOpenMobile(false)}
            />
          </div>
        </div>
      )}

      {paymentOpen && (
        <PaymentDialog total={total} onClose={() => setPaymentOpen(false)} onPaid={handlePaid} />
      )}
    </div>
  );
}
