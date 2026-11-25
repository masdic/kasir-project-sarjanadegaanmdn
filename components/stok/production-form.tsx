"use client";

import { useState } from "react";
import { ArrowRight, Minus, Plus } from "lucide-react";
import { CUPS_PER_COCONUT } from "@/lib/data";

export function ProductionForm({ maxCoconut }: { maxCoconut: number }) {
  const [coconut, setCoconut] = useState(1);
  const [saved, setSaved] = useState(false);
  const cups = coconut * CUPS_PER_COCONUT;

  function update(value: number) {
    setSaved(false);
    setCoconut(Math.min(Math.max(value, 1), maxCoconut));
  }

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        setSaved(true);
      }}
      className="flex flex-col gap-4 rounded-xl border border-border bg-card p-5"
    >
      <div>
        <h2 className="font-semibold">Konversi Produksi Es Cup</h2>
        <p className="text-sm text-muted-foreground">Masukkan jumlah kelapa yang dipecah.</p>
      </div>

      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => update(coconut - 1)}
          aria-label="Kurangi kelapa"
          className="flex size-11 items-center justify-center rounded-lg border border-border hover:bg-muted"
        >
          <Minus className="size-4" aria-hidden="true" />
        </button>
        <label className="flex-1">
          <span className="sr-only">Jumlah kelapa (butir)</span>
          <input
            type="number"
            inputMode="numeric"
            min={1}
            max={maxCoconut}
            value={coconut}
            onChange={(e) => update(Number(e.target.value))}
            className="w-full rounded-lg border border-border py-2.5 text-center text-lg font-semibold tabular-nums outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
          />
        </label>
        <button
          type="button"
          onClick={() => update(coconut + 1)}
          aria-label="Tambah kelapa"
          className="flex size-11 items-center justify-center rounded-lg border border-border hover:bg-muted"
        >
          <Plus className="size-4" aria-hidden="true" />
        </button>
      </div>

      <div className="flex items-center justify-between rounded-lg bg-primary-soft px-4 py-3">
        <div className="text-center">
          <p className="text-2xl font-bold tabular-nums">{coconut}</p>
          <p className="text-xs text-muted-foreground">butir kelapa</p>
        </div>
        <ArrowRight className="size-5 text-primary" aria-hidden="true" />
        <div className="text-center">
          <p className="text-2xl font-bold text-primary tabular-nums">{cups}</p>
          <p className="text-xs text-muted-foreground">cup es</p>
        </div>
      </div>

      <button
        type="submit"
        className="rounded-xl bg-primary py-3.5 font-semibold text-primary-foreground hover:opacity-90"
      >
        Simpan Produksi
      </button>
      {saved && (
        <p role="status" className="text-center text-sm text-primary">
          Tercatat: {coconut} kelapa menjadi {cups} cup (belum tersimpan ke database).
        </p>
      )}
    </form>
  );
}
