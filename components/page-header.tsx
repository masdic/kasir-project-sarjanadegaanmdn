export function PageHeader({ title, description }: { title: string; description: string }) {
  return (
    <div className="flex flex-col gap-1">
      <h1 className="text-xl font-semibold text-balance md:text-2xl">{title}</h1>
      <p className="text-sm text-muted-foreground text-pretty">{description}</p>
    </div>
  );
}
