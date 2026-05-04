insert into public.profiles (id, full_name, email, role)
select id, 'NDA (National Director of Administration)', email, 'nda'
from auth.users
where email = 'nda@ims.local'
   or email = 'nda@ebomim.org'
on conflict (id) do update
set
  full_name = excluded.full_name,
  email = excluded.email,
  role = excluded.role,
  updated_at = now();

insert into public.profiles (id, full_name, email, role)
select id, 'Assistant General Overseer', email, 'ago'
from auth.users
where email = 'ago@ims.local'
   or email = 'ago@ebomim.org'
on conflict (id) do update
set
  full_name = excluded.full_name,
  email = excluded.email,
  role = excluded.role,
  updated_at = now();

insert into public.profiles (id, full_name, email, role)
select id, 'General Overseer', email, 'general_overseer'
from auth.users
where email = 'go@ims.local'
   or email = 'go@ebomim.org'
on conflict (id) do update
set
  full_name = excluded.full_name,
  email = excluded.email,
  role = excluded.role,
  updated_at = now();

insert into public.profiles (id, full_name, email, role)
select id, 'Super Admin', email, 'super_admin'
from auth.users
where email = 'admin@ims.local'
   or email = 'admin@ebomim.org'
on conflict (id) do update
set
  full_name = excluded.full_name,
  email = excluded.email,
  role = excluded.role,
  updated_at = now();
