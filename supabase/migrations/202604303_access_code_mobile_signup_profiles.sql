alter table public.profiles
add column if not exists email text,
add column if not exists phone text;

drop policy if exists "users can update own device profile fields" on public.profiles;

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
  profile_role public.ims_role;
  profile_directorate_id uuid;
  profile_unit_id uuid;
begin
  profile_role := case role_text
    when 'unit_head' then 'unit_head'::public.ims_role
    when 'manager' then 'manager'::public.ims_role
    when 'director' then 'director'::public.ims_role
    else null
  end;

  if profile_role is null then
    return new;
  end if;

  select id
  into profile_directorate_id
  from public.directorates
  where code = directorate_code;

  if profile_directorate_id is null then
    raise exception 'Invalid directorate code: %', directorate_code;
  end if;

  if unit_code is not null and unit_code <> '' then
    select id
    into profile_unit_id
    from public.units
    where code = unit_code
      and directorate_id = profile_directorate_id;

    if profile_unit_id is null then
      raise exception 'Invalid unit code: %', unit_code;
    end if;
  end if;

  insert into public.profiles (
    id,
    full_name,
    email,
    phone,
    role,
    directorate_id,
    unit_id
  )
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'full_name', ''), new.email),
    new.email,
    nullif(new.raw_user_meta_data ->> 'phone', ''),
    profile_role,
    profile_directorate_id,
    profile_unit_id
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_mobile_auth_signup on auth.users;

create trigger on_mobile_auth_signup
after insert on auth.users
for each row execute function public.handle_mobile_auth_signup();
