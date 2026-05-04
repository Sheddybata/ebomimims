create extension if not exists "pgcrypto";

create type public.ims_role as enum (
  'unit_head',
  'manager',
  'director',
  'nda',
  'ago',
  'general_overseer',
  'super_admin'
);

create type public.report_stage as enum (
  'draft',
  'awaiting_manager',
  'awaiting_director',
  'revision_requested',
  'awaiting_administration',
  'awaiting_ago',
  'awaiting_general_overseer',
  'returned_for_revision',
  'approved',
  'archived'
);

create type public.timeline_action as enum (
  'submitted',
  'forwarded_to_manager',
  'forwarded_to_director',
  'submitted_to_nda',
  'forwarded_to_ago',
  'forwarded_to_go',
  'approved_by_go',
  'returned_for_revision',
  'resubmitted'
);

create type public.inbox_notice_status as enum (
  'approved',
  'returned_for_revision',
  'needs_action'
);

create table public.directorates (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.units (
  id uuid primary key default gen_random_uuid(),
  directorate_id uuid not null references public.directorates(id) on delete cascade,
  code text not null unique,
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role public.ims_role not null,
  directorate_id uuid references public.directorates(id),
  unit_id uuid references public.units(id),
  manager_id uuid references public.profiles(id),
  director_id uuid references public.profiles(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  report_type text not null,
  stage public.report_stage not null default 'draft',
  directorate_id uuid not null references public.directorates(id),
  unit_id uuid references public.units(id),
  author_id uuid not null references public.profiles(id),
  author_role public.ims_role not null,
  current_reviewer_role public.ims_role,
  returned_note text,
  returned_by uuid references public.profiles(id),
  returned_at timestamptz,
  submitted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.report_metrics (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  metric_key text not null,
  metric_label text not null,
  metric_value text not null,
  value_type text not null default 'text',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (report_id, metric_key)
);

create table public.report_timeline (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  action public.timeline_action not null,
  label text not null,
  actor_id uuid references public.profiles(id),
  actor_role public.ims_role not null,
  actor_name text not null,
  note text,
  created_at timestamptz not null default now()
);

create table public.report_inbox_notices (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  recipient_role public.ims_role not null,
  status public.inbox_notice_status not null,
  title text not null,
  message text not null,
  actor_id uuid references public.profiles(id),
  actor_role public.ims_role not null,
  note text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.report_attachments (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  uploaded_by uuid not null references public.profiles(id),
  file_name text not null,
  storage_path text not null,
  mime_type text,
  file_size_bytes bigint,
  created_at timestamptz not null default now()
);

create table public.profile_device_tokens (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  platform text not null,
  token text not null unique,
  created_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now()
);

create index reports_stage_idx on public.reports(stage);
create index reports_author_id_idx on public.reports(author_id);
create index reports_directorate_id_idx on public.reports(directorate_id);
create index reports_unit_id_idx on public.reports(unit_id);
create index reports_current_reviewer_role_idx on public.reports(current_reviewer_role);
create index report_metrics_report_id_idx on public.report_metrics(report_id);
create index report_timeline_report_id_idx on public.report_timeline(report_id);
create index report_inbox_notices_recipient_id_idx on public.report_inbox_notices(recipient_id);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger directorates_touch_updated_at
before update on public.directorates
for each row execute function public.touch_updated_at();

create trigger units_touch_updated_at
before update on public.units
for each row execute function public.touch_updated_at();

create trigger profiles_touch_updated_at
before update on public.profiles
for each row execute function public.touch_updated_at();

create trigger reports_touch_updated_at
before update on public.reports
for each row execute function public.touch_updated_at();

create or replace function public.current_profile_role()
returns public.ims_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_profile_role() = 'super_admin', false);
$$;

alter table public.directorates enable row level security;
alter table public.units enable row level security;
alter table public.profiles enable row level security;
alter table public.reports enable row level security;
alter table public.report_metrics enable row level security;
alter table public.report_timeline enable row level security;
alter table public.report_inbox_notices enable row level security;
alter table public.report_attachments enable row level security;
alter table public.profile_device_tokens enable row level security;

create policy "active users can read directorates"
on public.directorates for select
to authenticated
using (is_active = true or public.is_super_admin());

create policy "active users can read units"
on public.units for select
to authenticated
using (is_active = true or public.is_super_admin());

create policy "users can read own profile"
on public.profiles for select
to authenticated
using (id = auth.uid() or public.is_super_admin());

create policy "users can update own device profile fields"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "reports visible by role"
on public.reports for select
to authenticated
using (
  public.is_super_admin()
  or author_id = auth.uid()
  or returned_by = auth.uid()
  or (
    public.current_profile_role() = 'manager'
    and stage = 'awaiting_manager'
    and directorate_id = (select directorate_id from public.profiles where id = auth.uid())
  )
  or (
    public.current_profile_role() = 'director'
    and stage = 'awaiting_director'
    and directorate_id = (select directorate_id from public.profiles where id = auth.uid())
  )
  or (public.current_profile_role() = 'nda' and stage = 'awaiting_administration')
  or (public.current_profile_role() = 'ago' and stage = 'awaiting_ago')
  or (public.current_profile_role() = 'general_overseer' and stage = 'awaiting_general_overseer')
);

create policy "authors can create reports"
on public.reports for insert
to authenticated
with check (
  author_id = auth.uid()
  and author_role = public.current_profile_role()
);

create policy "report metrics visible with report"
on public.report_metrics for select
to authenticated
using (
  exists (
    select 1 from public.reports r
    where r.id = report_id
  )
);

create policy "authors can add metrics to own reports"
on public.report_metrics for insert
to authenticated
with check (
  exists (
    select 1 from public.reports r
    where r.id = report_id and r.author_id = auth.uid()
  )
);

create policy "report timeline visible with report"
on public.report_timeline for select
to authenticated
using (
  exists (
    select 1 from public.reports r
    where r.id = report_id
  )
);

create policy "inbox notices visible to recipient"
on public.report_inbox_notices for select
to authenticated
using (recipient_id = auth.uid() or public.is_super_admin());

create policy "recipient can mark notice read"
on public.report_inbox_notices for update
to authenticated
using (recipient_id = auth.uid())
with check (recipient_id = auth.uid());

create policy "attachments visible with report"
on public.report_attachments for select
to authenticated
using (
  exists (
    select 1 from public.reports r
    where r.id = report_id
  )
);

create policy "authors can add attachments to own reports"
on public.report_attachments for insert
to authenticated
with check (
  uploaded_by = auth.uid()
  and exists (
    select 1 from public.reports r
    where r.id = report_id and r.author_id = auth.uid()
  )
);

create policy "users manage own device tokens"
on public.profile_device_tokens for all
to authenticated
using (profile_id = auth.uid() or public.is_super_admin())
with check (profile_id = auth.uid() or public.is_super_admin());
