-- Profile photo URL + public avatars bucket (read open; write limited to own folder).

alter table public.profiles
add column if not exists avatar_url text;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = excluded.public;

-- Public read (stable URL for NetworkImage in the app).
drop policy if exists "avatar objects are publicly readable" on storage.objects;
create policy "avatar objects are publicly readable"
on storage.objects for select
to public
using (bucket_id = 'avatars');

-- Authenticated users may write only under avatars/{their user id}/...
drop policy if exists "users upload own avatar folder" on storage.objects;
create policy "users upload own avatar folder"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "users update own avatar folder" on storage.objects;
create policy "users update own avatar folder"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars'
  and split_part(name, '/', 1) = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and split_part(name, '/', 1) = auth.uid()::text
);

drop policy if exists "users delete own avatar folder" on storage.objects;
create policy "users delete own avatar folder"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'avatars'
  and split_part(name, '/', 1) = auth.uid()::text
);
