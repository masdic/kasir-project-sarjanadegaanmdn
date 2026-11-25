"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Eye, EyeOff } from "lucide-react";

const inputClass =
  "h-12 w-full rounded-xl border border-border bg-card px-3 text-sm outline-none transition-colors focus:border-primary focus:ring-2 focus:ring-primary/30";

export function OwnerLogin() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);

  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    router.push("/owner");
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-4">
      <div className="flex flex-col gap-1.5">
        <label htmlFor="owner-email" className="text-sm font-medium">
          Email
        </label>
        <input
          id="owner-email"
          name="email"
          type="email"
          required
          autoComplete="email"
          placeholder="owner@sarjanadegan.id"
          className={inputClass}
        />
      </div>

      <div className="flex flex-col gap-1.5">
        <label htmlFor="owner-password" className="text-sm font-medium">
          Password
        </label>
        <div className="relative">
          <input
            id="owner-password"
            name="password"
            type={showPassword ? "text" : "password"}
            required
            minLength={8}
            autoComplete="current-password"
            placeholder="Minimal 8 karakter"
            className={`${inputClass} pr-12`}
          />
          <button
            type="button"
            onClick={() => setShowPassword((value) => !value)}
            aria-label={showPassword ? "Sembunyikan password" : "Tampilkan password"}
            aria-pressed={showPassword}
            className="absolute inset-y-0 right-0 flex w-12 items-center justify-center text-muted-foreground hover:text-foreground"
          >
            {showPassword ? (
              <EyeOff className="size-4" aria-hidden="true" />
            ) : (
              <Eye className="size-4" aria-hidden="true" />
            )}
          </button>
        </div>
      </div>

      <button
        type="submit"
        className="mt-2 h-12 rounded-xl bg-primary text-sm font-semibold text-primary-foreground transition-opacity hover:opacity-90"
      >
        Masuk sebagai Owner
      </button>
    </form>
  );
}
