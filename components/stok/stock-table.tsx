import { formatRupiah, type Product } from "@/lib/data";

export function StockTable({ products }: { products: Product[] }) {
  return (
    <div className="overflow-x-auto rounded-xl border border-border bg-card">
      <table className="w-full text-sm">
        <thead className="bg-muted text-left text-xs text-muted-foreground">
          <tr>
            <th scope="col" className="px-4 py-3 font-medium">Produk</th>
            <th scope="col" className="px-4 py-3 font-medium">Kategori</th>
            <th scope="col" className="px-4 py-3 text-right font-medium">Harga</th>
            <th scope="col" className="px-4 py-3 text-right font-medium">Stok</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {products.map((p) => (
            <tr key={p.id}>
              <td className="px-4 py-3">
                <p className="font-medium">{p.name}</p>
                <p className="text-xs text-muted-foreground">{p.code}</p>
              </td>
              <td className="px-4 py-3 text-muted-foreground">{p.category}</td>
              <td className="px-4 py-3 text-right tabular-nums">{formatRupiah(p.price)}</td>
              <td className="px-4 py-3 text-right">
                <span
                  className={`rounded-md px-2 py-0.5 text-xs font-semibold tabular-nums ${
                    p.stock === 0
                      ? "bg-muted text-danger"
                      : p.stock <= 5
                        ? "bg-warning-soft text-warning"
                        : "bg-primary-soft text-primary"
                  }`}
                >
                  {p.stock} {p.unit}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
