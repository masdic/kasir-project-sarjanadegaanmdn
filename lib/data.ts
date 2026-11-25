export type Category = "Kelapa" | "Es Cup" | "Lainnya";

export type Product = {
  id: number;
  code: string;
  name: string;
  category: Category;
  price: number;
  stock: number;
  unit: string;
};

export type PaymentMethod = "TUNAI" | "QRIS";

export type TransactionItem = {
  productName: string;
  price: number;
  quantity: number;
};

export type Transaction = {
  invoice: string;
  time: string;
  method: PaymentMethod;
  paid: number;
  items: TransactionItem[];
};

export type Expense = {
  id: number;
  time: string;
  category: string;
  amount: number;
  notes: string;
};

export const STORE = {
  name: "Sarjana Degan",
  branch: "Cabang 1 - Alun-Alun Madiun",
  address: "Jl. Pahlawan No. 12, Madiun",
  phone: "0812-3456-7890",
  footer: "Terima Kasih Atas Kunjungan Anda",
};

export type Branch = {
  id: number;
  name: string;
  area: string;
  address: string;
  todayRevenue: number;
  todayTransactions: number;
  lowStockItems: number;
};

export const BRANCHES: Branch[] = [
  {
    id: 1,
    name: "Cabang 1",
    area: "Alun-Alun Madiun",
    address: "Jl. Pahlawan No. 12, Madiun",
    todayRevenue: 486000,
    todayTransactions: 38,
    lowStockItems: 2,
  },
  {
    id: 2,
    name: "Cabang 2",
    area: "Pasar Besar",
    address: "Jl. Sudirman No. 45, Madiun",
    todayRevenue: 312000,
    todayTransactions: 26,
    lowStockItems: 1,
  },
];

export const PRODUCTS: Product[] = [
  { id: 1, code: "PRD-001", name: "Kelapa Muda Ijo", category: "Kelapa", price: 12000, stock: 24, unit: "Butir" },
  { id: 2, code: "PRD-002", name: "Kelapa Kupas", category: "Kelapa", price: 15000, stock: 8, unit: "Butir" },
  { id: 3, code: "PRD-003", name: "Kelapa Bakar", category: "Kelapa", price: 18000, stock: 3, unit: "Butir" },
  { id: 4, code: "PRD-004", name: "Es Cup Degan Original", category: "Es Cup", price: 5000, stock: 45, unit: "Cup" },
  { id: 5, code: "PRD-005", name: "Es Cup Gula Jawa", category: "Es Cup", price: 6000, stock: 30, unit: "Cup" },
  { id: 6, code: "PRD-006", name: "Es Cup Susu", category: "Es Cup", price: 7000, stock: 0, unit: "Cup" },
  { id: 7, code: "PRD-007", name: "Air Mineral", category: "Lainnya", price: 4000, stock: 20, unit: "Botol" },
  { id: 8, code: "PRD-008", name: "Tambah Es Batu", category: "Lainnya", price: 1000, stock: 99, unit: "Porsi" },
];

export const TRANSACTIONS: Transaction[] = [
  {
    invoice: "TRX-20261126-005",
    time: "14:32",
    method: "TUNAI",
    paid: 50000,
    items: [
      { productName: "Kelapa Muda Ijo", price: 12000, quantity: 2 },
      { productName: "Es Cup Gula Jawa", price: 6000, quantity: 3 },
    ],
  },
  {
    invoice: "TRX-20261126-004",
    time: "13:10",
    method: "QRIS",
    paid: 15000,
    items: [{ productName: "Kelapa Kupas", price: 15000, quantity: 1 }],
  },
  {
    invoice: "TRX-20261126-003",
    time: "11:47",
    method: "TUNAI",
    paid: 20000,
    items: [
      { productName: "Es Cup Degan Original", price: 5000, quantity: 3 },
      { productName: "Tambah Es Batu", price: 1000, quantity: 2 },
    ],
  },
  {
    invoice: "TRX-20261126-002",
    time: "10:05",
    method: "TUNAI",
    paid: 100000,
    items: [
      { productName: "Kelapa Bakar", price: 18000, quantity: 2 },
      { productName: "Air Mineral", price: 4000, quantity: 2 },
    ],
  },
  {
    invoice: "TRX-20261126-001",
    time: "08:21",
    method: "QRIS",
    paid: 12000,
    items: [{ productName: "Kelapa Muda Ijo", price: 12000, quantity: 1 }],
  },
];

export const EXPENSE_CATEGORIES = ["Es Batu", "Cup & Sedotan", "Plastik/Kresek", "Operasional"];

export const EXPENSES: Expense[] = [
  { id: 1, time: "07:30", category: "Es Batu", amount: 25000, notes: "2 balok es" },
  { id: 2, time: "09:15", category: "Cup & Sedotan", amount: 18000, notes: "1 pak cup 50 pcs" },
  { id: 3, time: "12:00", category: "Plastik/Kresek", amount: 7000, notes: "" },
];

export const CUPS_PER_COCONUT = 3;

export function formatRupiah(value: number) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    maximumFractionDigits: 0,
  }).format(value);
}

export function transactionTotal(tx: Transaction) {
  return tx.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
