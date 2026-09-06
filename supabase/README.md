# Flamingo Group Boardroom — Supabase setup

1. In Supabase **Authentication → Providers**, enable Email/password sign-in.
2. In **Authentication → URL Configuration**, set **Site URL** to `https://flamingofficial.netlify.app` and add `https://flamingofficial.netlify.app/**` under **Redirect URLs**. Do not leave `http://localhost:3000` as the Site URL for the live project.
3. Run `schema.sql` once in **SQL Editor**.
4. Create the first account from the Board Portal using **Create a new member account**.
5. Run `chairman-nikhil.sql` in **SQL Editor** after Nikhil has confirmed his account to grant Chairman rights.
6. Create rooms and membership rows in Table Editor for the initial team. The next Boardroom increment can expose those Chairman actions in the UI.

The frontend intentionally uses only the project URL and publishable/anon key. Never add a `sb_secret_` key or Supabase service-role key to this repository or a browser build.

## Shared features now wired

- Authenticated email/password sign-in and account creation with a full name and role title.
- Shared, member-only room list.
- Real-time room messages with the sender's profile name and company role.
- Private image and PDF attachments, protected by room membership and delivered with short-lived signed URLs.
- Row Level Security policies that restrict room and message access to room members.

## Fixing a confirmation link that opens localhost

If an email verification link opens `localhost:3000`, Supabase is using an old Site URL. Update the URL Configuration in step 2, then delete the unconfirmed user in **Authentication → Users** (or use Supabase's resend confirmation action) and register again. The browser now explicitly asks Supabase to return to the deployed site's current origin after confirmation.

## Next increment

Expose Chairman room/member management controls. These features should be tested with two separate accounts before inviting the founding team.
