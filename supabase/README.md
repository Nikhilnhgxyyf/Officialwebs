# Flamingo Group Boardroom — Supabase setup

1. In Supabase **Authentication → Providers**, enable Email/password sign-in.
2. In **Authentication → URL Configuration**, add the deployed website URL as an allowed redirect URL.
3. Run `schema.sql` once in **SQL Editor**.
4. Create the first account from the Board Portal using **Create a new member account**.
5. Run the final commented `update` statement in `schema.sql` with the Chairman's email to grant Chairman rights.
6. Create rooms and membership rows in Table Editor for the initial team. The next Boardroom increment can expose those Chairman actions in the UI.

The frontend intentionally uses only the project URL and publishable/anon key. Never add a `sb_secret_` key or Supabase service-role key to this repository or a browser build.

## Shared features now wired

- Authenticated email/password sign-in and account creation with a full name and role title.
- Shared, member-only room list.
- Real-time room messages with the sender's profile name and company role.
- Private image and PDF attachments, protected by room membership and delivered with short-lived signed URLs.
- Row Level Security policies that restrict room and message access to room members.

## Next increment

Expose Chairman room/member management controls. These features should be tested with two separate accounts before inviting the founding team.
