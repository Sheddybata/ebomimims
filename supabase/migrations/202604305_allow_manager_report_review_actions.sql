create policy "managers update awaiting manager reports"
on public.reports for update
to authenticated
using (
  public.current_profile_role() = 'manager'
  and stage = 'awaiting_manager'
  and directorate_id = (select directorate_id from public.profiles where id = auth.uid())
)
with check (
  public.current_profile_role() = 'manager'
  and stage in ('awaiting_director', 'revision_requested')
  and directorate_id = (select directorate_id from public.profiles where id = auth.uid())
);

create policy "same directorate reviewers add report timeline"
on public.report_timeline for insert
to authenticated
with check (
  actor_id = auth.uid()
  and actor_role = public.current_profile_role()
  and exists (
    select 1
    from public.reports r
    join public.profiles p on p.id = auth.uid()
    where r.id = report_id
      and r.directorate_id = p.directorate_id
  )
);
