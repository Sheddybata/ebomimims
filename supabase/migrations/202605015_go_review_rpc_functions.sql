create or replace function public.go_approve_report(p_report_id uuid)
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
  if actor.id is null or actor.role <> 'general_overseer' then
    raise exception 'Only GO can approve reports';
  end if;

  select * into target from public.reports where id = p_report_id;
  if target.id is null then
    raise exception 'Report not found';
  end if;
  if target.stage <> 'awaiting_general_overseer' then
    raise exception 'Report is not awaiting GO review';
  end if;

  update public.reports
  set
    stage = 'approved',
    current_reviewer_role = null,
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
    'approved_by_go',
    'Approved by GO',
    actor.id,
    actor.role,
    actor.full_name
  );

  insert into public.report_inbox_notices (
    report_id,
    recipient_id,
    recipient_role,
    status,
    title,
    message,
    actor_id,
    actor_role,
    note
  )
  select
    target.id,
    target.author_id,
    target.author_role,
    'approved',
    target.title,
    'Final approval completed by the General Overseer.',
    actor.id,
    actor.role,
    null;
end;
$$;

create or replace function public.go_return_report_for_revision(
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
  if actor.id is null or actor.role <> 'general_overseer' then
    raise exception 'Only GO can return reports for revision';
  end if;

  if length(clean_note) < 20 then
    raise exception 'Return note must be at least 20 characters';
  end if;

  select * into target from public.reports where id = p_report_id;
  if target.id is null then
    raise exception 'Report not found';
  end if;
  if target.stage <> 'awaiting_general_overseer' then
    raise exception 'Report is not awaiting GO review';
  end if;

  update public.reports
  set
    stage = 'returned_for_revision',
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

  insert into public.report_inbox_notices (
    report_id,
    recipient_id,
    recipient_role,
    status,
    title,
    message,
    actor_id,
    actor_role,
    note
  )
  select
    target.id,
    target.author_id,
    target.author_role,
    'returned_for_revision',
    target.title,
    'The General Overseer returned this report for revision.',
    actor.id,
    actor.role,
    clean_note;
end;
$$;

grant execute on function public.go_approve_report(uuid) to authenticated;
grant execute on function public.go_return_report_for_revision(uuid, text) to authenticated;
