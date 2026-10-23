-- =============================================================
-- 8 个助教账号 · 密码统一 123456 · 在 Supabase SQL Editor 执行
-- 管理员：Suping + Robin；其余为助教
-- Grace 本人登录名：Suping（她原有的 grace390@hotmail.com 也保留）
-- 登录时面板里只输名字即可，大小写不限
-- 可重复执行（已存在的账号自动跳过，密码会被统一刷成 123456）
-- =============================================================

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, confirmation_token, recovery_token,
  email_change_token_new, email_change
)
select '00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated',
  v.email, crypt('123456', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  jsonb_build_object('display_name', v.dname),
  now(), now(), '', '', '', ''
from (values
  ('zrr@ta.snailai.au',       'ZRR'),
  ('sean@ta.snailai.au',      'Sean'),
  ('jason@ta.snailai.au',     'Jason'),
  ('michael@ta.snailai.au',   'Michael'),
  ('suping@ta.snailai.au',    'Suping'),
  ('jamesjiang@ta.snailai.au','James Jiang'),
  ('robin@ta.snailai.au',     'Robin'),
  ('mandy@ta.snailai.au',     'Mandy')
) as v(email, dname)
where not exists (select 1 from auth.users u where lower(u.email) = v.email);

-- 补 identities（邮箱密码登录所需）
insert into auth.identities (user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
select u.id, 'email', 'email', jsonb_build_object('sub', u.id::text, 'email', u.email), now(), now(), now()
from auth.users u
where lower(u.email) like '%@ta.snailai.au'
  and not exists (select 1 from auth.identities i where i.user_id = u.id and i.provider_id = 'email')
on conflict do nothing;

-- 所有内部账号密码统一刷成 123456（防止之前设过别的）
update auth.users set encrypted_password = crypt('123456', gen_salt('bf'))
where lower(email) like '%@ta.snailai.au';

-- 管理员：Suping + Robin
update public.profiles set role = 'admin' where display_name ilike 'suping' or display_name ilike 'robin';
