-- Run this in Supabase Dashboard > SQL Editor only after Nikhil has confirmed
-- the account registered with niksonar07@gmail.com.

insert into public.profiles (id, full_name, role_title, is_chairman)
select id, 'Nikhil Sonar', 'Chairman', true
from auth.users
where email = 'niksonar07@gmail.com'
on conflict (id) do update
set full_name = excluded.full_name,
    role_title = excluded.role_title,
    is_chairman = true;

-- Confirm exactly one profile was updated before continuing.
select full_name, role_title, is_chairman
from public.profiles
where id = (select id from auth.users where email = 'niksonar07@gmail.com');
