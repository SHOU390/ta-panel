-- ===========================================================
-- 迁移：为 sessions 表新增 seat_detail（本席位专属授课内容）
-- 在 Supabase SQL Editor 一次性执行即可（幂等，可重复跑）
-- ===========================================================

alter table public.sessions add column if not exists seat_detail jsonb;

update public.sessions set seat_detail = '{"title": "认知导入", "covers": "环节一导入 + 新授①AI相信观 ②万能公式", "duration_label": "约40分钟", "acceptance": "学员能用自己的话复述AI相信观；用公式改写一条烂指令。"}'::jsonb where id = 1;
update public.sessions set seat_detail = '{"title": "唯一入口与三模式", "covers": "新授③龙虾三模式", "duration_label": "约30分钟", "acceptance": "学员能区分三种模式并各举一个适用场景。"}'::jsonb where id = 2;
update public.sessions set seat_detail = '{"title": "技能创建与全量设置", "covers": "新授④三句话+全量设置 + 环节四小结作业", "duration_label": "约50分钟", "acceptance": "每名学员跑通第一个技能；《龙虾文件夹》建好。"}'::jsonb where id = 3;
update public.sessions set seat_detail = '{"title": "验收展示", "covers": "环节三·周四Review验收四动作", "duration_label": "约70分钟", "acceptance": "每人技能「跑通」而非「做了」；现场展示数据。"}'::jsonb where id = 4;
update public.sessions set seat_detail = '{"title": "排障与作业评价", "covers": "环节三·卡点 + 环节四作业 + 五·评价", "duration_label": "约60分钟", "acceptance": "指令改写练习达标；文件夹验收；态度观察（先改指令不换工具）。"}'::jsonb where id = 5;
update public.sessions set seat_detail = '{"title": "版本底座", "covers": "环节一导入 + 新授①GitHub底座", "duration_label": "约40分钟", "acceptance": "学员理解「下载是取钱、发布是存钱」的版本逻辑。"}'::jsonb where id = 6;
update public.sessions set seat_detail = '{"title": "技能生态与官制", "covers": "新授②技能库 ③三层官制", "duration_label": "约35分钟", "acceptance": "能说清三层分工；会从学生仓安装技能。"}'::jsonb where id = 7;
update public.sessions set seat_detail = '{"title": "发布实操", "covers": "新授④三Agent+小布 + 环节四小结", "duration_label": "约45分钟", "acceptance": "独立完成一次「小布检查并发布」全流程。"}'::jsonb where id = 8;
update public.sessions set seat_detail = '{"title": "验收展示", "covers": "环节三·周四Review验收", "duration_label": "约70分钟", "acceptance": "发布动作达标；概念复述准确。"}'::jsonb where id = 9;
update public.sessions set seat_detail = '{"title": "排障与作业评价", "covers": "环节三·卡点 + 环节四作业 + 五·评价", "duration_label": "约60分钟", "acceptance": "养成「发布才算交付」习惯；技能安装数量与运行率。"}'::jsonb where id = 10;
update public.sessions set seat_detail = '{"title": "需求澄清", "covers": "环节一导入 + 新授①四问 ②四件套", "duration_label": "约45分钟", "acceptance": "能用四问逼出真实需求；理解先手动后自动化。"}'::jsonb where id = 11;
update public.sessions set seat_detail = '{"title": "策划书", "covers": "新授③策划书两版", "duration_label": "约35分钟", "acceptance": "能套模板产出项目策划书结构。"}'::jsonb where id = 12;
update public.sessions set seat_detail = '{"title": "对标拆解", "covers": "新授④找对标 + 环节四小结", "duration_label": "约40分钟", "acceptance": "列出对标站页面/模块/CTA清单。"}'::jsonb where id = 13;
update public.sessions set seat_detail = '{"title": "验收展示", "covers": "环节三·周四Review验收", "duration_label": "约70分钟", "acceptance": "策划书简版覆盖四问+收款。"}'::jsonb where id = 14;
update public.sessions set seat_detail = '{"title": "排障与作业评价", "covers": "环节三·卡点 + 环节四作业 + 五·评价", "duration_label": "约60分钟", "acceptance": "需求清晰度；对标拆解区分借鉴与复制。"}'::jsonb where id = 15;
update public.sessions set seat_detail = '{"title": "MVP与口令", "covers": "环节一导入 + 新授①MVP ②三条口令", "duration_label": "约40分钟", "acceptance": "能把功能清单砍到核心主流程；口令一字不差。"}'::jsonb where id = 16;
update public.sessions set seat_detail = '{"title": "部署实操", "covers": "新授③Render部署（实操）", "duration_label": "约50分钟", "acceptance": "每位学员拿到项目公开链接。"}'::jsonb where id = 17;
update public.sessions set seat_detail = '{"title": "协作纪律", "covers": "新授④四大纪律 + 环节四小结", "duration_label": "约30分钟", "acceptance": "理解循环测试与换思路心理。"}'::jsonb where id = 18;
update public.sessions set seat_detail = '{"title": "验收展示", "covers": "环节三·周四Review验收", "duration_label": "约70分钟", "acceptance": "链接硬门槛；双端一致。"}'::jsonb where id = 19;
update public.sessions set seat_detail = '{"title": "排障与作业评价", "covers": "环节三·卡点 + 环节四作业 + 五·评价", "duration_label": "约60分钟", "acceptance": "MVP纪律；协作纪律执行。"}'::jsonb where id = 20;
update public.sessions set seat_detail = '{"title": "收款闭环", "covers": "环节一导入(红绿灯) + 新授①Stripe", "duration_label": "约50分钟", "acceptance": "每人收款链路真实跑通1澳元测试。"}'::jsonb where id = 21;
update public.sessions set seat_detail = '{"title": "获客引擎 I", "covers": "新授②SEO三件套", "duration_label": "约35分钟", "acceptance": "理解三件套各自用途并准备配置。"}'::jsonb where id = 22;
update public.sessions set seat_detail = '{"title": "获客引擎 II · GEO", "covers": "新授③GEO（实操） + 环节四小结", "duration_label": "约35分钟", "acceptance": "产出SEO诊断报告与GEO结论句。"}'::jsonb where id = 23;
update public.sessions set seat_detail = '{"title": "验收展示", "covers": "环节三·周四Review验收", "duration_label": "约70分钟", "acceptance": "收款硬门槛；三件套配置完整。"}'::jsonb where id = 24;
update public.sessions set seat_detail = '{"title": "排障与作业评价", "covers": "环节三·卡点+红绿灯 + 环节四作业 + 五·评价", "duration_label": "约60分钟", "acceptance": "合规意识；GEO输出质量。"}'::jsonb where id = 25;
update public.sessions set seat_detail = '{"title": "AI客服", "covers": "环节一导入 + 新授①元器AI客服（实操）", "duration_label": "约55分钟", "acceptance": "搭建能回答常见问题的AI客服。"}'::jsonb where id = 26;
update public.sessions set seat_detail = '{"title": "CRM与账单", "covers": "新授②CRM+邮件账单", "duration_label": "约35分钟", "acceptance": "理解客户与账单自动化链路。"}'::jsonb where id = 27;
update public.sessions set seat_detail = '{"title": "通知三档", "covers": "新授③企微三档（实操） + 环节四小结", "duration_label": "约30分钟", "acceptance": "选型并配置一种企微通知。"}'::jsonb where id = 28;
update public.sessions set seat_detail = '{"title": "验收展示", "covers": "环节三·周四Review验收", "duration_label": "约70分钟", "acceptance": "客服有效；自动化闭环跑通。"}'::jsonb where id = 29;
update public.sessions set seat_detail = '{"title": "排障与作业评价", "covers": "环节三·卡点+红绿灯 + 环节四作业 + 五·评价", "duration_label": "约60分钟", "acceptance": "自动化链路无断点；合规。"}'::jsonb where id = 30;
update public.sessions set seat_detail = '{"title": "第二大脑与日记", "covers": "环节一导入 + 新授①ima ②录音日记", "duration_label": "约50分钟", "acceptance": "理解第二大脑与全自动日记流水线。"}'::jsonb where id = 31;
update public.sessions set seat_detail = '{"title": "数字人与远程", "covers": "新授③数字人+远程三件套", "duration_label": "约35分钟", "acceptance": "说出远程三件套各自作用。"}'::jsonb where id = 32;
update public.sessions set seat_detail = '{"title": "记忆体系", "covers": "新授④记忆体系 + 环节四小结", "duration_label": "约35分钟", "acceptance": "理解记忆合并与发布风控。"}'::jsonb where id = 33;
update public.sessions set seat_detail = '{"title": "验收展示", "covers": "环节三·周四Review验收", "duration_label": "约70分钟", "acceptance": "检索返回出处；流水线跑通。"}'::jsonb where id = 34;
update public.sessions set seat_detail = '{"title": "排障与作业评价", "covers": "环节三·卡点+进阶 + 环节四作业 + 五·评价", "duration_label": "约60分钟", "acceptance": "合规（录音/风控）；概念清晰。"}'::jsonb where id = 35;
update public.sessions set seat_detail = '{"title": "投资框架", "covers": "环节一导入(合规) + 新授①投资三系统 ②房产股票", "duration_label": "约50分钟", "acceptance": "用框架而非代码；清晰合规边界。"}'::jsonb where id = 36;
update public.sessions set seat_detail = '{"title": "财富系统与服务器", "covers": "新授③财富专家+AI服务器", "duration_label": "约35分钟", "acceptance": "理解财富系统与数字员工闭环。"}'::jsonb where id = 37;
update public.sessions set seat_detail = '{"title": "毕业路演", "covers": "新授④路演四问 + 环节四小结", "duration_label": "约35分钟", "acceptance": "写好3分钟路演稿框架。"}'::jsonb where id = 38;
update public.sessions set seat_detail = '{"title": "毕业路演展示", "covers": "环节三·周四毕业路演", "duration_label": "约80分钟", "acceptance": "路演讲清真生意；链接收款硬门槛。"}'::jsonb where id = 39;
update public.sessions set seat_detail = '{"title": "结算与作业评价", "covers": "环节三·结算 + 环节四作业 + 五·评价", "duration_label": "约50分钟", "acceptance": "能力清单达成率；合规始终前置。"}'::jsonb where id = 40;