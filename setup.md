# 蜗牛AI 第二期 · 助教分配面板 — 部署与上手指南

> 目标：把《V3 助教分配总表》变成助教各自登录就能看的网页面板，认领后立刻看到该席位的完整课程内容。
> 技术栈：**Supabase（PostgreSQL + 登录 + 接口）** + **Render（免费静态托管）**，按 Robin 建议**跳过 SQLite，直接用 Postgres**。
> 全部免费计划，不绑信用卡。

---

## 0. 你现在手里有什么

| 文件 | 作用 |
|---|---|
| `index.html` | 面板本体（单文件，双击即可在浏览器打开） |
| `assets/demo-data.js` | 演示种子数据（40 个席位 + 6 大模块教学指南） |
| `assets/logo.png` | **把官方 logo 放这里**（同名文件），没有也能正常显示文字版「蜗牛AI」 |
| `supabase/schema.sql` | 数据库结构 + 种子数据，一次性执行即可 |
| `setup.md` | 本指南 |

**不注册任何账号也能先看效果**：直接用浏览器打开 `index.html` → 选一个身份（选 Grace / Robin 看管理员视图）→ 进面板点「认领」，课程内容会**立刻展开**。这就是 Robin 说的「认领了顺便看内容是啥」。

---

## 1. 创建 Supabase（免费，不绑卡）

1. 打开 https://supabase.com → 右上角 **Start your project** → 用 **GitHub 账号**登录（没有就先用邮箱注册，之后用「蜗牛吉姐姐」引导连 GitHub）。
2. 新建项目（New Project）：填名字（如 `snail-ta-panel`）、设一个数据库密码（**记下来**）、地区选离澳洲近的（Sydney）。
3. 等 1–2 分钟建好。免费版足够：500MB 数据库、5 万月活。

> 我不会、也不能替你点授权 / 输密码。下面每步你本人点一下即可。

## 2. 跑数据库结构（schema.sql）

1. 左侧菜单 **SQL Editor** → **New query**。
2. 把 `supabase/schema.sql` 全部内容粘进去 → 点 **Run**。
3. 执行完会建好 4 张表：`module_guides`（教学指南）、`sessions`（40 席位）、`profiles`（助教档案）、`claims`（认领记录），并自动写入种子数据。

表与权限说明（RLS，行级安全）：
- 所有登录助教都能**看**全部席位（避免重复认领）；
- 助教只能**认领/取消自己**的席位，不能改别人的；
- 管理员（Grace / Robin）能分配任意席位、改备注。

## 3. 拿到连接信息，填进面板

1. 左侧 **Project Settings → API**：复制 **Project URL** 和 **anon public key**。
2. 用记事本打开 `index.html`，最上方改这两行（原来为空）：

```js
const SUPABASE_URL = "https://xxxx.supabase.co";          // 粘你的 Project URL
const SUPABASE_ANON_KEY = "eyJhbGciOi...";                 // 粘你的 anon key
```

保存。此时面板从「演示模式」自动切到「真实模式」。

## 4. 把 Grace / Robin 设为管理员

1. 你们两人各自在面板上**注册**登录一次（显示名填 `Grace` / `Robin`）。
2. 回到 Supabase **SQL Editor** 执行：

```sql
update public.profiles set role='admin' where display_name in ('grace','robin');
```

（显示名不区分大小写无所谓，按你注册时填的来。）之后她们登录即见「管理分配」页。

## 5. 部署到 Render（变成公开网址）

> 部署这一步需要你本人在 GitHub / Render 点授权，我不会代点。

1. 把整个 `ta-panel` 文件夹推到 GitHub 一个新仓库（用「蜗牛吉姐姐 / 同步修改工具箱」引导连接，看到绿点才算通）。
2. 打开 https://render.com → 用 **GitHub** 登录 → **New → Static Site**。
3. 选刚才的仓库 → Build Command 留空、Publish directory 填 `ta-panel`（或仓库根目录，看你怎么放）→ Create。
4. 一两分钟后得到一个 `xxx.onrender.com` 网址，发给助教即可。改了分配 → 推一次 GitHub → Render 自动更新。

---

## 6. 助教怎么用（给她们的话术）

> 打开网址 → 注册/登录 → 默认在「我的课表」→ 去「全部席位」点「✋ 认领这个席位」→ **认领后课程内容立刻展开**（教学目标/讲法/实操/卡点/能力清单），不用再去找课件。Robin 说的「用户越少点击越好」就在这。

---

## 7. 费用与安全提醒

- 全免费计划，绝不绑信用卡；Supabase 免费 500MB / 5 万月活，内部助教数据完全够用。
- 内部数据：不要把 `anon key` 当秘密——它本就可公开，真正的安全靠 RLS 权限。管理员账号请你们两人自己保管。
- 文档与代码归 Robin 组织仓库管理（「蜗牛吉姐姐 / 同步修改工具箱」），本面板只负责把分配搭起来并部署。

---

## 8. 还能更优的地方（Robin 问的「还有没有更优的方式」）

按「用户越少点击、越快完成越好」的原则，后续可加（都已预留接口）：

1. **Grace 预分配 + 助教一键确认**：现在空白席位要助教自己抢；可改成 Grace 在「管理」页直接指派，助教端只出现「✅ 确认认领」，一步到位。
2. **实时推送**：已接 Supabase Realtime，认领/分配改动助教端**秒级刷新**，不用手动刷新。
3. **日历/周视图**：按周分组已做好，可再加「本月 Zoom 课表」导出，直接粘到群里。
4. **认领即发企微通知**：接 Supabase Edge Function + 企微 Webhook，有人认领/被指派，群里立刻收到卡片。
5. **移动端优先**：面板已做响应式，手机打开就能认领；可再做成 PWA 加到手机桌面。
6. **课程内容结构化检索**：模块指南已存数据库，可加搜索框，助教输入「Stripe」「GEO」直接定位到对应席位内容。

先做 1+2 性价比最高，其余按需再加。
