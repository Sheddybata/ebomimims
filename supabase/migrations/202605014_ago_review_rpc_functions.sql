create or replace function public.ago_forward_report_to_go(p_report_id uuid)
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
  if actor.id is null or actor.role <> 'ago' then
    raise exception 'Only AGO can forward reports to GO';
  end if;

  select * into target from public.reports where id = p_report_id;
  if target.id is null then
    raise exception 'Report not found';
  end if;
  if target.stage <> 'awaiting_ago' then
    raise exception 'Report is not awaiting AGO review';
  end if;

  update public.reports
  set
    stage = 'awaiting_general_overseer',
    current_reviewer_role = 'general_overseer',
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
    'forwarded_to_go',
    'Forwarded to GO',
    actor.id,
    actor.role,
    actor.full_name
  );
end;
$$;

create or replace function public.ago_return_report_for_revision(
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
  if actor.id is null or actor.role <> 'ago' then
    raise exception 'Only AGO can return reports for revision';
  end if;

  if length(clean_note) < 20 then
    raise exception 'Return note must be at least 20 characters';
  end if;

  select * into target from public.reports where id = p_report_id;
  if target.id is null then
    raise exception 'Report not found';
  end if;
  if target.stage <> 'awaiting_ago' then
    raise exception 'Report is not awaiting AGO review';
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
end;
$$;

grant execute on function public.ago_forward_report_to_go(uuid) to authenticated;
grant execute on function public.ago_return_report_for_revision(uuid, text) to authenticated;
