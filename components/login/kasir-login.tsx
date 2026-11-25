"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { MapPin } from "lucide-react";
import { BRANCHES } from "@/lib/data";
import { PinPad } from "@/components/login/pin-pad";

const PIN_MIN = 4;
const PIN_MAX = 6;

export function KasirLogin() {
  const router = useRouter();
  const [branchId, setBranchId] = useState(BRANCHES[0].id);
  const [pin, setPin] = useState("");

  const canSubmit = pin.length >= PIN_MIN;

  function handleDigit(digit: string) {
    setPin((current) => (current.length < PIN_MAX ? current + digit : current));
  }

  function handleSubmit() {
    if (!canSubmit) return;
    router.push("/");
  }

  return (
    <div className="flex flex-col gap-4">
      <fieldset>
        <legend className="text-sm font-medium">Cabang</legend>
        <div className="mt-2 grid grid-cols-2 gap-2">
          {BRANCHES.map((branch) => {
            const selected = branch.id === branchId;
            return (
              <label
                key={branch.id}
                className={`flex cursor-pointer flex-col gap-0.5 rounded-xl border px-3 py-2.5 transition-colors has-[:focus-visible]:ring-2 has-[:focus-visible]:ring-primary ${
                  selected ? "border-primary bg-primary-soft" : "border-border bg-card hover:bg-muted"
                }`}
              >
                <input
                  type="radio"
                  name="branch"
                  value={branch.id}
                  checked={selected}
                  onChange={() => setBranchId(branch.id)}
                  className="sr-only"
                />
                <span className={`text-sm font-semibold ${selected ? "text-primary" : ""}`}>
                  {branch.name}
                </span>
                <span className="flex items-center gap-1 text-xs text-muted-foreground">
                  <MapPin className="size-3" aria-hidden="true" />
                  {branch.area}
                </span>
              </label>
            );
          })}
        </div>
      </fieldset>

      <div className="flex items-center justify-between">
        <p id="pin-label" className="text-sm font-medium">
          PIN Kasir
        </p>
        <div
          role="status"
          aria-labelledby="pin-label"
          aria-live="polite"
          className="flex gap-2.5"
        >
          <span className="sr-only">{`${pin.length} dari ${PIN_MAX} digit terisi`}</span>
          {Array.from({ length: PIN_MAX }, (_, index) => (
            <span
              key={index}
              aria-hidden="true"
              className={`size-3.5 rounded-full border-2 transition-colors ${
                index < pin.length ? "border-primary bg-primary" : "border-border bg-card"
              }`}
            />
          ))}
        </div>
      </div>

      <PinPad
        onDigit={handleDigit}
        onDelete={() => setPin((current) => current.slice(0, -1))}
        onClear={() => setPin("")}
        onSubmit={handleSubmit}
      />

      <button
        type="button"
        onClick={handleSubmit}
        disabled={!canSubmit}
        className="h-12 rounded-xl bg-primary text-sm font-semibold text-primary-foreground transition-opacity hover:opacity-90 disabled:opacity-40"
      >
        {`Masuk ke ${BRANCHES.find((branch) => branch.id === branchId)?.name ?? "Kasir"}`}
      </button>
    </div>
  );
}
