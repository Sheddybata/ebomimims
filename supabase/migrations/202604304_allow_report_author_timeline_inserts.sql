create policy "authors can add timeline to own reports"
on public.report_timeline for insert
to authenticated
with check (
  actor_id = auth.uid()
  and exists (
    select 1 from public.reports r
    where r.id = report_id and r.author_id = auth.uid()
  )
);
