create or replace function public.director_submit_report_to_nda(p_report_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  actor public.profiles%rowtype;
  target public.reports%rowtype;
begin
  select * into actor from public.profiles where id = auth.uid();
  if actor.id is null or actor.role <> 'director' then
    raise exception 'Only directors can submit reports to NDA';
  end if;

  select * into target from public.reports where id = p_report_id;
  if target.id is null then
    raise exception 'Report not found';
  end if;
  if target.stage <> 'awaiting_director' then
    raise exception 'Report is not awaiting director review';
  end if;
  if target.directorate_id <> actor.directorate_id then
    raise exception 'Report is outside your directorate';
  end if;

  update public.reports
  set
    stage = 'awaiting_administration',
    current_reviewer_role = 'nda',
    returned_note = null,
    returned_by = null,
    returned_at = null,
    updated_at = now()
  where id = p_report_id;

  insert into public.report_timeline (
    report_id,
    action,
    label,
    actor_id,
    actor_role,
    actor_name
  )
  values (
    p_report_id,
    'submitted_to_nda',
    'Submitted to NDA',
    actor.id,
    actor.role,
    actor.full_name
  );
end;
$$;

create or replace function public.director_return_report_for_revision(
  p_report_id uuid,
  p_note text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  actor public.profiles%rowtype;
  target public.reports%rowtype;
  clean_note text := btrim(coalesce(p_note, ''));
begin
  select * into actor from public.profiles where id = auth.uid();
  if actor.id is null or actor.role <> 'director' then
    raise exception 'Only directors can return reports for revision';
  end if;

  if length(clean_note) < 20 then
    raise exception 'Return note must be at least 20 characters';
  end if;

  select * into target from public.reports where id = p_report_id;
  if target.id is null then
    raise exception 'Report not found';
  end if;
  if target.stage <> 'awaiting_director' then
    raise exception 'Report is not awaiting director review';
  end if;
  if target.directorate_id <> actor.directorate_id then
    raise exception 'Report is outside your directorate';
  end if;

  update public.reports
  set
    stage = 'revision_requested',
    current_reviewer_role = null,
    returned_note = clean_note,
    returned_by = actor.id,
    returned_at = now(),
    updated_at = now()
  where id = p_report_id;

  insert into public.report_timeline (
    report_id,
    action,
    label,
    actor_id,
    actor_role,
    actor_name,
    note
  )
  values (
    p_report_id,
    'returned_for_revision',
    'Returned for revision',
    actor.id,
    actor.role,
    actor.full_name,
    clean_note
  );
end;
$$;

grant execute on function public.director_submit_report_to_nda(uuid) to authenticated;
grant execute on function public.director_return_report_for_revision(uuid, text) to authenticated;

create policy "directors can read same directorate reports"
on public.reports for select
to authenticated
using (
  public.current_profile_role() = 'director'
  and directorate_id = (select directorate_id from public.profiles where id = auth.uid())
);
