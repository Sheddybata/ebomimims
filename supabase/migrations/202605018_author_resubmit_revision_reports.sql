-- Authors can correct returned reports and re-enter the workflow.
-- Line-review returns go back to the original line reviewer; executive returns restart at NDA.

create or replace function public.author_resubmit_report_for_revision(
  p_report_id uuid,
  p_title text,
  p_body text,
  p_report_type text,
  p_metrics jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  actor public.profiles%rowtype;
  target public.reports%rowtype;
  clean_title text := btrim(coalesce(p_title, ''));
  clean_body text := btrim(coalesce(p_body, ''));
  clean_type text := btrim(coalesce(p_report_type, 'Narrative'));
  next_stage public.report_stage;
  next_reviewer public.ims_role;
  metric record;
begin
  select * into actor from public.profiles where id = auth.uid();
  if actor.id is null then
    raise exception 'You must be signed in to resubmit a report';
  end if;

  if clean_title = '' or clean_body = '' then
    raise exception 'Report title and body are required';
  end if;

  select * into target from public.reports where id = p_report_id;
  if target.id is null then
    raise exception 'Report not found';
  end if;
  if target.author_id <> actor.id then
    raise exception 'Only the original author can resubmit this report';
  end if;
  if target.stage not in ('revision_requested', 'returned_for_revision') then
    raise exception 'Report is not awaiting revision';
  end if;

  if target.stage = 'returned_for_revision' then
    next_stage := 'awaiting_administration';
    next_reviewer := 'nda';
  elsif target.author_role = 'unit_head' then
    next_stage := 'awaiting_manager';
    next_reviewer := 'manager';
  elsif target.author_role = 'manager' then
    next_stage := 'awaiting_director';
    next_reviewer := 'director';
  else
    next_stage := 'awaiting_administration';
    next_reviewer := 'nda';
  end if;

  update public.reports
  set
    title = clean_title,
    body = clean_body,
    report_type = clean_type,
    stage = next_stage,
    current_reviewer_role = next_reviewer,
    returned_note = null,
    returned_by = null,
    returned_at = null,
    updated_at = now()
  where id = p_report_id;

  delete from public.report_metrics where report_id = p_report_id;

  for metric in
    select key, value
    from jsonb_each_text(coalesce(p_metrics, '{}'::jsonb))
    where btrim(value) <> ''
  loop
    insert into public.report_metrics (
      report_id,
      metric_key,
      metric_label,
      metric_value
    )
    values (
      p_report_id,
      metric.key,
      metric.key,
      metric.value
    );
  end loop;

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
    'resubmitted',
    'Resubmitted after revision',
    actor.id,
    actor.role,
    actor.full_name
  );
end;
$$;

grant execute on function public.author_resubmit_report_for_revision(uuid, text, text, text, jsonb) to authenticated;
