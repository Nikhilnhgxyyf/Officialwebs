-- Run this once in Supabase Dashboard > SQL Editor if room creation says:
-- "new row violates row-level security policy for table board_rooms".
-- It safely grants the verified Nikhil Sonar account its Chairman record.

insert into public.profiles (id, full_name, role_title, is_chairman)
select id, 'Nikhil Sonar', 'Chairman', true
from auth.users
where email = 'niksonar07@gmail.com'
on conflict (id) do update
set full_name = excluded.full_name,
    role_title = excluded.role_title,
    is_chairman = true;

select full_name, role_title, is_chairman
from public.profiles
where id = (select id from auth.users where email = 'niksonar07@gmail.com');
