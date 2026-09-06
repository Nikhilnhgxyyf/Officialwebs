-- Flamingo Group Boardroom: run once in Supabase Dashboard > SQL Editor.
-- Never use a service-role/secret key in the browser.

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 100),
  role_title text not null check (char_length(role_title) between 2 and 100),
  is_chairman boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.board_rooms (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 100),
  description text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.room_members (
  room_id uuid not null references public.board_rooms(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  added_by uuid references public.profiles(id),
  joined_at timestamptz not null default now(),
  primary key (room_id, user_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.board_rooms(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(trim(body)) between 1 and 5000),
  created_at timestamptz not null default now()
);

create table public.attachments (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  room_id uuid not null references public.board_rooms(id) on delete cascade,
  uploaded_by uuid not null references public.profiles(id),
  storage_path text not null unique,
  file_name text not null,
  mime_type text not null,
  file_size bigint not null check (file_size <= 10485760),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.board_rooms enable row level security;
alter table public.room_members enable row level security;
alter table public.messages enable row level security;
alter table public.attachments enable row level security;

create function public.is_room_member(target_room uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.room_members where room_id = target_room and user_id = auth.uid());
$$;

create function public.is_chairman()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_chairman from public.profiles where id = auth.uid()), false);
$$;

create function public.create_profile_for_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, role_title)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', 'Board member'), coalesce(new.raw_user_meta_data ->> 'role_title', 'Member'));
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.create_profile_for_new_user();

-- Backfill profiles for accounts created before this schema was installed.
insert into public.profiles (id, full_name, role_title)
select id, coalesce(raw_user_meta_data ->> 'full_name', 'Board member'), coalesce(raw_user_meta_data ->> 'role_title', 'Member')
from auth.users
on conflict (id) do nothing;

create policy "members can read profiles" on public.profiles for select to authenticated using (true);
create policy "members view their rooms" on public.board_rooms for select to authenticated using (public.is_room_member(id));
create policy "chairman creates rooms" on public.board_rooms for insert to authenticated with check (public.is_chairman());
create policy "chairman updates rooms" on public.board_rooms for update to authenticated using (public.is_chairman()) with check (public.is_chairman());
create policy "members view room membership" on public.room_members for select to authenticated using (public.is_room_member(room_id));
create policy "chairman manages membership" on public.room_members for all to authenticated using (public.is_chairman()) with check (public.is_chairman());
create policy "members view messages" on public.messages for select to authenticated using (public.is_room_member(room_id));
create policy "members send messages" on public.messages for insert to authenticated with check (author_id = auth.uid() and public.is_room_member(room_id));
create policy "members view attachments" on public.attachments for select to authenticated using (public.is_room_member(room_id));
create policy "members add attachments" on public.attachments for insert to authenticated with check (uploaded_by = auth.uid() and public.is_room_member(room_id));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('board-attachments', 'board-attachments', false, 10485760, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
on conflict (id) do nothing;

create policy "room members upload files" on storage.objects for insert to authenticated
with check (bucket_id = 'board-attachments' and public.is_room_member((storage.foldername(name))[1]::uuid));
create policy "room members read files" on storage.objects for select to authenticated
using (bucket_id = 'board-attachments' and public.is_room_member((storage.foldername(name))[1]::uuid));

alter publication supabase_realtime add table public.messages;

-- After creating the first account, promote it once (replace the email):
-- update public.profiles set is_chairman = true where id = (select id from auth.users where email = 'chairman@example.com');
-- Then create rooms and add members through the dashboard or a later Chairman UI.
