"use client";

import { useEffect, useEffectEvent } from "react";
import { Delete } from "lucide-react";

type PinPadProps = {
  onDigit: (digit: string) => void;
  onDelete: () => void;
  onClear: () => void;
  onSubmit: () => void;
};

const DIGITS = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

const keyClass =
  "flex h-11 items-center justify-center rounded-xl border border-border bg-card text-lg font-semibold transition-colors hover:bg-muted active:bg-primary-soft focus-visible:outline-2 focus-visible:outline-primary";

export function PinPad({ onDigit, onDelete, onClear, onSubmit }: PinPadProps) {
  const handleKey = useEffectEvent((event: KeyboardEvent) => {
    if (/^[0-9]$/.test(event.key)) onDigit(event.key);
    else if (event.key === "Backspace") onDelete();
    else if (event.key === "Escape") onClear();
    else if (event.key === "Enter") onSubmit();
  });

  useEffect(() => {
    const listener = (event: KeyboardEvent) => handleKey(event);
    window.addEventListener("keydown", listener);
    return () => window.removeEventListener("keydown", listener);
  }, []);

  return (
    <div className="grid grid-cols-3 gap-2" aria-label="Keypad PIN" role="group">
      {DIGITS.map((digit) => (
        <button key={digit} type="button" onClick={() => onDigit(digit)} className={keyClass}>
          {digit}
        </button>
      ))}
      <button
        type="button"
        onClick={onClear}
        className={`${keyClass} text-sm font-medium text-muted-foreground`}
      >
        Hapus
      </button>
      <button type="button" onClick={() => onDigit("0")} className={keyClass}>
        0
      </button>
      <button type="button" onClick={onDelete} className={keyClass} aria-label="Hapus satu digit">
        <Delete className="size-5" aria-hidden="true" />
      </button>
    </div>
  );
}
