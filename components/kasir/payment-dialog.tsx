"use client";

import { useState } from "react";
import { Banknote, CheckCircle2, QrCode, X } from "lucide-react";
import { formatRupiah, type PaymentMethod } from "@/lib/data";

const QUICK_CASH = [20000, 50000, 100000];

type Props = {
  total: number;
  onClose: () => void;
  onPaid: () => void;
};

export function PaymentDialog({ total, onClose, onPaid }: Props) {
  const [method, setMethod] = useState<PaymentMethod>("TUNAI");
  const [cash, setCash] = useState(0);
  const [done, setDone] = useState(false);

  const paid = method === "QRIS" ? total : cash;
  const change = paid - total;
  const canPay = paid >= total;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="payment-title"
      className="fixed inset-0 z-50 flex items-end justify-center bg-foreground/40 p-0 sm:items-center sm:p-4"
    >
      <div className="flex w-full max-w-md flex-col gap-5 rounded-t-2xl bg-card p-5 sm:rounded-2xl">
        {done ? (
          <div className="flex flex-col items-center gap-3 py-6 text-center">
            <CheckCircle2 className="size-14 text-primary" aria-hidden="true" />
            <h2 id="payment-title" className="text-lg font-semibold">
              Pembayaran Berhasil
            </h2>
            <p className="text-sm text-muted-foreground">
              {method === "TUNAI" ? `Kembalian ${formatRupiah(change)}` : "Dibayar lewat QRIS"}
            </p>
            <button
              type="button"
              onClick={onPaid}
              className="mt-2 w-full rounded-xl bg-primary py-3.5 font-semibold text-primary-foreground"
            >
              Transaksi Baru
            </button>
          </div>
        ) : (
          <>
            <div className="flex items-center justify-between">
              <h2 id="payment-title" className="text-lg font-semibold">
                Pembayaran
              </h2>
              <button
                type="button"
                onClick={onClose}
                aria-label="Tutup"
                className="rounded-md p-1.5 text-muted-foreground hover:bg-muted"
              >
                <X className="size-5" aria-hidden="true" />
              </button>
            </div>

            <div className="rounded-xl bg-primary-soft p-4 text-center">
              <p className="text-sm text-muted-foreground">Total Belanja</p>
              <p className="text-3xl font-bold text-primary tabular-nums">{formatRupiah(total)}</p>
            </div>

            <div className="grid grid-cols-2 gap-2" role="radiogroup" aria-label="Metode pembayaran">
              {(
                [
                  { value: "TUNAI", label: "Tunai", icon: Banknote },
                  { value: "QRIS", label: "QRIS / Transfer", icon: QrCode },
                ] as const
              ).map(({ value, label, icon: Icon }) => (
                <button
                  key={value}
                  type="button"
                  role="radio"
                  aria-checked={method === value}
                  onClick={() => setMethod(value)}
                  className={`flex items-center justify-center gap-2 rounded-xl border py-3 text-sm font-medium ${
                    method === value
                      ? "border-primary bg-primary-soft text-primary"
                      : "border-border text-muted-foreground"
                  }`}
                >
                  <Icon className="size-5" aria-hidden="true" />
                  {label}
                </button>
              ))}
            </div>

            {method === "TUNAI" && (
              <div className="flex flex-col gap-3">
                <div className="grid grid-cols-4 gap-2">
                  <button
                    type="button"
                    onClick={() => setCash(total)}
                    className="rounded-lg border border-border py-2.5 text-sm font-medium hover:border-primary"
                  >
                    Uang Pas
                  </button>
                  {QUICK_CASH.map((amount) => (
                    <button
                      key={amount}
                      type="button"
                      onClick={() => setCash(amount)}
                      className="rounded-lg border border-border py-2.5 text-sm font-medium hover:border-primary"
                    >
                      {amount / 1000}rb
                    </button>
                  ))}
                </div>
                <label className="flex flex-col gap-1.5">
                  <span className="text-sm font-medium">Uang Diterima</span>
                  <input
                    type="number"
                    inputMode="numeric"
                    min={0}
                    value={cash || ""}
                    onChange={(e) => setCash(Number(e.target.value))}
                    placeholder="0"
                    className="rounded-lg border border-border px-3 py-2.5 text-lg font-semibold tabular-nums outline-none focus:border-primary focus:ring-2 focus:ring-primary/20"
                  />
                </label>
                <div className="flex items-center justify-between rounded-lg bg-muted px-4 py-3">
                  <span className="text-sm text-muted-foreground">Kembalian</span>
                  <span
                    className={`text-lg font-bold tabular-nums ${canPay ? "text-foreground" : "text-danger"}`}
                  >
                    {canPay ? formatRupiah(change) : "Uang kurang"}
                  </span>
                </div>
              </div>
            )}

            <button
              type="button"
              disabled={!canPay}
              onClick={() => setDone(true)}
              className="w-full rounded-xl bg-primary py-4 font-semibold text-primary-foreground disabled:opacity-40"
            >
              Simpan &amp; Cetak Struk
            </button>
          </>
        )}
      </div>
    </div>
  );
}
