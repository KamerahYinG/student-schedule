# AGENTS.md

## 1. Language

- 对用户的进度汇报、解释、总结、验收结果，默认使用**简体中文**。
- 代码标识符、文件名、类名、API 名称、命令行命令保持英文，不为了中文化而改名。
- 编译器、测试框架、Flutter/Dart 原始报错可以保留英文；随后用中文概括问题。
- 除非用户明确要求英文，否则不要用英文写最终工作总结。

## 2. Sources of truth

开始任何实现任务前，先阅读：

1. `AGENTS.md`
2. `PRODUCT_SPEC.md`
3. `ARCHITECTURE.md`

其中：

- `PRODUCT_SPEC.md` 是产品行为和领域语义的事实来源。
- `ARCHITECTURE.md` 是代码结构、依赖方向、存储和工程约束的事实来源。
- 用户当前明确给出的指令优先级最高。

如果实现方式与这些文档冲突，不要擅自扩大范围；优先采用满足当前任务且改动最小的方案。

## 3. Scope discipline

- 一次只实现用户当前要求的 milestone。
- 不主动增加未要求的功能。
- 不为了“以后可能会用”提前加入抽象、依赖、服务或页面。
- 不实现 `PRODUCT_SPEC.md` 中明确列为后续版本的功能。
- 优先小 diff、可验证 diff。
- 不进行与当前任务无关的大规模重构。
- 发现旧代码可以更漂亮，但不影响当前任务时，记录在总结中，不顺手重写。

## 4. Architecture discipline

必须遵守 `ARCHITECTURE.md` 中定义的依赖方向。

特别是：

- UI 不直接访问数据库。
- Feature UI 通过 controller/provider 调用 repository。
- Domain 层不能依赖 Flutter Widget、数据库实现或云服务 SDK。
- Data 层实现 Domain 定义的 repository contract。
- Deadline 与 TimeBlock 语义必须分开。
- `Inbox`、`Overdue`、`Scheduled`、`Unscheduled` 不得错误实现成 Task status。
- date-only deadline 不得偷偷转换为 23:59。
- 不要自动把父 Task 的 deadline/category 写入子 Task；继承逻辑按产品文档动态计算。

## 5. Dependency policy

- 添加 production dependency 前，先确认当前任务确实需要。
- V0.1 不添加 Firebase、Supabase、AI SDK、复杂日历库或通知库。
- 不因为方便而引入大型框架。
- 不自行更换已确定的状态管理或本地存储方案。
- 不锁定未要求的 package version；遵循当前 Flutter/Dart SDK 可兼容的稳定版本。

## 6. Platform scaffolding

Android、iOS、macOS 平台目录必须由 Flutter CLI 正式生成。

- 不手工伪造 Flutter 平台工程。
- 如果当前环境没有 Flutter SDK，不要声称项目已经可以在对应平台构建。
- 可以保留现有占位文件，但必须明确它们不是正式 platform scaffold。
- 等 Flutter SDK 可用后，再使用 Flutter CLI 生成/修复平台目录。

## 7. Validation

每次修改后，尽可能执行与改动相关的验证。

正常情况下至少包括：

```bash
dart format .
flutter analyze
flutter test
```

但只有命令**实际成功执行**后，才能说对应验证通过。

如果因为 Flutter SDK、平台工具链或权限缺失而无法运行：

- 明确写“未运行”或“无法验证”。
- 给出阻塞原因。
- 不把“检查了文件结构”描述成“Flutter validation passed”。

不要为了让测试通过而删除、弱化或跳过有意义的测试。

## 8. Reporting

任务结束时，用简体中文简洁说明：

1. 做了什么。
2. 改了哪些关键文件。
3. 实际运行了哪些验证以及结果。
4. 哪些验证没有运行，以及为什么。
5. 是否存在下一步必须先解决的 blocker。

不要重复整份产品需求。
不要输出与本次修改无关的长篇建议。
