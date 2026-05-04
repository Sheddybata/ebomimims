-- 1. Add state_coordinator role
alter type public.ims_role add value 'state_coordinator';

-- 2. Create reference_states table
create table public.reference_states (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

alter table public.reference_states enable row level security;

create policy "active users can read reference states"
on public.reference_states for select
to authenticated
using (true);

insert into public.reference_states (name) values
  ('Abia'), ('Adamawa'), ('Akwa Ibom'), ('Anambra'), ('Bauchi'), ('Bayelsa'), 
  ('Benue'), ('Borno'), ('Cross River'), ('Delta'), ('Ebonyi'), ('Edo'), 
  ('Ekiti'), ('Enugu'), ('Gombe'), ('Imo'), ('Jigawa'), ('Kaduna'), 
  ('Kano'), ('Katsina'), ('Kebbi'), ('Kogi'), ('Kwara'), ('Lagos'), 
  ('Nasarawa'), ('Niger'), ('Ogun'), ('Ondo'), ('Osun'), ('Oyo'), 
  ('Plateau'), ('Rivers'), ('Sokoto'), ('Taraba'), ('Yobe'), ('Zamfara'), 
  ('Federal Capital Territory');

-- 3. Add state_id to profiles
alter table public.profiles add column if not exists state_id uuid references public.reference_states(id);

-- 4. Allow reports to have no directorate_id (for state coordinators)
alter table public.reports alter column directorate_id drop not null;

-- Add state_id to reports as well, so we can track which state the report belongs to
alter table public.reports add column if not exists state_id uuid references public.reference_states(id);

-- 5. Update auth trigger
create or replace function public.handle_mobile_auth_signup()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  role_text text := new.raw_user_meta_data ->> 'role';
  directorate_code text := new.raw_user_meta_data ->> 'directorate_code';
  unit_code text := new.raw_user_meta_data ->> 'unit_code';
  state_name_text text := new.raw_user_meta_data ->> 'state_name';
  profile_role public.ims_role;
  profile_directorate_id uuid;
  profile_unit_id uuid;
  profile_state_id uuid;
begin
  profile_role := case role_text
    when 'unit_head' then 'unit_head'::public.ims_role
    when 'manager' then 'manager'::public.ims_role
    when 'director' then 'director'::public.ims_role
    when 'state_coordinator' then 'state_coordinator'::public.ims_role
    else null
  end;

  if profile_role is null then
    return new;
  end if;

  if profile_role = 'state_coordinator' then
    if state_name_text is null or state_name_text = '' then
      raise exception 'State name is required for state coordinators';
    end if;

    select id into profile_state_id
    from public.reference_states
    where name = state_name_text;

    if profile_state_id is null then
      raise exception 'Invalid state name: %', state_name_text;
    end if;
  else
    select id into profile_directorate_id
    from public.directorates
    where code = directorate_code;

    if profile_directorate_id is null then
      raise exception 'Invalid directorate code: %', directorate_code;
    end if;

    if unit_code is not null and unit_code <> '' then
      select id into profile_unit_id
      from public.units
      where code = unit_code
        and directorate_id = profile_directorate_id;

      if profile_unit_id is null then
        raise exception 'Invalid unit code: %', unit_code;
      end if;
    end if;
  end if;

  insert into public.profiles (
    id,
    full_name,
    email,
    phone,
    role,
    directorate_id,
    unit_id,
    state_id
  )
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'full_name', ''), new.email),
    new.email,
    nullif(new.raw_user_meta_data ->> 'phone', ''),
    profile_role,
    profile_directorate_id,
    profile_unit_id,
    profile_state_id
  )
  on conflict (id) do nothing;

  return new;
end;
$$;
