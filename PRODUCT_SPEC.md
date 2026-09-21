# Student Schedule

## 0. 文档目的

Student Schedule 是一个面向大学生个人使用的跨平台时间与任务管理工具。

目标平台：

- macOS
- iPadOS
- Android

产品主要解决四个问题：

1. 我已经有哪些不能移动的课程、会议和活动？
2. 接下来有哪些任务即将到 DDL？
3. 我准备在什么时候完成这些任务？
4. 一个复杂事项应该如何随着执行过程不断拆解？

本产品不是单纯的 Calendar，也不是单纯的 Todo List。

它的核心模型是：

**Event + Task + Project + TimeBlock**

其中：

- Event 表示“某个时间必须发生的事情”
- Task 表示“某个时间之前必须完成的事情”
- Project 表示“一组围绕同一目标的相关工作”
- TimeBlock 表示“我计划在某段时间推进某个 Task”

---

# 1. 产品原则

## 1.1 Capture 必须快

用户临时想到：

> 周四之前找副书记确认名单

不应该被迫填写：

- 优先级
- Project
- Category
- 预计时长
- 描述
- 标签
- 提醒时间

最低只输入：

> 找副书记确认名单

即可保存。

其他信息允许之后补充。

---

## 1.2 Deadline 和 Schedule 必须分开

例如：

> 高数作业周五 23:59 截止

这是一个 Task。

如果用户计划：

> 周二 20:00–20:40 做一次  
> 周四 19:00–20:30 再做一次

这是同一个 Task 对应的两个 TimeBlock。

因此：

```text
Task
High Math Homework
due: Friday 23:59

    ↓

TimeBlock A
Tuesday 20:00–20:40

TimeBlock B
Thursday 19:00–20:30
```

Task 的 deadline 不因为 TimeBlock 的移动而变化。

TimeBlock 的移动也不能修改 Task deadline。

---

## 1.3 大任务允许逐渐展开

用户不需要一开始就规划完整 Project。

例如最开始：

```text
团支部推优

├── 收集材料
├── 正式会议
└── 后期处理
```

执行“收集材料”时可能继续展开：

```text
团支部推优

├── 收集材料
│   ├── 通知相关同学
│   ├── 建立名单
│   ├── 催交材料
│   └── 核对材料
│
├── 正式会议
└── 后期处理
```

因此：

**创建 Subtask 必须是核心操作，而不是隐藏在复杂菜单里的高级功能。**

---

## 1.4 不要求用户提前规划完美

系统必须允许：

- Task 没有 deadline
- Task 没有 Project
- Task 没有 Category
- Project 没有完整结构
- Task 没有安排 TimeBlock
- Task 后续才增加 Subtask
- Task 后续才决定执行时间

产品应该支持：

> 先记录 → 再整理 → 再安排 → 执行过程中继续拆解

而不是要求：

> 先完整规划 → 才允许保存

---

# 2. 核心领域模型

---

## 2.1 Project

Project 表示一个相对复杂、需要多个步骤完成的目标。

例如：

- 团支部推优
- 科研项目 A
- 期中考试复习
- 数模比赛准备
- 班级团日活动

Project 自身不是一个 Todo。

它是 Task 和相关 Event 的容器。

### 字段

```text
Project

id
title
description?
categoryId?

status
    active
    done
    archived

targetDate?

createdAt
updatedAt
deletedAt?
```

### targetDate

`targetDate` 只是一个整体目标日期。

它不能代替 Task 的 deadline。

例如：

```text
Project:
团支部推优

targetDate:
October 20
```

真正需要提醒用户的事项仍然应该表现为：

```text
Task:
提交最终材料

due:
October 20
```

---

# 3. Task

Task 表示：

> 某件需要被完成的事情。

例如：

- 写高数作业
- 收集入党志愿书
- 预约会议室
- 复习第三章
- 阅读论文
- 给老师发送材料

---

## 3.1 Task 数据结构

```text
Task

id

title
notes?

projectId?
parentTaskId?
categoryId?

status

isInbox

dueKind
dueDate?
dueAt?

estimateMinutes?

sortOrder

createdAt
updatedAt
completedAt?
deletedAt?
```

---

# 4. Task Status

真正持久化的 Task status 只有：

```text
todo
doing
waiting
done
cancelled
```

---

## 4.1 Todo

任务已经明确，但尚未开始。

---

## 4.2 Doing

当前正在推进。

Doing 不意味着用户此刻正在计时。

它表示：

> 这是当前正在主动推进的事项。

---

## 4.3 Waiting

暂时无法继续，需要等待外部条件。

例如：

- 等老师回复
- 等副书记确认名单
- 等材料提交
- 等实验数据
- 等会议室审批

---

## 4.4 Done

任务已经完成。

记录：

```text
completedAt
```

---

## 4.5 Cancelled

任务不再需要完成。

Cancelled 和 Done 必须区分。

---

# 5. 以下内容不是 Task Status

这一点必须严格遵守。

## Inbox

Inbox 不是 status。

使用：

```text
isInbox = true / false
```

表示任务是否还没有完成整理。

因此一个刚刚快速记录的 Task 可以是：

```text
status = todo
isInbox = true
```

整理之后：

```text
status = todo
isInbox = false
```

---

## Overdue

Overdue 是动态计算状态。

条件：

```text
Task.status != done
Task.status != cancelled
deadline < now
```

不要存：

```text
status = overdue
```

---

## Due Today

动态计算。

不要存入数据库。

---

## Scheduled

动态计算。

如果一个未完成 Task 有未来的 TimeBlock：

```text
scheduled = true
```

否则：

```text
scheduled = false
```

不要出现：

```text
status = scheduled
```

---

## Unscheduled

同样动态计算。

一个有 deadline、但没有未来 TimeBlock 的 Task 可以被 UI 标记为：

> Unscheduled

但它不是 Task status。

---

# 6. Deadline 数据模型

Deadline 必须区分两种情况。

## 情况 A：只有日期

例如：

> 周五交实验报告

用户不知道具体几点。

记录为：

```text
dueKind = date

dueDate = 2026-10-16
dueAt = null
```

不要偷偷把它转换成：

```text
2026-10-16 23:59
```

因为用户从来没有说 deadline 是 23:59。

---

## 情况 B：有明确时间

例如：

> 周五 23:59 截止

记录：

```text
dueKind = datetime

dueAt = ...
```

---

## 情况 C：没有 deadline

```text
dueKind = none
dueDate = null
dueAt = null
```

---

# 7. Subtask

Task 可以拥有 Task 子任务。

通过：

```text
parentTaskId
```

实现。

例如：

```text
收集材料
│
├── 通知相关同学
├── 建立名单
├── 催交材料
└── 核对材料
```

每个子 Task 本质仍然是普通 Task。

因此子 Task 可以拥有：

- 自己的 status
- 自己的 deadline
- 自己的 notes
- 自己的 TimeBlock
- 自己的 subtasks

---

# 8. Subtask 规则

## 8.1 不限制层级

数据模型允许：

```text
Task
  Task
    Task
      Task
```

UI 可以根据实际体验限制过深层级，但数据库层不要限制。

---

## 8.2 不自动继承 deadline

例如：

```text
收集材料
deadline: Oct 15

    ├─ 通知同学
    └─ 催交材料
```

子任务如果没有自己的 deadline：

```text
dueKind = none
```

不要在数据库里复制：

```text
Oct 15
```

UI 可以显示父任务 deadline 作为上下文，但不要修改数据。

---

## 8.3 不自动完成 Parent

如果所有 child tasks 完成：

```text
3 / 3 completed
```

Parent Task 不自动变为 Done。

系统可以以后提示：

> 所有子任务都完成了，是否完成父任务？

但第一版不需要。

---

## 8.4 Project Progress

为了避免父任务和子任务重复计算，Project progress 默认根据：

**leaf tasks**

计算。

例如：

```text
收集材料
├── 通知
├── 催交
└── 核对
```

“收集材料”因为有 children，不作为 progress denominator。

三个 leaf tasks 才参与计算。

例如：

```text
2 / 3 completed
```

Cancelled task 不参与 progress。

---

# 9. Event

Event 表示：

> 某个确定的时间段内发生的事情。

例如：

- 高数课
- 物理实验
- 班委会议
- 团支部正式推优会议
- 和导师见面

---

## Event 数据结构

```text
Event

id

title
notes?

projectId?
categoryId?

startAt
endAt

location?

createdAt
updatedAt
deletedAt?
```

第一阶段不实现复杂 recurring rule。

---

# 10. Event 和 Task 的区别

判断方法：

如果问题是：

> “它什么时候发生？”

通常是 Event。

如果问题是：

> “它什么时候之前必须做完？”

通常是 Task。

例如：

```text
周三 15:00 班委会
→ Event
```

```text
班委会之前整理名单
→ Task
```

```text
周五 23:59 交作业
→ Task
```

```text
周四 20:00–21:00 写作业
→ TimeBlock
```

---

# 11. TimeBlock

TimeBlock 表示：

> 用户计划在什么时候推进一个 Task。

它不是 Event。

虽然它们都会显示在 Calendar 上，但语义不同。

---

## TimeBlock 数据结构

```text
TimeBlock

id

taskId

startAt
endAt

createdAt
updatedAt
deletedAt?
```

TimeBlock 不需要复制：

```text
projectId
categoryId
```

这些信息应该从对应 Task 推导。

---

# 12. 一个 Task 可以对应多个 TimeBlock

例如：

```text
Task:
实验报告

due:
Friday
```

可以安排：

```text
Tuesday
19:00–19:40

Thursday
20:00–21:30
```

因此关系为：

```text
Task 1 → N TimeBlocks
```

---

# 13. TimeBlock 不代表 Task 完成

TimeBlock 到时间结束以后：

Task 不自动 Done。

例如：

```text
20:00–21:00
写实验报告
```

21:00 以后：

如果用户没有完成实验报告：

```text
Task.status
```

保持不变。

产品未来可以提示：

> 这个 Task 的计划时间已经过去，要重新安排吗？

但第一版无需自动处理。

---

# 14. Category

Category 用于描述用户生活中的领域。

默认可以提供：

```text
Course
Assignment
Class Work
Research
Study
Exercise
Personal
```

但不能写死。

用户必须能够：

- 新建
- 重命名
- 删除
- 修改颜色

---

## Category 数据结构

```text
Category

id
name
color

sortOrder

createdAt
updatedAt
deletedAt?
```

---

# 15. Category 继承

Project 可以拥有 category。

Task 可以拥有自己的 category。

如果 Task 没有 category，但属于 Project：

```text
effectiveCategory =
Task.categoryId ?? Project.categoryId
```

因此不要把 Project category 自动复制给 Task。

这样以后修改 Project Category 时，所有继承它的 Task 会自然更新。

Event 同理。

---

# 16. Inbox

Inbox 的目的不是长期管理任务。

它的作用只有：

> 快速捕获暂时还没整理的信息。

Inbox 页面显示：

```text
isInbox = true
```

的 Task。

典型流程：

```text
想到事情
↓
快速输入
↓
Inbox
↓
之后补充信息
↓
移出 Inbox
```

---

# 17. Quick Add

这是整个产品最重要的交互之一。

第一版 Quick Add 不需要自然语言 AI。

最低流程：

```text
+ 
↓
输入标题
↓
Save
```

默认：

```text
type = Task
status = todo
isInbox = true
```

---

## 可选快速字段

Quick Add 可以允许用户进一步选择：

```text
Task / Event

Deadline
Category
Project
```

但这些字段不能阻止保存。

---

# 18. 主导航

产品核心页面固定为：

```text
Week
Deadlines
Projects
Inbox
Settings
```

第一阶段不要加入更多一级导航。

---

# 19. Desktop / iPad Layout

macOS 与较宽的 iPad 使用：

```text
┌────────────┬─────────────────────────────┐
│ Navigation │                             │
│            │          Content            │
│ Week       │                             │
│ Deadlines  │                             │
│ Projects   │                             │
│ Inbox      │                             │
│ Settings   │                             │
│            │                             │
└────────────┴─────────────────────────────┘
```

Week 页面进一步允许：

```text
┌─────────────── Week Calendar ────────────┬──────────┐
│                                         │ Upcoming │
│ Mon Tue Wed Thu Fri Sat Sun             │          │
│                                         │ overdue  │
│                                         │ today    │
│                                         │ next 3d  │
│                                         │          │
└─────────────────────────────────────────┴──────────┘
```

---

# 20. Android Phone Layout

手机不要强行复制桌面布局。

主导航使用 Bottom Navigation：

```text
Week
Deadlines
Projects
Inbox
```

Settings 从其他页面进入。

---

# 21. Phone Week View

手机屏幕不足以清晰显示七个完整时间轴。

因此手机默认使用：

```text
Mon Tue Wed Thu Fri Sat Sun
──────── Week Strip ────────

        Selected Day

08:00
09:00   High Math
10:00   High Math
11:00
...
```

顶部仍然表现“这一周”。

下面重点显示当前选择的一天。

用户左右滑动切换日期。

未来可以提供 3-day view。

第一版不要把桌面七列周历硬缩小到手机屏幕。

---

# 22. Week View 的视觉语义

Week Calendar 上必须明确区分：

## Event

表示不可随意移动的现实时间安排。

视觉上使用：

> solid block

---

## TimeBlock

表示用户自己的计划。

视觉上应该比 Event 更轻。

例如：

> lighter / outlined block

用户必须一眼知道：

> 这是课。

和：

> 这是我计划用来写作业的时间。

不是同一种东西。

---

# 23. Deadline 在 Week 中的表现

Deadline 不应该占据 Calendar 时间轴。

例如：

```text
Friday
实验报告 due
```

如果没有具体时间，不应该画一个：

```text
23:59 event
```

Week View 可以在当天顶部显示：

```text
● 实验报告
```

或者：

```text
2 deadlines
```

点击后展示当天 deadline。

---

# 24. 从 Deadline 到 Schedule

这是核心工作流。

例如 Deadlines sidebar 中：

```text
实验报告
Friday
Unscheduled
```

用户可以：

### Desktop / iPad

把 Task 拖入 Calendar：

```text
Thursday
20:00–21:30
```

系统创建：

```text
TimeBlock
```

Task 本身不发生变化。

### Phone

Task detail 中：

```text
Schedule
```

选择日期和时间。

生成 TimeBlock。

---

# 25. Deadlines Page

默认按以下逻辑分组：

```text
Overdue

Today

Next 3 Days

This Week

Later

No Deadline
```

Done / Cancelled 默认不显示。

---

# 26. Deadline 排序

优先：

```text
Overdue
↓
日期更早
↓
时间更早
```

只有日期、没有时间的任务应明显标记：

```text
No specific time
```

不要伪造 23:59。

---

# 27. Deadline Item 应显示的信息

最低：

```text
Task title
deadline
Project
Category
status
scheduled / unscheduled
```

例如：

```text
实验报告
Physics · Friday
Doing · Scheduled
```

其中：

```text
Doing
```

来自 Task.status。

```text
Scheduled
```

是动态计算。

---

# 28. Projects Page

Project 列表首先显示：

```text
Active Projects
```

每个 Project 卡片显示：

```text
title
category
progress
nearest upcoming deadline
```

例如：

```text
团支部推优
Class Work

4 / 7
Next: 预约会议室 · Tuesday
```

---

# 29. Project Detail

Project Detail 的主要界面不是 Kanban。

它应该更接近：

**Outline / Tree**

例如：

```text
团支部推优

☐ 收集材料
    ☑ 通知相关同学
    ☐ 催交材料
    ☐ 核对材料

☐ 预约会议室

◇ 正式会议
  Thu 15:00

☐ 后期处理
```

---

# 30. Inline Task Creation

Project 页面必须支持：

```text
+ Add Task
```

之后直接在当前位置输入：

```text
核对材料
```

按 Enter：

创建。

继续输入：

创建下一个。

不能每次弹出完整 Task Editor。

---

# 31. Desktop Outline Keyboard UX

后续版本应该支持：

```text
Enter
→ new sibling

Tab
→ indent

Shift + Tab
→ outdent
```

这对于快速拆 Project 非常重要。

第一版如果实现成本较高，可以先只完成：

```text
Enter = new sibling
+ Child = create child
```

---

# 32. Task Detail

Task Detail 最低展示：

```text
Title

Status
Deadline
Project
Category
Estimate

TimeBlocks

Subtasks

Notes
```

---

# 33. Task Detail 中的 Schedule

用户可以：

```text
Add TimeBlock
```

例如：

```text
Wednesday
19:00
60 minutes
```

Task 可以显示：

```text
Scheduled sessions

Wed 19:00–20:00
Thu 14:00–15:30
```

---

# 34. Event Detail

最低：

```text
Title

Start
End

Project
Category

Location
Notes
```

---

# 35. 课程处理

完整 recurrence engine 不属于第一阶段。

对于：

```text
高数

Monday
08:00–09:40

Week 1–16
```

第一阶段可以直接生成：

```text
16 Event instances
```

这样如果第七周停课：

只删除或修改第七周那个 Event。

暂时不处理：

```text
edit this event

edit this and following

edit entire series
```

---

# 36. Search

第一阶段不是必须。

未来搜索应该至少覆盖：

```text
Task title
Project title
Event title
Notes
```

---

# 37. Notifications

不是 V0.1 核心。

后续支持：

### Event reminder

例如：

```text
10 minutes before
```

### Task deadline reminder

例如：

```text
1 day before
1 hour before
```

TimeBlock 是否提醒由用户选择。

---

# 38. 不做时间追踪

TimeBlock 表示：

> planned time

不是：

> actual tracked time

第一版不要加入：

```text
start timer
stop timer
actual duration
productivity score
```

---

# 39. 不做人工 Priority

V1 之前暂时不加入：

```text
P0
P1
P2
P3
```

主要优先信息来自：

```text
deadline
status
scheduled / unscheduled
```

未来如果真实使用证明需要 Priority，再加入。

---

# 40. 不做复杂 Dependency

第一版不支持：

```text
Task A blocks Task B
```

大多数情况使用：

```text
Subtask
Waiting
Deadline
```

表达即可。

---

# 41. 不做 Habit System

例如每周三次锻炼，第一版可以先表现为：

```text
Events / TimeBlocks
```

暂时不加入：

```text
streak
habit score
daily check-in
```

---

# 42. 不做团队协作

产品首先服务单用户。

暂时没有：

```text
workspace
member
role
comment
mention
shared project
```

---

# 43. 不做 AI Auto Scheduling

第一版不让 AI 自动决定：

> 你应该什么时候做什么。

首先建立稳定的：

```text
Task
Event
TimeBlock
Project
```

模型。

未来 AI 只能建立在这些可靠数据之上。

---

# 44. 数据通用规则

所有实体使用 client-generated unique ID。

所有主要实体包含：

```text
createdAt
updatedAt
```

建议支持：

```text
deletedAt
```

作为 soft delete。

原因：

跨设备同步时比直接物理删除更安全。

---

# 45. 删除规则

第一阶段：

普通实体删除采用 soft delete。

UI 中立即消失。

未来可以加入 Trash。

Task 删除时，如果有 TimeBlock：

相关 TimeBlock 同时 soft delete。

对于包含 children 的 Task：

第一版删除整个 subtree。

UI 必须提示：

```text
This task contains 4 subtasks.
Delete all?
```

---

# 46. 数据关系

核心关系：

```text
Category
   │
   ├── Project
   ├── Task
   └── Event


Project
   │
   ├── Task
   │     │
   │     ├── Subtask
   │     │
   │     └── TimeBlock
   │
   └── Event
```

---

# 47. 数据模型总结

```text
Project
├─ id
├─ title
├─ description?
├─ categoryId?
├─ status
├─ targetDate?
├─ createdAt
├─ updatedAt
└─ deletedAt?


Task
├─ id
├─ title
├─ notes?
├─ projectId?
├─ parentTaskId?
├─ categoryId?
├─ status
├─ isInbox
├─ dueKind
├─ dueDate?
├─ dueAt?
├─ estimateMinutes?
├─ sortOrder
├─ createdAt
├─ updatedAt
├─ completedAt?
└─ deletedAt?


Event
├─ id
├─ title
├─ notes?
├─ projectId?
├─ categoryId?
├─ startAt
├─ endAt
├─ location?
├─ createdAt
├─ updatedAt
└─ deletedAt?


TimeBlock
├─ id
├─ taskId
├─ startAt
├─ endAt
├─ createdAt
├─ updatedAt
└─ deletedAt?


Category
├─ id
├─ name
├─ color
├─ sortOrder
├─ createdAt
├─ updatedAt
└─ deletedAt?
```

---

# 48. 必须满足的领域约束

```text
Event.endAt > Event.startAt
```

```text
TimeBlock.endAt > TimeBlock.startAt
```

Task parent 不能形成 cycle。

例如禁止：

```text
A parent = B
B parent = A
```

以及：

```text
A
└─ B
   └─ C
```

然后把 A 移动到 C 下面。

---

# 49. V0.1 目标

V0.1 的目标不是：

> 做出最终漂亮 App。

而是验证：

> 领域模型是不是正确。

V0.1 应该完成：

```text
Project CRUD
Task CRUD
Subtask CRUD
Event CRUD
Category CRUD

Inbox

Deadline basic view

basic local persistence

basic responsive navigation
```

暂时不要求：

```text
完整 Week Calendar
TimeBlock drag & drop
Cloud Sync
Notifications
Recurrence
AI
```

---

# 50. V0.1 页面

必须有：

```text
Week
Deadlines
Projects
Inbox
Settings
```

Week 第一阶段甚至可以只是：

```text
Upcoming Events
```

不需要马上实现完整 Calendar grid。

---

# 51. V0.1 验收案例 A：普通作业

用户可以建立：

```text
Task
高数作业

deadline:
Friday 23:59

category:
Assignment
```

之后可以：

```text
Todo → Doing → Done
```

Deadline 页面能够正确显示。

---

# 52. V0.1 验收案例 B：快速记录

用户输入：

```text
问导师实验数据的问题
```

不填写任何其他信息。

系统保存：

```text
status = todo
isInbox = true
```

Inbox 页面能够看到。

之后用户补充：

```text
Project = Research
Deadline = Wednesday
```

并将：

```text
isInbox = false
```

任务从 Inbox 消失。

---

# 53. V0.1 验收案例 C：团支部推优

建立：

```text
Project:
团支部推优
```

能够逐步建立：

```text
收集材料
├── 通知相关同学
├── 建立名单
├── 催交材料
└── 核对材料

预约会议室

后期处理
```

并且：

做到一半以后仍然可以随时：

```text
Add child task
```

无需重新设计 Project。

---

# 54. V0.1 验收案例 D：Project Progress

假设：

```text
收集材料
├── 通知 ✓
├── 催交 ✓
└── 核对

预约会议室
```

leaf tasks：

```text
通知
催交
核对
预约会议室
```

Project progress 应表现为：

```text
2 / 4
```

而不是：

```text
2 / 5
```

---

# 55. V0.1 验收案例 E：Event

用户建立：

```text
班委会

Wednesday
19:00–20:00
```

它显示为 Event。

它不会出现在 Deadline Task list 中。

---

# 56. V0.5 目标

V0.5 引入真正的时间规划：

```text
Full Week View
TimeBlock
Task → Calendar scheduling
Deadline sidebar
drag / edit TimeBlock
Project Outline UX
```

这一阶段之后，产品形成完整闭环：

```text
Capture
↓
Organize
↓
Break Down
↓
Schedule
↓
Execute
↓
Complete / Reschedule
```

---

# 57. V0.5 核心验收

存在：

```text
Task:
实验报告

deadline:
Friday
```

用户可以安排：

```text
Tue 20:00–21:00
Thu 19:00–20:30
```

Week View 同时显示：

```text
课程 Event
会议 Event
Task TimeBlocks
Friday deadline marker
```

用户能够视觉上区分：

```text
Event
vs
TimeBlock
```

---

# 58. V1.0 目标

V1.0 重点不是增加大量功能。

重点是：

```text
可靠
快速
跨设备
真正每天能用
```

包括：

```text
macOS
iPad
Android

cloud sync
offline usage
notifications
stable Week View
fast capture
fast project breakdown
fast rescheduling
```

---

# 59. V1.0 之后才考虑

只有经过真实使用以后再判断是否加入：

```text
Natural-language input

AI task breakdown

AI scheduling suggestions

Calendar import

Course timetable import

Widgets

Advanced recurrence

Dependencies

Habit tracking

Search

Statistics
```

---

# 60. 最重要的产品判断标准

每一个新功能都必须回答：

> 它是否明显改善以下流程中的某一步？

```text
Capture
↓
Organize
↓
Break Down
↓
Schedule
↓
Execute
↓
Update
```

如果答案是否定的：

暂时不加入。

---

# 61. 产品成功标准

这个产品成功，不意味着拥有最多功能。

真正的成功标准是：

### 早上

用户打开 App，可以迅速知道：

> 今天有什么固定安排？

> 最近有什么 DDL？

### 白天

突然收到一个任务时，可以几秒钟记下来。

### 规划时

可以看到：

> 哪些时间已经被课程/会议占用？

> 哪些 Task 还没安排执行时间？

### 做复杂事情时

发现新步骤，可以立刻：

```text
Add Subtask
```

### 做不完时

可以快速：

```text
Reschedule
```

而不是重新创建任务。

### 一周结束

系统里的信息仍然可信。

用户不需要同时维护：

```text
Calendar
Todo App
Notes
脑内记忆
```

四套互相冲突的系统。

这就是 Student Schedule 的核心价值。
