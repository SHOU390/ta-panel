-- =============================================================
-- 补丁：重建 Suping / James Jiang（其余 6 个账号已正常，不动）
-- 在 Supabase SQL Editor 执行；整段一起粘贴，点一次 Run
-- =============================================================

-- 1) 先清掉这两个号的旧残留（identities/users 删除会自动级联清 profile）
delete from auth.identities where user_id in (
  select id from auth.users where lower(email) in ('suping@ta.snailai.au','jamesjiang@ta.snailai.au')
);
delete from auth.users where lower(email) in ('suping@ta.snailai.au','jamesjiang@ta.snailai.au');

-- 2) 重新创建这两个账号（密码 123456，自动已确认）
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
  ('suping@ta.snailai.au',    'Suping'),
  ('jamesjiang@ta.snailai.au','James Jiang')
) as v(email, dname)
where not exists (select 1 from auth.users u where lower(u.email) = v.email);

-- 3) 补 identities（带防冲突保险，不会再报 duplicate key）
insert into auth.identities (user_id, provider_id, provider, identity_data, last_sign_in_at, created_at, updated_at)
select u.id, 'email', 'email', jsonb_build_object('sub', u.id::text, 'email', u.email), now(), now(), now()
from auth.users u
where lower(u.email) in ('suping@ta.snailai.au','jamesjiang@ta.snailai.au')
on conflict do nothing;

-- 4) 密码统一 123456
update auth.users set encrypted_password = crypt('123456', gen_salt('bf'))
where lower(email) in ('suping@ta.snailai.au','jamesjiang@ta.snailai.au');

-- 5) Suping 设回管理员（Robin 昨晚已设好，不受影响）
update public.profiles set role = 'admin' where display_name ilike 'suping';
