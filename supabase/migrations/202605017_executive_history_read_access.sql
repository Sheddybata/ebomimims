-- Let NDA and AGO view read-only history for reports that have passed through their desks.
-- This does not grant update/approval powers beyond the existing RPC functions.

create or replace function public.report_has_timeline_action(
  p_report_id uuid,
  p_action public.timeline_action
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.report_timeline rt
    where rt.report_id = p_report_id
      and rt.action = p_action
  );
$$;

grant execute on function public.report_has_timeline_action(uuid, public.timeline_action) to authenticated;

create policy "nda can read reports received by nda"
on public.reports for select
to authenticated
using (
  public.current_profile_role() = 'nda'
  and public.report_has_timeline_action(id, 'submitted_to_nda')
);

create policy "ago can read reports received by ago"
on public.reports for select
to authenticated
using (
  public.current_profile_role() = 'ago'
  and public.report_has_timeline_action(id, 'forwarded_to_ago')
);
