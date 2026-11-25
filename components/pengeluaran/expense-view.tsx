"use client";

import { useState } from "react";
import { EXPENSE_CATEGORIES, formatRupiah, type Expense } from "@/lib/data";

export function ExpenseView({ initialExpenses }: { initialExpenses: Expense[] }) {
  const [expenses, setExpenses] = useState(initialExpenses);
  const [category, setCategory] = useState(EXPENSE_CATEGORIES[0]);
  const [amount, setAmount] = useState("");
  const [notes, setNotes] = useState("");

  const total = expenses.reduce((s, e) => s + e.amount, 0);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const value = Number(amount);
    if (!value || value <= 0) return;
    setExpenses((prev) => [
      {
        id: Date.now(),
        time: new Date().toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" }),
        category,
        amount: value,
        notes: notes.trim(),
      },
      ...prev,
    ]);
    setAmount("");
    setNotes("");
  }

  return (
    <div className="flex flex-col gap-5 lg:flex-row lg:items-start">
      <form onSubmit={handleSubmit} className="flex flex-col gap-4 rounded-xl border border-border bg-card p-5 lg:w-80">
        <h2 className="font-semibold">Tambah Pengeluaran</h2>
        <fieldset className="flex flex-col gap-2">
          <legend className="mb-2 text-sm font-medium">Kategori</legend>
          <div className="grid grid-cols-2 gap-2">
            {EXPENSE_CATEGORIES.map((c) => (
              <button
                key={c}
                type="button"
                aria-pressed={category === c}
                onClick={() => setCategory(c)}
                className={`rounded-lg border px-2 py-2 text-sm font-medium ${
                  category === c
                    ? "border-primary bg-primary-soft text-primary"
                    : "border-border text-muted-foreground"
                }`}
              >
                {c}
              </button>
            ))}
          </div>
        </fieldset>
        <label className="flex flex-col gap-1.5">
          <span className="text-sm font-medium">Nominal (Rp)</span>
          <input
            type="number"
            inputMode="numeric"
            min={1}
            required
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="25000"
            className="rounded-lg border border-border px-3 py-2.5 tabular-nums outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
          />
        </label>
        <label className="flex flex-col gap-1.5">
          <span className="text-sm font-medium">Catatan (opsional)</span>
          <input
            type="text"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Contoh: 2 balok es"
            className="rounded-lg border border-border px-3 py-2.5 outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
          />
        </label>
        <button type="submit" className="rounded-xl bg-primary py-3.5 font-semibold text-primary-foreground hover:opacity-90">
          Simpan Pengeluaran
        </button>
      </form>

      <section aria-labelledby="expense-list-title" className="flex flex-1 flex-col overflow-hidden rounded-xl border border-border bg-card">
        <div className="flex items-center justify-between border-b border-border px-4 py-3">
          <h2 id="expense-list-title" className="font-semibold">Pengeluaran Hari Ini</h2>
          <span className="text-sm font-semibold text-danger tabular-nums">{formatRupiah(total)}</span>
        </div>
        <ul className="divide-y divide-border">
          {expenses.map((e) => (
            <li key={e.id} className="flex items-center gap-4 px-4 py-3">
              <span className="font-mono text-sm text-muted-foreground tabular-nums">{e.time}</span>
              <div className="min-w-0 flex-1">
                <p className="text-sm font-medium">{e.category}</p>
                {e.notes && <p className="truncate text-xs text-muted-foreground">{e.notes}</p>}
              </div>
              <span className="text-sm font-semibold tabular-nums">{formatRupiah(e.amount)}</span>
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
