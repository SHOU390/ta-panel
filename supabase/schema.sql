-- ===========================================================
-- 蜗牛AI 第二期 · 助教分配面板  · Supabase / PostgreSQL schema
-- 直接照此在 Supabase SQL Editor 里一次性执行即可（无需 SQLite）
-- ===========================================================

create table if not exists public.module_guides (
  id integer primary key,
  title text not null,
  weeks_label text,
  objectives text,
  key_points jsonb,
  class_practice jsonb,
  pitfalls jsonb,
  ability_map text
);

create table if not exists public.sessions (
  id serial primary key,
  week integer not null,
  class_date date not null,
  seat text not null,
  topic text not null,
  duration_min integer,
  acceptance text,
  module_number integer references public.module_guides(id),
  assigned_ta_name text,
  notes text,
  created_at timestamptz default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  role text not null default 'ta',
  created_at timestamptz default now()
);

create table if not exists public.claims (
  id uuid primary key default gen_random_uuid(),
  session_id integer references public.sessions(id) on delete cascade,
  ta_user_id uuid not null references auth.users(id) on delete cascade,
  claimed_at timestamptz default now(),
  status text not null default 'claimed',
  unique (session_id)
);

-- 新用户注册时自动建 profile（默认 ta 角色）
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email,'@',1)), 'ta')
  on conflict (id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- 管理员判定函数
create or replace function public.is_admin()
returns boolean language sql security definer set search_path = public as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;


alter table public.module_guides enable row level security;
alter table public.sessions enable row level security;
alter table public.profiles enable row level security;
alter table public.claims enable row level security;

drop policy if exists "module_guides_read" on public.module_guides;
create policy "module_guides_read" on public.module_guides for select to authenticated using (true);

drop policy if exists "sessions_read" on public.sessions;
create policy "sessions_read" on public.sessions for select to authenticated using (true);

drop policy if exists "sessions_admin_write" on public.sessions;
create policy "sessions_admin_write" on public.sessions for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "profiles_read_self" on public.profiles;
create policy "profiles_read_self" on public.profiles for select to authenticated using (true);

drop policy if exists "profiles_admin_write" on public.profiles;
create policy "profiles_admin_write" on public.profiles for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "claims_read" on public.claims;
create policy "claims_read" on public.claims for select to authenticated using (true);

drop policy if exists "claims_write_self" on public.claims;
create policy "claims_write_self" on public.claims for insert to authenticated with check (ta_user_id = auth.uid());

drop policy if exists "claims_update_self" on public.claims;
create policy "claims_update_self" on public.claims for update to authenticated using (ta_user_id = auth.uid()) with check (ta_user_id = auth.uid());

drop policy if exists "claims_delete_self" on public.claims;
create policy "claims_delete_self" on public.claims for delete to authenticated using (ta_user_id = auth.uid());

drop policy if exists "claims_admin_all" on public.claims;
create policy "claims_admin_all" on public.claims for all to authenticated using (public.is_admin()) with check (public.is_admin());


-- ---------- 种子数据：6 大模块教学指南 ----------
insert into public.module_guides (id, title, weeks_label, objectives, key_points, class_practice, pitfalls, ability_map) values (
  1,
  '模块一 · AI 思维与唯一入口',
  '第1周',
  '学员能说清 WorkBuddy（龙虾）与网页聊天机器人的本质区别：AI 是大脑、龙虾是四肢；独立完成安装/登录/安全设置/龙虾文件夹搭建；当场用三句话做出第一个自定义技能并跑通录入→查询→导出；建立「AI 不是目的，达成目标才是」的心态。',
  '["① 唯一入口：过去用 AI 像用一堆分散 APP，切换成本高。龙虾=唯一入口，技能是手、专家是参谋、自动化是神经，只在一个地方下指令。", "② AI 相信观：新手最大内耗是「AI 不行」。真相：90% 失败来自指令不清。金句——「结果不对，先改说法，不换工具。」", "③ 万能公式：原始输入（背景/目标/限制）→ 角色规则（它是谁、守什么边界）→ 强制输出（要什么格式的产物）。指令差通常缺一段。", "④ 三句话建技能：用途 + 数据 + 用法。SQLite 向学员解释为「AI 的 Excel」。", "⑤ 三种工作模式：Ask=门口问路（只问不买）/ Plan=列好清单确认再买 / Craft=直接推车搬货（直接干）。"]'::jsonb,
  '["安装 WorkBuddy + 关沙箱 + 删除默认值改 500 + 建《龙虾文件夹》——课堂跟做，不带回家", "给龙虾做自我介绍（姓名/职业/做事风格/常用工具），验证它能复述", "三句话做出「我的购买清单」，语音录入 3 条 → 查询 → 导出 MD", "登录 snailai.au 学员学堂，完成能力清单第 1 项自评"]'::jsonb,
  '[["安装后权限反复弹窗", "每步都要点允许", "安全中心一次性放开"], ["建了文件夹 AI 找不到", "对话时未指定工作目录", "始终在龙虾文件夹下新建任务"], ["语音输入无效", "麦克风权限未开", "系统设置→隐私→麦克风→允许"], ["技能只能聊天不能查询", "第2句没说存 SQLite", "补上数据要求立刻可查"], ["对话只有一两句就停", "不知道还能怎么问", "用万能公式补背景与角色"]]'::jsonb,
  '13 项 · 530 点：01下载WB / 02关沙箱改500 / 03建龙虾文件夹 / 04语音输入法 / 05Zoom调试 / 07任务对话分享 / 13登录学员学堂 / 25AI相信观 / 28安全中心设置 / 39先计划后修改 / 40龙虾企微微信 / 43仔细阅读AI回复 / 53中国区Apple ID'
)
on conflict (id) do nothing;

insert into public.module_guides (id, title, weeks_label, objectives, key_points, class_practice, pitfalls, ability_map) values (
  2,
  '模块二 · 蜗牛AI 技能库与专家团',
  '第2周',
  '一键安装蜗牛AI技能库并验证可用（数量 ≥26，版本与课堂一致）；理解「专家 ≠ 技能」（专家带判断力，技能只执行），搭起总管家→专家→子技能三层架构；完成 GitHub 注册与连接（吉姐姐），做出并发布第一个自定义技能到学生仓库。',
  '["① GitHub 版本底座：Git=「改动记录本」，每次保存叫 commit，可随时回退。「本地改了不等于交付了，必须过吉姐姐这一关。」", "② 一库三仓：核心仓（官方 26+ 技能）/ 助教仓（教学辅助）/ 学生仓（学员作品），每 4 小时自动更新。", "③ 三层官制：总管家（项目经理，拆解派单）→ 专家（领域顾问，出方案）→ 子技能（工人，执行）。成本逐级上升。", "④ 项目工作室四 Agent：小修（打开/修改项目）、小导（进度看板）、小布（检查并发布、打版本标签）、项目信息君（后台统计）。", "⑤ 拟人心智模型：吉姐姐=GitHub（代码云盘）、软妹妹=Render（部署上线）、苏哥哥=Supabase（云数据库）。"]'::jsonb,
  '["GitHub 注册 + 连接器（MCP）授权——看到绿点才算成功", "一键安装技能库，确认数量 ≥26，观察自动更新提示", "定义总管家（职责/权限/汇报格式），挂载 2–3 位专家，跑通一次「派单→方案→执行」", "三句话做一个技能，走「小布检查并发布」全流程，验证仓库出现该技能文件"]'::jsonb,
  '[["GitHub 长期红点", "浏览器登了工具没登", "走连接器授权看绿点；20分钟不通立刻举手"], ["不知道用哪个层级", "所有事都叫专家团", "记住：技能 < 专家 < 专家团"], ["安装了技能用不了", "没更新技能库", "开工第一件事：更新技能库"], ["谷歌授权失败", "只授权没填完整邮箱", "填完整邮箱 + 走授权页"], ["找不到刚装的技能", "未置顶、记不清名字", "对话栏用触发词调用并置顶"]]'::jsonb,
  '周一 9 项·540 点：06GitHub连接 / 09谷歌全家桶 / 12安装技能库 / 18技能大全 / 44调用置顶 / 57安装专家 / 58专家团 / 63侧边栏浏览器 / 68内置浏览器。周四 6 项·810 点：10生成自定义技能 / 29发布技能 / 50我的项目配置 / 54本地路径 / 76复刻技能'
)
on conflict (id) do nothing;

insert into public.module_guides (id, title, weeks_label, objectives, key_points, class_practice, pitfalls, ability_map) values (
  3,
  '模块三 · 项目实战 I — 从 0 到上线（需求/策划 + MVP/上线）',
  '第3–4周',
  '确定真实项目方向，产出可执行的策划书（简版 1 页 + 完整版）；掌握「找对标 → 抓架构 → 搭 MVP」三步法，AI 搭出本地可运行第一版；部署上线 Render，绑定自有域名，桌面/手机双端一致。',
  '["① 需求澄清四问：给谁用？/ 解决什么？/ 长什么样？(三个页面说清楚) / 怎么收钱？(线上收订金)", "② AI 项目四件套：任务描述 → 工作流描述 → 结果模板 → 先手动再自动化。缺第四步容易一上来追全自动而卡死。", "③ 策划书两版：简版 1 页对齐用；完整版补用户画像/竞品/技术选型/收款/风险。", "④ 找对标三步：找 3 个同类网站 → 抓架构（页面/模块/CTA）→ 拆清单（要哪些/不要哪些/哪里不同）。借鉴架构不复制内容。", "⑤ MVP 思维：MVP=最小可演示产品。「丑没关系，能演示就行。」砍到两周能上线，其余进第二版路线图。", "⑥ 三条标准口令（一字不差）：「下载我的项目」/「打开我的项目」/「检查并发布」。", "⑦ 软妹妹部署：push 即上线；Cloudflare 注册域名，DNS 首次配置后自动生效；双端校验截图。"]'::jsonb,
  '["第3周：现场产出简版策划书 + 对标拆解表(3站) + GitHub 仓库初始化，AI 搭 MVP 首页", "第3周：策划书逐份评审（只看 MVP 边界/第一版是否小到能完成/哪些该砍）", "第4周：讲师提交修改→学员同步→小布检查并发布；部署 Render 拿公网地址；绑域名开 HTTPS；手机 4G 验证", "第4周：逐人展示公网网址 + 双端一致截图；集体复盘部署坑，沉淀「部署检查清单」"]'::jsonb,
  '[["构建失败", "依赖缺失或版本冲突", "读构建日志，交给部署专家"], ["页面白屏", "环境变量未配置", "检查平台环境变量设置"], ["本地能开线上打不开", "只开了本地服务", "走完整发布流程"], ["改了没生效", "版本脱节", "确认唯一通道，重新发布"], ["桌面正常手机错位", "未做响应式布局", "加 viewport 与弹性布局"], ["策划书大而空", "「得做半年」", "砍到两周可上线，其余进路线图"]]'::jsonb,
  '11AI刚需项目开始 / 24三工程师调用 / 41ChatGPT生成策划MD / 48学生项目策划书 / 60AI+UI / 66高级项目经理 / 14购买清单 / 15项目中途检验 / 45策划MD给WB / 46循环测试 / 51修不动换GLM5.2 / 53负面提示词 / 20Cloudflare域名 / 21认识Render / 27同步修改工具箱 / 37同步修改流程 / 65网站部署专家 / 75Supabase'
)
on conflict (id) do nothing;

insert into public.module_guides (id, title, weeks_label, objectives, key_points, class_practice, pitfalls, ability_map) values (
  4,
  '模块四 · 项目实战 II — 商业化闭环（收款/获客 + 客服/自动化）',
  '第5–6周',
  '接入 Stripe 收款并完成 1 澳元测试（全员当堂）；跑通 SEO 诊断与 Top3 优化，建立 GEO 基线；上线腾讯元器 AI 客服 + CRM + 邮件账单自动化 + 企微通知链路。',
  '["① 收款合规底线：「你永远不要经手客户的信用卡号。」走 Stripe 托管即 PCI 合规，网站必须 HTTPS。不存卡号明文。", "② 1 澳元测试：用测试卡完成支付→确认订单邮件到达→后台看到订单。「这 1 澳元是最便宜的学费」。", "③ SEO 三件套：GSC（收录）/ GA4（流量来源与转化）/ GBP（本地搜索地图，澳洲本地生意必做）。蜗牛SEO技能自动出诊断。", "④ GEO：让 ChatGPT/Gemini 等 AI 助手在回答中推荐你。机器可读的清晰信息（你是谁/做什么/地区/联系）+ 优质结构化内容。", "⑤ AI 客服（腾讯元器）：七阶段搭建 + 向量知识库。24 小时在线。", "⑥ 企微通知三档：群 Webhook / 自动化原生通知 / 独立 BOT。重要事件才推，避免太吵。"]'::jsonb,
  '["第5周：注册验证 Stripe→网站放收款按钮→1 澳元测试→跑 SEO 诊断→补「关于/服务地区/联系」结构化信息设 GEO 基线", "第5周：收款截图验收 + SEO 报告解读（每人列 Top3 优化）", "第6周：给项目装 AI 客服 + 建 CRM + 打通「询价→CRM→企微提醒」链路", "第6周：机器人调优与 CRM 验收（纯排障与验收课）"]'::jsonb,
  '[["收款两个月才发现没通", "无人测试支付", "开课当堂全员 1 澳元测试"], ["SEO 不知从哪下手", "问题清单太长", "只挑 Top3 高性价比优化，渐进迭代"], ["客服机器人答非所问", "知识库没配好", "检查向量知识库配置，答案写结构化"], ["通知太吵", "所有事都推", "按档位配置，重要事件才推"], ["把 GEO 当玄学", "不知怎么落地", "机器可读的清晰信息 + 优质内容"]]'::jsonb,
  '22注册Stripe / 74网站AI客服 / 79蜗牛SEO / 32AI邮件助手 / 49邮件连接器 / 50自动化企微通知 / 19Tailscale / 26谷歌日历任务 / 34AI支付账单系统 / 35AI协助股票投资(部分) / 47Zoom远程控制'
)
on conflict (id) do nothing;

insert into public.module_guides (id, title, weeks_label, objectives, key_points, class_practice, pitfalls, ability_map) values (
  5,
  '模块五 · 个人 AI 工作流与生活场景',
  '第7周',
  '把课程知识注入 ima 第二大脑并完成检索问答；搭通「24 小时录音 → 本地转写 → AI 日记」自动流水线；生成第一条数字人口播视频；完成 Tailscale+RustDesk 远程遥控。',
  '["① 第二大脑（腾讯 ima/熊猫）：把课程资料、个人知识存进知识库，随时检索提问。「不记笔记，用脑记重点」。", "② 录音日记：全天录音→本地免费转写（whisper）→AI 整理当日日记与待办→定时自动运行。省约 A$400/年转录订阅费。", "③ 数字人口播：一张照片 + 一段文案 → 生成口播视频（可灵/Hydra API）。先脚本后生成，调语速口型。", "④ 远程办公三件套：Tailscale（组网）/ RustDesk（远程控制，设永久密码）/ 手机端 WorkBuddy（移动端发起任务）。", "⑤ 记忆与本地模型：HY Memory 混元记忆插件（跨会话记住偏好）；每月合并三家长期记忆成「灵魂文件」。本地 Ollama 处理敏感内容。"]'::jsonb,
  '["ima 注入课程资料 + 检索问答；配置录音→转写→AI 日记定时任务", "一张图一段话生成口播视频；Tailscale+RustDesk 现场远程打开家里电脑文件", "视频互评（前3秒钩子/看完能说出一个被解答的问题/明确知道下一步）+ 记忆合并 + 浏览器自动化"]'::jsonb,
  '[["远程组网失败", "NAT/防火墙/休眠唤醒", "现场逐项排查，装好再上课"], ["AI 日记质量差", "模板混乱", "统一模板，连续 3 天迭代"], ["口播视频口型不齐", "语速不匹配", "调语速参数重生成"], ["记忆插件没生效", "新对话不记得旧事", "确认插件已加载 + 记忆文件路径"]]'::jsonb,
  '08腾讯熊猫 / 16Tailscale登录本机 / 33AI录音日记 / 36学业分享会 / 61自动化BOT通知 / 67RustDesk+Tailscale / 73跨应用长期记忆月度合并 / 81设置AI服务器 / 55HY Memory / 56本地Ollama / 69长期记忆合并 / 80模拟鼠标 / 83浏览器自动化'
)
on conflict (id) do nothing;

insert into public.module_guides (id, title, weeks_label, objectives, key_points, class_practice, pitfalls, ability_map) values (
  6,
  '模块六 · AI + 财富实战 + 毕业路演',
  '第8周',
  '掌握澳洲场景的 AI 辅助分析框架（股票三系统 / 房产调研 / 个人财富）；理解「AI 服务器」价值；完成毕业路演（每人 3 分钟）与能力清单结算。⚠️ 合规红线：本章不提供金融/投资/法律/税务建议，不承诺收益，决策后果自负。',
  '["① 投资三套系统（讲框架不荐股）：数据系统→决策系统→策略系统。概率思维 / 仓位纪律 / 小白百法（先列100种方法建判断基准）。", "② 房产 AI 实战：Suburb 画像 / Section 32 速读 / 租金回报决策表 / 多语言解读。建模前先问「我漏了哪个成本？」（利息！）。", "③ 个人财富专家系统：收入+支出+负债+资产 → 每周结论：这一周该优化什么。", "④ AI 服务器（3000 点）：24 小时在线机器（如 Mac Mini），住着数字员工，在你睡觉时干活。长期成本远低于人工。", "⑤ 路演四问（必须全答出）：我的项目是什么 / 上线链接在哪 / 怎么收钱 / 下一步计划。评分看「这是不是一门真生意」。", "⑥ 能力清单结算：80 项 14,820 点逐项核对，毕业门槛 ≥80%（至少 64 项双签）。毕业后 90 天计划。"]'::jsonb,
  '["全员路演每人 3 分钟，当场演示链接与支付环节；做一份目标 Suburb 投资简报", "能力清单逐项结算 + 毕业后 90 天计划 + 助教与下期共创招募"]'::jsonb,
  '[["财务测算漏项", "回报率算高", "先列成本清单再建模（利息！）"], ["决策规则没写下来", "临场决定事后后悔", "把买卖/仓位规则写成文档"], ["路演讲太多技术", "3分钟讲不完", "只答四问"], ["把课程当投资建议", "风险理解错误", "反复阅读合规声明"], ["自评多助教未签", "分数虚高", "逐项现场演示才算通过"]]'::jsonb,
  '35AI协助股票投资 / 81设置AI服务器（3000点最高）等 + 能力清单结算（80项14,820点，≥80%双签）'
)
on conflict (id) do nothing;


-- ---------- 种子数据：40 个助教席位（认领状态来自 V3 总表） ----------
insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  1, 1, '2026-10-26', '1-A', '认知导入', 40,
  '学员能用自己的话复述 AI 相信观；用公式改写一条烂指令。', 1, 'ZRR'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  2, 1, '2026-10-26', '1-B', '唯一入口与三模式', 30,
  '学员能区分三种模式并各举一个适用场景。', 1, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  3, 1, '2026-10-26', '1-C', '技能创建与全量设置', 50,
  '每名学员跑通第一个技能；《龙虾文件夹》建好。', 1, 'Sean'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  4, 1, '2026-10-29', '2-A', '验收展示', 70,
  '每人技能「跑通」而非「做了」；现场展示数据。', 1, 'Mandy'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  5, 1, '2026-10-29', '2-B', '排障与作业评价', 60,
  '指令改写练习达标；文件夹验收；态度观察（先改指令不换工具）。', 1, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  6, 2, '2026-11-02', '1-A', '版本底座', 40,
  '学员理解「下载是取钱、发布是存钱」的版本逻辑。', 2, 'Sean'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  7, 2, '2026-11-02', '1-B', '技能生态与官制', 35,
  '能说清三层分工；会从学生仓安装技能。', 2, 'Michael'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  8, 2, '2026-11-02', '1-C', '发布实操', 45,
  '独立完成一次「小布检查并发布」全流程。', 2, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  9, 2, '2026-11-05', '2-A', '验收展示', 70,
  '发布动作达标；概念复述准确。', 2, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  10, 2, '2026-11-05', '2-B', '排障与作业评价', 60,
  '养成「发布才算交付」习惯；技能安装数量与运行率。', 2, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  11, 3, '2026-11-09', '1-A', '需求澄清', 45,
  '能用四问逼出真实需求；理解先手动后自动化。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  12, 3, '2026-11-09', '1-B', '策划书', 35,
  '能套模板产出项目策划书结构。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  13, 3, '2026-11-09', '1-C', '对标拆解', 40,
  '列出对标站页面/模块/CTA 清单。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  14, 3, '2026-11-12', '2-A', '验收展示', 70,
  '策划书简版覆盖四问+收款。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  15, 3, '2026-11-12', '2-B', '排障与作业评价', 60,
  '需求清晰度；对标拆解区分借鉴与复制。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  16, 4, '2026-11-16', '1-A', 'MVP与口令', 40,
  '能把功能清单砍到核心主流程；口令一字不差。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  17, 4, '2026-11-16', '1-B', '部署实操', 50,
  '每位学员拿到项目公开链接。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  18, 4, '2026-11-16', '1-C', '协作纪律', 30,
  '理解循环测试与换思路心理。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  19, 4, '2026-11-19', '2-A', '验收展示', 70,
  '链接硬门槛；双端一致。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  20, 4, '2026-11-19', '2-B', '排障与作业评价', 60,
  'MVP 纪律；协作纪律执行。', 3, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  21, 5, '2026-11-23', '1-A', '收款闭环', 50,
  '每人收款链路真实跑通 1 澳元测试。', 4, 'Mandy'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  22, 5, '2026-11-23', '1-B', '获客引擎 I', 35,
  '理解三件套各自用途并准备配置。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  23, 5, '2026-11-23', '1-C', '获客引擎 II · GEO', 35,
  '产出 SEO 诊断报告与 GEO 结论句。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  24, 5, '2026-11-26', '2-A', '验收展示', 70,
  '收款硬门槛；三件套配置完整。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  25, 5, '2026-11-26', '2-B', '排障与作业评价', 60,
  '合规意识；GEO 输出质量。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  26, 6, '2026-11-30', '1-A', 'AI客服', 55,
  '搭建能回答常见问题的 AI 客服。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  27, 6, '2026-11-30', '1-B', 'CRM与账单', 35,
  '理解客户与账单自动化链路。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  28, 6, '2026-11-30', '1-C', '通知三档', 30,
  '选型并配置一种企微通知。', 4, 'Michael'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  29, 6, '2026-12-03', '2-A', '验收展示', 70,
  '客服有效；自动化闭环跑通。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  30, 6, '2026-12-03', '2-B', '排障与作业评价', 60,
  '自动化链路无断点；合规。', 4, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  31, 7, '2026-12-07', '1-A', '第二大脑与日记', 50,
  '理解第二大脑与全自动日记流水线。', 5, 'Michael'
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  32, 7, '2026-12-07', '1-B', '数字人与远程', 35,
  '说出远程三件套各自作用。', 5, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  33, 7, '2026-12-07', '1-C', '记忆体系', 35,
  '理解记忆合并与发布风控。', 5, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  34, 7, '2026-12-10', '2-A', '验收展示', 70,
  '检索返回出处；流水线跑通。', 5, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  35, 7, '2026-12-10', '2-B', '排障与作业评价', 60,
  '合规（录音/风控）；概念清晰。', 5, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  36, 8, '2026-12-14', '1-A', '投资框架', 50,
  '用框架而非代码；清晰合规边界。', 6, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  37, 8, '2026-12-14', '1-B', '财富系统与服务器', 35,
  '理解财富系统与数字员工闭环。', 6, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  38, 8, '2026-12-14', '1-C', '毕业路演', 35,
  '写好 3 分钟路演稿框架。', 6, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  39, 8, '2026-12-17', '2-A', '毕业路演展示', 80,
  '路演讲清真生意；链接收款硬门槛。', 6, NULL
)
on conflict (id) do nothing;

insert into public.sessions (id, week, class_date, seat, topic, duration_min, acceptance, module_number, assigned_ta_name) values (
  40, 8, '2026-12-17', '2-B', '结算与作业评价', 50,
  '能力清单达成率；合规始终前置。', 6, NULL
)
on conflict (id) do nothing;


-- 把 Grace / Robin 设为管理员：注册登录后，在 SQL Editor 执行下面两行（换成你们自己的邮箱）
-- update public.profiles set role='admin' where display_name in ('grace','robin');