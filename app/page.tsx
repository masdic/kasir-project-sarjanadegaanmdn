import { KasirView } from "@/components/kasir/kasir-view";
import { PRODUCTS } from "@/lib/data";

export default function KasirPage() {
  return <KasirView products={PRODUCTS} />;
}
