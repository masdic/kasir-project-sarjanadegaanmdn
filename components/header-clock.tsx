"use client";

import { useEffect, useState } from "react";

export function HeaderClock() {
  const [now, setNow] = useState<Date | null>(null);

  useEffect(() => {
    setNow(new Date());
    const timer = setInterval(() => setNow(new Date()), 1000 * 30);
    return () => clearInterval(timer);
  }, []);

  if (!now) return <div className="h-9 w-28" aria-hidden="true" />;

  return (
    <div className="shrink-0 text-right leading-tight">
      <p className="font-mono text-sm font-semibold tabular-nums md:text-base">
        {now.toLocaleTimeString("id-ID", { hour: "2-digit", minute: "2-digit" })}
      </p>
      <p className="text-xs text-muted-foreground">
        {now.toLocaleDateString("id-ID", { weekday: "long", day: "numeric", month: "short" })}
      </p>
    </div>
  );
}
