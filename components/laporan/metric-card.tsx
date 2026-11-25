type Props = {
  label: string;
  value: string;
  hint: string;
  tone?: "default" | "primary" | "danger";
};

export function MetricCard({ label, value, hint, tone = "default" }: Props) {
  const styles = {
    default: "border-border bg-card",
    primary: "border-primary bg-primary text-primary-foreground",
    danger: "border-border bg-card",
  }[tone];

  return (
    <div className={`flex flex-col gap-1 rounded-xl border p-5 ${styles}`}>
      <p className={`text-sm ${tone === "primary" ? "opacity-85" : "text-muted-foreground"}`}>{label}</p>
      <p className={`text-2xl font-bold tabular-nums ${tone === "danger" ? "text-danger" : ""}`}>{value}</p>
      <p className={`text-xs ${tone === "primary" ? "opacity-85" : "text-muted-foreground"}`}>{hint}</p>
    </div>
  );
}
