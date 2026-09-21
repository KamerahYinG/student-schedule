# ARCHITECTURE.md

# Student Schedule — Architecture

## 0. 文档状态

本文档定义 Student Schedule 的目标工程架构。

当前产品阶段：

**V0.1**

当前最重要的工程目标不是“把功能尽快堆出来”，而是建立一个：

- 可以持续迭代
- 不混淆领域语义
- 支持本地优先
- 未来可以加入跨设备同步
- 不需要频繁推倒重写

的基础结构。

`PRODUCT_SPEC.md` 定义“产品应该做什么”。

本文档定义“代码应该如何组织，以及哪些边界不能跨越”。

---

# 1. 当前技术方向

客户端：

```text
Flutter
Dart
```

目标平台：

```text
macOS
iPadOS / iOS
Android
```

采用：

```text
single Flutter codebase
```

V0.1 不实现 Web。

---

# 2. V0.1 技术决策

V0.1 使用：

```text
Flutter
Riverpod
Drift / SQLite
```

分别负责：

```text
Flutter
→ UI 与跨平台客户端

Riverpod
→ application state / dependency injection / reactive state

Drift + SQLite
→ 本地持久化
```

V0.1 明确**不接云后端**。

因此这一阶段不要添加：

```text
Firebase
Firestore
Supabase
Appwrite
custom backend
```

云同步供应商在 V1.0 前通过单独技术验证后再决定。

---

# 3. 为什么 V0.1 先 Local-first

Student Schedule 的核心数据：

- Task
- Project
- Event
- TimeBlock
- Category

都应该在没有网络时正常工作。

对于个人 Schedule 工具来说：

> 打开 App → 查看 → 新建 → 修改 → 勾掉任务

不能依赖网络请求成功。

所以 V0.1 直接把本地数据库视为应用的主要数据源。

未来的 Cloud Sync 是：

```text
local data
↕
sync layer
↕
remote data
```

而不是让 UI 直接读取云数据库。

---

# 4. 云同步暂时不选供应商

不要因为未来需要同步，就在 V0.1 提前把 Firebase/Supabase 类型传播到代码里。

未来无论选择：

```text
Firestore
Supabase
custom service
```

Domain 和 Feature UI 都不应该知道具体供应商。

必须保持：

```text
UI
↓
Repository Contract
↓
Data Implementation
```

因此以后增加 Cloud Sync 时，目标是新增 Data/Sync 层，而不是重写 UI。

---

# 5. 架构原则

采用**务实的分层架构**。

不采用过度复杂的 enterprise Clean Architecture。

不要为了每一个简单 CRUD 操作都创建一个 UseCase class。

核心层次：

```text
Presentation / Feature
        ↓
Application State
        ↓
Domain Repository Contract
        ↓
Data Repository Implementation
        ↓
Local Database
```

依赖方向只能向下。

---

# 6. 目标目录结构

建议逐步收敛为：

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── app_shell.dart
│   └── app_breakpoints.dart
│
├── core/
│   ├── ids/
│   │   └── id_generator.dart
│   │
│   └── time/
│       ├── clock.dart
│       └── local_date.dart
│
├── domain/
│   ├── models/
│   │   ├── project.dart
│   │   ├── task.dart
│   │   ├── event.dart
│   │   ├── time_block.dart
│   │   └── category.dart
│   │
│   ├── enums/
│   │   ├── project_status.dart
│   │   ├── task_status.dart
│   │   └── due_kind.dart
│   │
│   ├── repositories/
│   │   ├── project_repository.dart
│   │   ├── task_repository.dart
│   │   ├── event_repository.dart
│   │   ├── time_block_repository.dart
│   │   └── category_repository.dart
│   │
│   └── services/
│       ├── deadline_rules.dart
│       └── project_progress.dart
│
├── data/
│   ├── local/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   └── migrations/
│   │
│   ├── mappers/
│   └── repositories/
│
├── features/
│   ├── week/
│   ├── deadlines/
│   ├── projects/
│   ├── inbox/
│   └── settings/
│
└── shared/
    └── widgets/
```

这是一份**目标结构**。

不要为了满足目录图而立刻做无意义的大规模文件搬迁。

当前已有的：

```text
lib/domain/models.dart
```

可以暂时保留。

在第一次实现本地 persistence、repository contract 时，再自然拆分。

原则：

> 因需求而重构，不为目录美观而重构。

这可以显著减少 Codex token 和无意义 diff。

---

# 7. Domain 层

Domain 是产品语义的核心。

Domain：

- 可以依赖 Dart
- 不依赖 Flutter Widget
- 不依赖 Riverpod
- 不依赖 Drift
- 不依赖 Firebase/Supabase
- 不依赖页面组件

这里放：

```text
Project
Task
Event
TimeBlock
Category
```

以及：

```text
TaskStatus
ProjectStatus
DueKind
```

和不依赖数据库的规则。

---

# 8. Domain model 与数据库 model 分开

不要让 Drift generated row 直接成为整个应用中的 Task。

正确：

```text
Drift TaskRow
↓ mapper
Domain Task
↓
Feature/UI
```

原因：

以后修改数据库字段、迁移数据或替换存储实现时，不应迫使 UI 改写。

---

# 9. Repository Contract

Repository interface 定义在：

```text
domain/repositories/
```

实现定义在：

```text
data/repositories/
```

例如概念上：

```text
TaskRepository
```

负责：

```text
watch tasks
get task
save task
soft delete task
watch inbox tasks
watch tasks with deadlines
```

Project/Event/TimeBlock/Category 同理。

不要让页面执行 SQL。

不要让 Widget 拿到 `AppDatabase`。

---

# 10. Application State

使用 Riverpod。

Riverpod 主要负责：

```text
repository dependency injection
reactive query state
feature controller state
async loading/error state
```

推荐数据流：

```text
Widget
↓
Feature Controller / Provider
↓
Repository
↓
Database
```

数据库更新：

```text
Database
↓ stream
Repository
↓ provider
UI automatically refreshes
```

---

# 11. 不做 Global Mutable Store

不要创建：

```text
global List<Task>
global singleton mutable state
static task cache
```

本地数据库才是 V0.1 的持久化 source of truth。

Riverpod state 负责：

```text
UI/application state
```

而不是充当数据库。

---

# 12. 错误处理

V0.1 不引入复杂：

```text
Either
Result monad
custom error hierarchy
```

Repository 遇到不可恢复的 data error 可以抛出明确 exception。

Riverpod 使用：

```text
AsyncValue
```

向 UI 表示：

```text
loading
data
error
```

后续如果错误模型变复杂，再演进。

---

# 13. ID

所有主要实体使用 client-generated unique ID。

V0.1 推荐：

```text
UUID
```

ID 在创建实体时立即生成。

不要使用数据库 auto-increment ID 作为领域实体 ID。

原因：

未来跨设备同步时，client-generated ID 更容易合并。

---

# 14. 日期与时间：最重要的基础规则之一

Deadline 分为：

```text
none
date
datetime
```

严格遵守 `PRODUCT_SPEC.md`。

---

# 15. Date-only 不得使用假的午夜/23:59

例如：

> Friday due

这是：

```text
LocalDate
```

而不是：

```text
Friday 00:00
```

也不是：

```text
Friday 23:59
```

Domain 中应该有明确的 date-only value。

推荐：

```text
LocalDate
year
month
day
```

持久化时可以编码为：

```text
YYYY-MM-DD
```

例如：

```text
2026-10-16
```

这样不会因为 timezone conversion 改变日期。

---

# 16. Datetime

以下字段是真正的时间点：

```text
Task.dueAt
Event.startAt
Event.endAt
TimeBlock.startAt
TimeBlock.endAt
createdAt
updatedAt
completedAt
deletedAt
```

持久化时统一使用 UTC。

UI 展示时：

```text
UTC
→ current device local timezone
```

V0.1 不实现用户自选 timezone。

---

# 17. Overdue 计算

Overdue 不入库。

对于：

```text
dueKind = datetime
```

规则：

```text
dueAt < now
```

并且 Task 不是：

```text
done
cancelled
```

---

对于：

```text
dueKind = date
```

只比较本地 calendar date。

例如今天：

```text
2026-10-16
```

一个 dueDate：

```text
2026-10-16
```

在今天全天都不算 overdue。

只有进入：

```text
2026-10-17
```

后才 overdue。

这是 date-only deadline 和 datetime deadline 的关键差异。

---

# 18. Inbox

Inbox 使用：

```text
Task.isInbox
```

它与：

```text
Task.status
```

互相独立。

允许：

```text
status = todo
isInbox = true
```

禁止创建：

```text
TaskStatus.inbox
```

---

# 19. Scheduled / Unscheduled

不持久化。

如果一个 active Task 存在未来 TimeBlock：

```text
scheduled = true
```

否则：

```text
scheduled = false
```

禁止创建：

```text
TaskStatus.scheduled
TaskStatus.unscheduled
```

---

# 20. Project Progress

按 `PRODUCT_SPEC.md`：

只计算 leaf task。

忽略：

```text
cancelled
soft-deleted
```

父 Task 本身有 children 时不进入 denominator。

例如：

```text
Parent
├── A ✓
├── B ✓
└── C
```

progress：

```text
2 / 3
```

不是：

```text
2 / 4
```

这个计算属于 Domain service。

不要把它作为持久化字段存数据库。

---

# 21. Category inheritance

Task 有：

```text
categoryId?
```

Project 有：

```text
categoryId?
```

effective category：

```text
task.categoryId ?? project.categoryId
```

这是动态推导。

不要在 Task 创建时把 Project category 复制进去。

否则以后修改 Project category 会产生数据不一致。

---

# 22. Soft Delete

主要实体支持：

```text
deletedAt?
```

默认 query 不返回：

```text
deletedAt != null
```

V0.1 暂时不需要 Trash UI。

Task 删除时：

- Task soft delete
- 它对应的 TimeBlock soft delete

如果 Task 有 children：

- 整个 subtree soft delete

真正执行删除前，UI 应按 Product Spec 提示。

---

# 23. Database

V0.1 使用 Drift + SQLite。

表：

```text
projects
tasks
events
time_blocks
categories
```

数据库 schema version 从：

```text
1
```

开始。

任何 schema 修改必须：

- 增加 schema version
- 明确 migration

不要删除用户数据后重新建库来“解决” migration。

开发早期确实需要 destructive reset 时，也必须明确标注为 development-only。

---

# 24. Database 字段原则

数据库字段应尽量对应 Domain 数据，而不是 UI 状态。

不要持久化：

```text
overdue
scheduled
unscheduled
effectiveCategory
projectProgress
```

这些全部动态计算。

---

# 25. sortOrder

V0.1 使用：

```text
integer sortOrder
```

同一 parent 下按 sortOrder 排序。

移动/重排时允许重新编号 sibling tasks。

现在不要提前实现复杂 fractional indexing / CRDT ordering。

未来跨设备同步真正需要时再升级。

---

# 26. Task parent cycle

Repository/domain validation 必须防止 cycle。

禁止：

```text
A.parent = A
```

禁止：

```text
A
└── B
    └── C
```

然后：

```text
A.parent = C
```

验证必须在 persistence 前完成。

---

# 27. UI 架构

Feature 页面放在：

```text
features/
```

每个 feature 只负责自己的 UI 与 feature-specific controller/provider。

例如：

```text
features/inbox/
├── inbox_page.dart
├── inbox_controller.dart
└── inbox_providers.dart
```

不要把所有业务逻辑堆进：

```text
app_shell.dart
```

---

# 28. Responsive Layout

布局根据可用宽度判断。

不要写：

```text
if Android → phone layout
if iPad → tablet layout
if macOS → desktop layout
```

同一设备窗口宽度也会变化。

采用 width breakpoint。

建议：

```text
compact:
< 600

medium:
600–839

expanded:
>= 840
```

---

# 29. Compact

主要用于手机。

使用：

```text
BottomNavigationBar / NavigationBar
```

主入口：

```text
Week
Deadlines
Projects
Inbox
```

Settings 从 AppBar 或菜单进入。

---

# 30. Medium

可以使用：

```text
NavigationRail
```

内容保持单主栏。

---

# 31. Expanded

使用：

```text
NavigationRail
+
main content
```

未来 Week View 可以增加：

```text
deadline sidebar
```

但 V0.1 暂时不用提前实现完整三栏布局。

---

# 32. Navigation

V0.1 当前只有少量一级页面。

如果现有简单导航已经工作：

**暂时保留。**

不要仅仅因为“正规项目应该用 router”就立即加入 `go_router`。

当出现：

```text
Task Detail
Project Detail
Event Detail
deep linking
nested navigation
```

并且现有方案明显变复杂时，再评估 router。

原则仍然是：

> 不提前为未来复杂度付费。

---

# 33. Week V0.1

V0.1 不实现完整 Calendar grid。

Week 页面只需要验证：

```text
Event data can be read
upcoming events can be rendered
responsive shell works
```

不要在 V0.1 引入 Calendar package。

完整周历属于 V0.5。

---

# 34. Calendar package

V0.5 开始前单独做 technical spike。

评估：

```text
drag/drop
resize
overlapping events
desktop pointer input
touch input
week layout
performance
maintenance status
```

测试之后再决定：

```text
third-party package
vs
custom calendar implementation
```

不要现在锁死。

---

# 35. Local persistence first

V0.1 UI 与 DB 的关系：

```text
UI
↓
Riverpod
↓
Repository
↓
Drift
↓
SQLite
```

禁止：

```text
Widget → Drift query
```

---

# 36. Future sync boundary

以后加入同步时，目标结构：

```text
                 ┌─ LocalDataSource
Repository/Sync ─┤
                 └─ RemoteDataSource
```

UI 仍然只面对 Repository。

未来同步需要考虑：

```text
conflict resolution
deleted records
updatedAt
device offline
multiple device edits
```

但这些不属于 V0.1。

---

# 37. updatedAt

所有 mutable entity：

```text
updatedAt
```

每次内容变化时更新。

未来同步会依赖它。

V0.1 不使用 `updatedAt` 做复杂 conflict resolution。

---

# 38. Clock abstraction

与“现在几点”有关的 Domain logic 不要到处直接写：

```text
DateTime.now()
```

推荐通过一个简单：

```text
Clock
```

抽象。

Production Clock：

```text
system now
```

Test Clock：

```text
fixed now
```

这样可以可靠测试：

```text
overdue
today
next 3 days
```

不需要引入复杂时间框架。

---

# 39. Testing Strategy

V0.1 测试重点按价值排序：

## Domain tests

必须优先覆盖：

```text
date-only overdue
datetime overdue
done/cancelled not overdue
category inheritance
leaf-task project progress
task parent cycle prevention
```

这些是最容易发生“看起来能运行但语义错了”的地方。

---

## Repository tests

覆盖：

```text
CRUD
soft delete
subtree delete
TimeBlock cleanup
Inbox query
deadline query
```

---

## Widget tests

至少覆盖：

```text
compact navigation
wide navigation
page switching
Settings access on phone
```

不要追求大量 snapshot/golden tests。

---

# 40. Static analysis

项目应开启 Flutter/Dart 推荐 lints。

但不要加入几十条纯风格 lint 导致 Codex 大量花 token 修格式。

原则：

```text
correctness
maintainability
> stylistic perfection
```

---

# 41. Comments

代码应主要靠命名表达意图。

只在以下情况写 comment：

- 领域规则不明显
- timezone/date-only 语义容易误解
- workaround
- 平台限制

不要生成逐行解释代码的冗余注释。

---

# 42. Platform scaffold

当前 Codex 环境曾报告：

> Flutter SDK is not installed.

因此目前不能把：

```text
android/
ios/
macos/
```

中的 README/占位目录视为真正 Flutter platform project。

正式 platform scaffold 必须在 Flutter SDK 可用的环境中，由 Flutter CLI 生成。

推荐在已有代码先 commit 后执行：

```bash
flutter create \
  --project-name student_schedule \
  --platforms=android,ios,macos \
  .
```

执行后必须检查：

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
```

在 macOS 上还需要实际尝试：

```bash
flutter run -d macos
```

Android/iOS 在对应 SDK / simulator 可用后再验证。

不要手工编写伪造的 Xcode/Gradle scaffold 来代替 Flutter CLI。

---

# 43. 当前代码如何处理

已有：

```text
app_shell.dart
models.dart
placeholder pages
widget_test.dart
```

不需要撤销。

把当前状态视为：

```text
provisional scaffold
```

下一轮不要立即大规模重构。

先做：

```text
environment/scaffold verification
```

再逐步把它收敛到本文档的 target architecture。

---

# 44. V0.1 实现顺序

建议严格按以下顺序推进。

## M0 — Environment & Scaffold

目标：

```text
真实 Flutter project
pub get works
analyze works
test works
macOS build/run works
```

如果 SDK 不可用：

明确 blocker。

不要假装完成。

---

## M1 — Domain correctness

整理现有 Domain model。

实现并测试：

```text
TaskStatus
ProjectStatus
DueKind
LocalDate
deadline rules
category inheritance
project progress
cycle protection
```

这一步不要做 UI 大改。

---

## M2 — Local Database

加入：

```text
Drift
SQLite
tables
mappers
repository contracts
local repository implementations
```

验证 CRUD 与 soft delete。

---

## M3 — Category + Task + Inbox

先完成最基本真实工作流：

```text
Quick Add Task
↓
Inbox
↓
edit
↓
organize
↓
remove from Inbox
```

---

## M4 — Deadlines

实现：

```text
Overdue
Today
Next 3 Days
This Week
Later
No Deadline
```

确保 date-only 与 datetime 语义正确。

---

## M5 — Projects + Subtasks

实现：

```text
Project CRUD
Task tree
Add child
progress
subtree delete
```

先保证数据与交互正确。

复杂拖拽以后再做。

---

## M6 — Events

实现：

```text
Event CRUD
Upcoming Events
Week V0.1 placeholder replacement
```

仍然不做完整 calendar grid。

---

# 45. V0.1 结束条件

V0.1 完成时，必须能用真实数据走完：

### Case A

```text
创建高数作业
→ 设置周五 deadline
→ Deadline 页面看到
→ Doing
→ Done
```

### Case B

```text
Quick Add
“问导师实验数据的问题”
→ Inbox
→ 补 Project + deadline
→ 移出 Inbox
```

### Case C

```text
创建团支部推优 Project
→ 新建 Task
→ 一边做一边 Add Child
→ progress 正确
```

### Case D

```text
创建班委会 Event
→ Upcoming Events 显示
→ 不进入 Deadline list
```

全部使用真实本地 persistence。

App 重启后数据仍然存在。

---

# 46. 明确不属于 V0.1

不要实现：

```text
full week calendar
TimeBlock drag & drop
cloud sync
Firebase
Supabase
notifications
AI
natural language parser
habit system
team collaboration
advanced recurrence
complex dependencies
statistics
```

TimeBlock 的 Domain model 可以存在。

但完整 schedule UI 属于 V0.5。

---

# 47. Dependency budget

V0.1 尽量控制 production dependencies。

预期核心依赖只围绕：

```text
Riverpod
Drift / SQLite
UUID
```

以及它们确实需要的基础 supporting packages。

每新增一个明显的大型依赖，都必须能回答：

> 当前 milestone 为什么没有它就无法合理完成？

否则不加。

---

# 48. Codex 工作方式

每次交给 Codex 的任务应尽可能小。

推荐：

```text
Read AGENTS.md, PRODUCT_SPEC.md and ARCHITECTURE.md first.

Implement M1 only.

Do not start M2.
```

而不是：

```text
Build V0.1.
```

一个 milestone 仍然太大时，继续拆。

例如 M1 可以拆：

```text
M1.1 LocalDate + DueKind
M1.2 deadline rules
M1.3 project progress
M1.4 category inheritance
M1.5 cycle validation
```

这样：

- Codex 上下文更短
- diff 更容易审核
- 出错更容易回滚
- token 更省
- 架构更不容易漂移

---

# 49. 最终工程原则

这个项目不追求“最复杂、最先进”的架构。

追求：

```text
correct domain semantics
clear boundaries
small changes
offline reliability
future syncability
low maintenance burden
```

如果两种实现都能满足需求：

优先选择：

> 更简单、更容易测试、更容易以后修改的那个。
