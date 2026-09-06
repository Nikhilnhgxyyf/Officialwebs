-- Run this in Supabase Dashboard > SQL Editor only after Nikhil has confirmed
-- the account registered with niksonar07@gmail.com.

update public.profiles
set
  full_name = 'Nikhil Sonar',
  role_title = 'Chairman',
  is_chairman = true
where id = (
  select id
  from auth.users
  where email = 'niksonar07@gmail.com'
);

-- Confirm exactly one profile was updated before continuing.
select full_name, role_title, is_chairman
from public.profiles
where id = (select id from auth.users where email = 'niksonar07@gmail.com');
