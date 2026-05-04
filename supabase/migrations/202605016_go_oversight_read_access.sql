-- Allow the General Overseer to see the live oversight dashboard without granting admin write powers.
-- This is read-only RLS access for Command Center and Weekly Compliance counts.

create policy "general overseer can read workflow oversight reports"
on public.reports for select
to authenticated
using (
  public.current_profile_role() = 'general_overseer'
  and stage in (
    'awaiting_administration',
    'awaiting_ago',
    'awaiting_general_overseer',
    'returned_for_revision',
    'approved'
  )
);

create policy "general overseer can read workflow outcome notices"
on public.report_inbox_notices for select
to authenticated
using (public.current_profile_role() = 'general_overseer');
