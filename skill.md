---
name: postman-test-case-generator
description: >
  当用户提供接口文档并要求生成 Postman 测试用例时，使用此技能。
  支持 OpenAPI/Swagger、Markdown、Word 等格式的文档解析。
  自动构建接口分支树（内部/外部接口），提取请求与响应四要素，
  设计正例与反例（鉴权/参数/业务），处理加密、动态传参、链式调用等特殊场景，
  生成可按单条导入的 cURL 文件、完整 Postman Collection JSON、环境配置文件、
  分支树 Mermaid 图、README，并可选择输出 Newman 命令、Jenkinsfile/GitHub Actions/GitLab CI 和 Mock 服务配置。
  企业级特性：测试优先级分级(P0/P1/P2)、冒烟/回归/全量标签、重试策略、
  环境晋升流程、测试数据生命周期管理、JSON Schema 校验、覆盖率矩阵、
  多CI平台模板、故障排查指南。
  适用于测试人员快速生成可直接执行和集成 CI 的 Postman 测试资产。
license: MIT
compatibility: requires postman-collection, newman (optional), htmlextra reporter (optional)
metadata:
  author: user-defined
  version: "2.0.0"
  version_history:
    - version: "2.0.0"
      date: "2026-05-28"
      changes:
        - "新增测试优先级分级 P0/P1/P2，支持风险导向测试执行"
        - "新增冒烟/回归/全量测试标签体系"
        - "新增重试策略与 flaky test 处理机制"
        - "新增环境晋升流程 dev→staging→prod"
        - "新增测试数据生命周期管理（setup/teardown）"
        - "新增 JSON Schema 校验断言模板"
        - "新增性能阈值断言模板（P95/P99）"
        - "新增测试覆盖率矩阵生成"
        - "新增多CI平台模板：Jenkins、GitHub Actions、GitLab CI"
        - "新增故障排查附录"
        - "新增边界值分析指导"
        - "新增 Collection Runner 配置推荐"
    - version: "1.0.0"
      date: "2026-05-27"
      changes:
        - "初始版本：接口分支树、正反例设计、cURL+Collection 输出"
        - "断言生成规范（防御性JSON解析、弹性状态码、链式校验）"
        - "环境/集合/用户变量三级分类"
  triggers:
    - "postman"
    - "使用postman"
    - "生成postman测试用例"
    - "postman测试"
    - "接口测试用例"
---

# Postman 测试用例生成器

## 概述
此技能用于从接口文档自动生成结构完整、可直接执行的 Postman 测试用例集合。
生成的产物包含：接口分支树图（Mermaid）、每条测试用例的独立 cURL 文件、
一个合并所有用例的 Postman Collection JSON 文件、环境配置文件、README，
并可选择生成 Newman 运行命令、Jenkinsfile 和 Mock 服务配置。

**适用角色**：测试人员  
**核心能力**：
- 解析多种格式接口文档（OpenAPI/Swagger/Markdown/Word）
- 自动划分接口分支树：`内部接口`（各功能模块间，需详细测试） vs `外部接口`（被测系统与外部系统，测功能）
- 提取请求四要素（方法、路径、请求头、请求体）和响应四要素（状态码、消息、响应头、响应体）
- 设计正例（验证正确响应）和反例（鉴权异常、参数异常、业务场景异常等）
- 识别并实现特殊处理：数据加密、动态传参、链式调用、复杂认证
- 抽离环境变量、集合变量、用户变量，支持数据驱动（CSV/JSON）
- 使用 Postman 内置 Chai 断言库，并根据文档预期结果自动生成断言脚本
- 输出单条 cURL 文件 + 整体 Collection JSON，方便按需修改和一次性导入
- 询问用户是否需要 Newman/Jenkinsfile/Mock 服务

## 触发条件
当用户消息中包含以下任一关键词或场景时，应激活此技能：
- "postman"
- "使用postman"
- "生成postman测试用例"
- "postman测试"
- "接口测试用例"
- 用户上传或粘贴接口文档，并说明需要 Postman 相关资产

## 工作流程

### 阶段一：解析文档并生成接口分支树
1. **识别文档格式**  
   支持的格式：OpenAPI/Swagger (JSON/YAML)、Markdown、Word (.docx)。  
   - 若为 OpenAPI/Swagger，直接解析 `paths`、`components` 等节点。  
   - 若为 Markdown/Word，以自然语言理解方式提取接口信息，遇到模糊不清的字段主动提问。
2. **构建接口分支树**  
   - 将所有接口划分为 `内部接口` 和 `外部接口` 两个主分支。  
   - `内部接口`：系统内各模块之间调用的接口，测试重点为详细逻辑、边界值、错误处理。  
   - `外部接口`：被测系统与外部第三方系统之间的接口，测试重点为功能连通性、协议合规。  
   - 按照功能模块或业务流进一步组织子分支。  
   - 生成 **Mermaid 格式的树形图**，展示所有接口及其层级关系。
3. **首次交互确认**  
   将生成的 Mermaid 分支树展示给用户，并提示：  
   > "已生成接口分支树，请检查是否准确完整。确认无误后我将继续提取接口要素，如有遗漏或分类错误请告知。"  
   等待用户确认后进入下一阶段。不得在未确认前继续。

### 阶段二：提取接口要素并设计测试用例
4. **提取四要素**  
   对每个接口精确提取：
   - 请求四要素：请求方式 (GET/POST/PUT/DELETE等)、请求路径、请求头（含 Content-Type、鉴权字段等）、请求数据（Query、Body 结构、必填/选填字段及其类型和约束）
   - 响应四要素：响应状态码、响应消息、响应头、响应数据（JSON Schema 或示例，需标注预期结构）
5. **设计正例**  
   - 使用合法有效的请求参数，预期返回定义的响应码（通常 2xx）和正确数据结构。  
   - **必须遵循断言生成原则**（详见下方"断言生成规范"章节），核心要点：
     - **响应类型分类**：先判断接口返回的是 JSON、HTML 页面、还是重定向，三类响应的断言策略完全不同。
     - **防御性 JSON 解析**：所有 `pm.response.json()` 必须包裹在 try-catch 中，因为鉴权失败的接口可能返回 HTML 登录页而非 JSON。
     - **弹性状态码断言**：对文档中未明确验证过的状态码，使用 `to.be.oneOf([200, 302, ...])` 弹性断言，而非 `to.have.status(精确值)`。
     - **页面型接口只断言状态码**：对返回 HTML 的页面型接口，只检查 `status(200)` 和 `response.text()` 非空，不检查特定关键词（除非用户亲口确认页面上有该关键词）。
   - 根据响应预期编写 Chai 断言，至少包含：状态码断言、响应体结构断言、关键字段值/类型断言，若文档有要求则增加响应时间断言（如 `pm.expect(pm.response.responseTime).to.be.below(200)`）。
6. **设计反例**  
   反例需覆盖以下类别，并根据文档具体约束推断：
   - **鉴权反例**：鉴权码为空、错误、过期（若文档定义了认证方式）。**注意**：未登录时框架可能返回 302 重定向、或 200 HTML 登录页面、或 401/403 JSON 错误。应使用弹性断言 `to.be.oneOf([200, 302, 401, 403])`，不要预设具体状态码。
   - **参数反例**：必填参数缺失、参数类型错误（如数字传字符串）、参数长度超限或格式错误、枚举值非法等。
   - **业务场景反例**：黑名单用户、接口调用次数超限、分页参数越界、余额不足等（需从文档业务描述中推断；若文档信息不足，标记为"需用户补充"）。
   - **错误消息断言规则**：仅当文档明确给出了错误响应样例（如 `{"resultCode": 500, "message": "验证码错误"}`）时，才在断言中检查该消息。**禁止从源码中提取内部常量名（如 `NULL_ADDRESS_ERROR`、`SHOPPING_ITEM_ERROR`）作为断言依据**，因为用户界面可能不暴露这些常量。
7. **测试优先级分级（P0/P1/P2）**  
   为每条测试用例标注优先级，支持风险导向的测试执行策略：
   
   | 优先级 | 定义 | 典型场景 | 执行时机 |
   |--------|------|----------|----------|
   | **P0** | 核心功能阻断级 | 登录正例、下单正例、支付回调 | 每次提交触发 |
   | **P1** | 重要功能异常级 | 参数校验反例、鉴权反例、状态转换 | 每日构建触发 |
   | **P2** | 边界场景完善级 | 分页越界、特殊字符、并发冲突 | 每周/发版前触发 |
   
   优先级标注在 Collection 中对应文件夹/请求的 `description` 字段，格式：`[P0]`、`[P1]`、`[P2]`。
   在 Newman 运行脚本中按优先级生成独立的执行命令。

8. **测试标签分类（冒烟/回归/全量）**  
   为每个 Collection 文件夹打上标签，支持选择性执行：
   
   | 标签 | 包含优先级 | 用例数量预期 | 执行耗时预期 | 触发场景 |
   |------|-----------|-------------|-------------|----------|
   | **smoke** | 仅 P0 | 5-15 条 | < 2 分钟 | 部署后快速验证 |
   | **regression** | P0 + P1 | 30-80 条 | < 15 分钟 | 每日构建 |
   | **e2e** | P0 + P1 + P2 | 全部 | < 60 分钟 | 发版前/每周 |
   
   标签通过 Postman Collection 的文件夹命名体现（如 `[smoke] 前台认证`），并在 Newman 脚本中使用 `--folder` 按标签筛选执行。

9. **高风险反例确认**  
   将推导出的所有反例（尤其业务场景反例）罗列给用户，并说明依据。  
   > "以下为识别到的高风险反例场景，请确认是否需要全部生成，或补充/修改：..."  
   等待用户反馈。
10. **特殊处理识别与实现**  
   检查接口是否存在以下情况：
   - **加密**：如请求体或响应体需要 MD5/SHA/AES 加密。默认在 Pre-request Script 或 Tests 中使用 CryptoJS 等通用库实现，若算法特殊则提问。
   - **动态传参**：如 Token 从登录接口获取并传递给后续接口。使用 `pm.environment.set("token", ...)` 在登录请求的 Tests 中设置，后续请求使用 `{{token}}` 引用。
   - **链式调用**：如创建订单后立即查询订单详情。通过 `postman.setNextRequest()` 或直接用环境变量传递 ID。**关键**：所有依赖链式变量的请求，必须在其 Pre-request Script 中添加变量存在性检查：
     ```javascript
     // Pre-request Script: 检查链式依赖变量是否已设置
     const orderNo = pm.collectionVariables.get('order_no');
     if (!orderNo) {
         console.warn('[跳过] order_no 未设置，请先执行创建订单接口');
         // 不抛异常，后续 Tests 中的弹性断言会优雅处理
     }
     ```
   - **复杂认证**：如 OAuth2.0、签名认证。优先用 Postman 内置 Auth 辅助，若无法内置则生成预请求脚本实现。
   - **验证码/2FA 依赖**：若接口依赖验证码（如登录、注册），**不可使用硬编码默认值**（如 `0000`）。必须：① 在环境变量中使用 `your_verify_code_here` 占位符；② 在 README 中显式警告用户运行前必须填写验证码；③ 登录/注册正例的断言接受 `resultCode` 为 200 或 500（验证码可能无效），避免因验证码错误导致整个测试集合误报失败。
   - **响应类型分类**：对每个接口标注响应类型——`JSON API`、`HTML 页面`、`重定向`。不同类型的断言策略完全不同（详见"断言生成规范"）。
   识别后，向用户说明拟采用的实现方案，确认后执行。

### 阶段三：变量与数据驱动设计
11. **变量分类**  
   - **环境变量**：随部署环境变化的值（如 `base_url`、`api_key`）。提取并生成 Postman 环境文件，**所有敏感/运行时变量必须使用占位符**（如 `your_api_key_here`、`your_verify_code_here`），严禁使用假值（如 `0000`、`fake_token`），避免用户遗漏修改导致测试误报。  
   - **集合变量**：项目级常量（如 `api_version`）。生成在 Collection 的变量定义中。  
   - **用户变量**：用于数据驱动的动态测试数据（如用户名、密码）。在反例参数化时使用 `{{username}}` 等占位符，并在 README 中说明需用户自行准备 CSV 或 JSON 数据文件导入。
   - **验证码/Token 类变量**：初始值必须为空字符串 `""` 或 `your_xxx_here`，并在 README 中以醒目方式警告用户运行前填写。登录正例的断言应同时接受成功和验证码错误两种结果。
12. **变量确认**  
    向用户展示变量分类清单，请其确认或调整。  
    > "以下变量将被设置为环境变量/集合变量/用户变量，请确认：... 如需修改请告知。"

### 测试数据生命周期管理

测试数据必须在测试执行前后进行妥善管理，避免数据污染和测试间相互干扰。

**原则**：
- 每个测试用例必须是**独立可重复**的——不依赖前序测试残留的数据
- 测试产生的数据应在 teardown 中清理（若接口支持删除）
- 若接口不支持删除，在 README 中标注需手动清理的数据类型

**Setup 模式**（Pre-request Script）：
```javascript
// 例：订单测试前准备购物车数据
// Pre-request: 确保购物车中有商品
const cartReady = pm.collectionVariables.get('cart_ready');
if (!cartReady) {
    console.warn('[Setup] 购物车未准备，请先执行添加购物车接口');
}
```

**Teardown 模式**（Tests 中清理）：
```javascript
// 例：创建测试数据后标记清理
const createdId = pm.collectionVariables.get('created_order_id');
if (createdId && pm.response.code === 200) {
    console.log(`[Teardown] 已创建订单 ${createdId}，需在 teardown 文件夹中清理`);
}
```

**Teardown 文件夹**：在 Collection 末尾创建 `[teardown] 数据清理` 文件夹，包含：
- 删除测试订单的请求（参数化从变量读取 ID）
- 清空测试购物车的请求
- 每个清理请求的 Tests 中输出清理结果日志

**数据隔离策略**：
| 策略 | 适用场景 | 实现方式 |
|------|----------|----------|
| 逻辑删除 | 接口支持删除/取消 | Teardown 文件夹中调用删除接口 |
| 时间窗口 | 接口不支持删除但有时间戳字段 | README 中注明需定期按时间范围清理 |
| 独立账号 | 敏感/不可逆操作 | 环境变量中使用专用测试账号 |

### 阶段四：输出文件生成
13. **格式选择确认**  
    询问用户首选测试用例文件格式：  
    > "默认生成 cURL 格式的独立用例文件，是否也需要生成其他格式（如 Swagger/OpenAPI/HAR）？如需请指定。"  
    默认生成 cURL。若用户需要其他格式，调用相应转换逻辑（如 OpenAPI 生成 Collection 后转换）并生成对应文件。
14. **CI 集成与 Mock 服务询问**  
    - 询问："是否需要生成 CI/CD 集成脚本？支持 Jenkins、GitHub Actions、GitLab CI。" 若需要，输出对应平台模板：  
      - **Jenkins**：生成 `Jenkinsfile`，包含参数化构建（选择 smoke/regression/e2e 标签）、HTML 报告归档、失败阈值设定  
      - **GitHub Actions**：生成 `.github/workflows/postman-tests.yml`，支持 push/PR 触发、矩阵策略按标签并行  
      - **GitLab CI**：生成 `.gitlab-ci.yml` 片段，支持 stage 划分、artifacts 收集  
    - **重试策略**（必须写入所有 CI 模板）：单个请求超时 10s，Collection 级别失败重试 2 次（仅 regression/e2e 标签，smoke 不重试），重试间隔 3s。Newman 命令使用 `--delay-request 500` 避免请求间互相影响。  
    - 询问："是否需要生成 Mock 服务配置？" 若需要，基于接口文档生成 Postman Mock Server 配置片段或指导。
15. **最终生成**  
    所有文件输出至 `test-case/` 文件夹，结构如下：
    test-case/
    ├── README.md # 使用说明（含故障排查链接）
    ├── api-branch-tree.md # Mermaid 分支树图，标注接口优先级
    ├── coverage-matrix.md # 测试覆盖率矩阵（接口↔用例映射）
    ├── environment.postman_environment.json # Postman 环境文件
    ├── collection.postman_collection.json # 合并所有用例的 Collection JSON
    ├── cases/ # 单条用例 cURL 文件
    │ ├── 01-auth/          # [smoke] 前台认证 (P0)
    │ ├── 02-goods/         # [regression] 商品浏览 (P1)
    │ ├── 03-cart/          # [regression] 购物车 (P0-P1)
    │ ├── 04-order/         # [regression] 订单 (P0-P1)
    │ ├── 05-personal/      # [regression] 个人中心 (P1)
    │ ├── 06-backend-auth/  # [smoke] 后台认证 (P0)
    │ ├── 07-backend-mgmt/  # [regression] 后台管理 (P1)
    │ └── 08-security/      # [e2e] 安全测试 (P2)
    ├── newman-commands.sh # Newman 运行脚本（按标签+优先级拆分）
    ├── ci-templates/ # CI 平台模板
    │ ├── Jenkinsfile
    │ ├── github-actions.yml
    │ └── gitlab-ci.yml
    ├── test-data/ # 数据驱动测试文件模板
    │ ├── login-test-data.csv
    │ └── user-variables.json
    ├── schemas/ # JSON Schema 校验文件（可选）
    │ └── *.schema.json
    └── mock-config/ # Mock 配置（可选）

16. **README 必须包含内容**  
- 项目名称、生成时间  
- 接口分支树说明  
- 测试优先级分布（P0/P1/P2 数量和占比）  
- 冒烟/回归/全量标签的用例数量及估计执行时间  
- 如何使用各文件：导入环境、导入 Collection、导入单个 cURL  
- 如何准备用户变量数据文件（CSV/JSON 示例）  
- 如何按标签运行测试（smoke/regression/e2e 的 Newman 命令）  
- 如何运行 Newman（每个 CI 平台的快速入门）  
- 常见问题排查（Session 失效、验证码错误、JSON 解析失败等 Top 5 问题及解决方案）  
- 提醒："导入后请务必检查环境变量和用户变量文件路径，并确认断言是否符合预期。"

17. **最终提醒**  
生成完成后，显式提醒用户：  
> "所有文件已生成至 `test-case` 文件夹。请按以下步骤操作：  
> 1. 导入 `environment.postman_environment.json` 并填写缺失的环境值。  
> 2. 导入 `collection.postman_collection.json` 或单独拖入 `cases/` 下的 cURL 文件。  
> 3. 若使用了用户变量，请准备 CSV/JSON 文件并在 Runner 中导入。  
> 4. 执行 Collection 前，请根据实际环境调整认证设置。"

## 决策树（企业级完整流程）

```
用户给出文档 → [解析文档]
↓
生成分支树 + 标注接口优先级(P0/P1/P2) → 展示给用户 → 用户确认？
↓ 是                                              ↓ 否
提取要素、设计正反例 → 标注测试标签(smoke/regression/e2e)
↓
展示高风险反例 → 用户确认？
↓ 是                          ↓ 否
识别特殊处理(加密/链式/验证码) → 提出方案 → 用户确认？
↓ 是
变量分类(环境/集合/用户) → 展示清单 → 用户确认？
↓ 是
测试数据生命周期设计(Setup/Teardown) → 展示 → 用户确认？
↓ 是
询问格式(默认cURL) → 询问CI平台(多选) → 询问Mock服务
↓
生成所有文件(含覆盖率矩阵、CI模板、JSON Schema)
↓
输出到 test-case/ 并给出操作提醒 + 故障排查链接
```

### 各阶段产出检查表

| 阶段 | 产出物 | 验收标准 |
|------|--------|----------|
| 一：分支树 | Mermaid 树形图 + 优先级标注 | 所有接口被分类，P0/P1/P2 标注完整 |
| 二：用例设计 | 正例+反例列表 + 标签 | 正例覆盖率 100%，反例覆盖率 ≥ 80% |
| 三：变量与数据 | 变量清单 + 数据生命周期方案 | 无硬编码默认值，Teardown 策略明确 |
| 四：文件生成 | 完整 test-case/ 目录 | Collection 可导入，cURL 可执行，CI 模板可运行 |

## 断言生成规范（必读）

如果生成的断言不符合此规范，用户运行测试时会遇到大量误报失败。

### 1. 响应类型分类（决定断言策略）

每个接口必须先分类，不同类型使用完全不同断言模板：

| 响应类型 | 判断依据 | 断言策略 |
|----------|----------|----------|
| **JSON API** | 文档标注 `@ResponseBody` 或返回 `{"resultCode": ...}` | 状态码 + JSON 结构 + resultCode/message + 业务字段 |
| **HTML 页面** | 文档标注"返回页面"、"无 `@ResponseBody`" | **仅**状态码 200 + 响应非空。**禁止**用 `to.include('某关键词')` 检查页面内容（除非用户亲口确认该关键词存在于页面中） |
| **重定向** | 文档标注 "302" 或成功后跳转 | 使用弹性断言 `to.be.oneOf([200, 302])`，不锁定具体状态码 |

### 2. 防御性 JSON 解析（所有 JSON API 强制执行）

任何调用 `pm.response.json()` 的地方必须包裹 try-catch，因为鉴权失败时 JSON API 可能返回 HTML 登录页面：

```javascript
// 正确写法
let json;
try { json = pm.response.json(); } catch(e) { json = null; }

if (json) {
    pm.test("resultCode=200", () => { pm.expect(json.resultCode).to.eql(200); });
} else {
    pm.test("响应非JSON（可能未登录被重定向）", () => {
        pm.expect(pm.response.code).to.be.oneOf([200, 302]);
    });
}
```

### 3. 弹性状态码断言

| 场景 | 错误写法 | 正确写法 |
|------|----------|----------|
| 鉴权失败 | `to.have.status(403)` | `to.be.oneOf([200, 302, 401, 403])` |
| 参数类型错误 | `to.have.status(400)` | `to.be.oneOf([200, 400])` |
| 登录成功 | `to.have.status(302)` | `to.be.oneOf([200, 302])` |
| 未登录访问 | `to.have.status(302)` | `to.be.oneOf([200, 302])` |

**原则**：文档中描述的行为（如"跳转登录页"）可能与框架实际表现（返回 200 HTML 登录页）不同。永远用 `oneOf` 而非 `have.status(精确值)`。

### 4. 链式依赖变量的 Pre-request 校验

所有依赖链式变量（如 `order_no`、`cart_item_id`、`token`、`jsessionid`）的请求，必须添加 Pre-request Script：

```javascript
// Pre-request: 验证链式依赖
const deps = [
    { name: 'order_no', label: '订单号' },
    { name: 'mall_jsessionid', label: '前台Session' }
];
for (const dep of deps) {
    const val = pm.collectionVariables.get(dep.name);
    if (!val || val === '') {
        console.warn(`⚠ 前置依赖 ${dep.label}(${dep.name}) 未设置，接口可能返回错误`);
    }
}
```

注意：Pre-request 只输出警告，不阻止请求执行。弹性断言会在 Tests 中优雅处理缺失情况。

### 5. 错误消息断言规则

- **可以断言**：文档明确给出的错误响应样例消息（如 `"message": "验证码错误"`）
- **禁止断言**：从源码 Controller 中提取的内部常量名（如 `NULL_ADDRESS_ERROR`、`SHOPPING_ITEM_ERROR`），因为这些常量可能不被暴露给用户
- 当文档只说"返回错误提示"但无具体文本时，只断言 `resultCode === 500` 或 `message` 非空，不检查具体文字

### 6. 异步/动态变量的取值时机

`pm.collectionVariables.get()` 在同一个 Runner 迭代中**实时读取**最新值，但需注意：
- 如果前一个请求的 Tests 中 `set` 了变量，当前请求的 Pre-request 或 Body 中 `{{var}}` 会自动展开为新值
- 但如果在 Pre-request 中用 `pm.collectionVariables.get()` 读取，读到的就是前序请求设置的值
- 对于首轮执行的链式依赖（如 ORDER-006 依赖 ORDER-005 设置的 `order_no`），应确保请求按文件夹顺序执行

### 7. 断言自信心分级

每条断言应隐含一个"自信心等级"，影响断言严格程度：

| 等级 | 依据来源 | 断言写法 | 示例 |
|------|----------|----------|------|
| **高** | 文档中明确给出的响应样例 | 精确断言 | `pm.expect(json.message).to.eql('success')` |
| **中** | 从文档描述推断 | 弹性断言 | `pm.expect(json.resultCode).to.be.oneOf([200, 500])` |
| **低** | 从源码分析猜测 | 最低限度断言 | `pm.expect(pm.response.code).to.be.oneOf([200, 302])` |

当文档信息不足以做出高等级断言时，**主动降级**，不要猜测填充。

### 8. JSON Schema 校验（推荐用于 P0 接口）

对响应结构稳定且文档明确给出字段定义的接口，应生成 JSON Schema 校验断言：

```javascript
// 例：登录成功响应 Schema
const loginSuccessSchema = {
    type: 'object',
    required: ['resultCode', 'message', 'data'],
    properties: {
        resultCode: { type: 'number' },
        message: { type: 'string' }
    }
};

let json; try { json = pm.response.json(); } catch(e) { json = null; }
if (json) {
    pm.test('响应结构符合Schema', () => {
        pm.expect(tv4.validate(json, loginSuccessSchema)).to.be.true;
    });
}
```

**注意**：Postman 不内置 tv4/ajv。需要在 Collection 的 Pre-request 中通过 CDN 加载，或在 README 中说明安装方式。JSON Schema 仅对 P0 核心接口强制执行，避免过度约束 API 演进。

### 9. 性能阈值断言

对文档中标注了性能要求的接口（或用户明确要求的接口），添加响应时间断言：

```javascript
// P95 性能断言（宽松，仅告警不阻断）
pm.test('响应时间 < 2000ms (P95)', () => {
    pm.expect(pm.response.responseTime).to.be.below(2000);
});

// P0 核心接口性能断言（严格，阻断）
pm.test('响应时间 < 500ms (核心接口)', () => {
    pm.expect(pm.response.responseTime).to.be.below(500);
});
```

**阈值推荐**：
| 场景 | 警告阈值 | 阻断阈值 |
|------|----------|----------|
| 页面加载 | 3000ms | — |
| JSON API (一般) | 2000ms | 5000ms |
| JSON API (核心/登录) | 500ms | 2000ms |
| 文件上传 | 10000ms | 30000ms |

### 10. 边界值分析（BVA）指导

参数反例设计必须包含边界值分析：

| 边界类型 | 正例 | 反例 |
|----------|------|------|
| 最小值 | `min` | `min - 1` |
| 最大值 | `max` | `max + 1` |
| 刚好等于 | `exact` | — |
| 空字符串 | — | `""` |
| null | — | `null` |
| 超长字符串 | — | 10001 字符（若定义 max=10000） |

对于分页接口，额外添加：`page=0`（零下标）、`page=-1`（负数）、`page=999999`（超大页码）、`limit=0`、`limit=2147483647`（int32 上限）

## 测试覆盖率矩阵

生成完成后必须产出覆盖率矩阵 `coverage-matrix.md`，格式如下：

```markdown
| 接口 | 模块 | 优先级 | 正例 | 鉴权反例 | 参数反例 | 业务反例 | 覆盖率 |
|------|------|--------|------|----------|----------|----------|--------|
| /api/user/login | 前台认证 | P0 | 1 | 3 | 4 | 2 | 10/10 |
| /api/user/register | 前台认证 | P0 | 1 | 0 | 5 | 1 | 7/7 |
| /shop-cart | 购物车 | P0 | 1 | 2 | 3 | 1 | 7/7 |
| ... | ... | ... | ... | ... | ... | ... | ... |
| **合计** | | | **N** | **N** | **N** | **N** | **X/Y** |
```

覆盖率矩阵使测试资产可度量、可审计：
- 一眼可见哪些接口缺少反例覆盖
- 正例覆盖应达到 100%（每个接口至少 1 条正例）
- 反例覆盖应达到 ≥ 80%（允许少部分业务反例因文档信息不足标记为"需用户补充"）

## 环境晋升策略

测试用例应在不同环境间逐级验证，避免未经验证的用例直接进入生产环境。

| 环境 | 执行标签 | 目的 | 变量差异 |
|------|----------|------|----------|
| **dev** | smoke | 部署后快速验证 | `base_url` 指向开发环境，`verify_code` 可设后门值 |
| **staging** | smoke + regression | 每日构建验证 | `base_url` 指向预发布环境，`verify_code` 需真实获取 |
| **prod** | smoke（只读接口） | 生产探活 | `base_url` 指向生产环境，**禁止**执行写操作和数据修改接口 |

**生产环境安全规则**：
- 生产环境仅允许执行 smoke 标签，且仅限 GET/只读接口
- 生产 Collection 必须移除所有写操作请求（POST/PUT/DELETE 创建/修改类）
- 生产环境变量 `base_url` 必须独立配置，不得与 staging 共用
- 所有环境变量文件必须 `.gitignore` 排除（除 template 版本外）

环境配置文件命名规范：`environment.{env}.postman_environment.json`（如 `environment.dev.postman_environment.json`、`environment.staging.postman_environment.json`）

## CI 平台模板参考

### Newman 多标签脚本结构

`newman-commands.sh` 必须包含以下独立命令：

```bash
# Smoke：部署后快速验证（仅 P0，< 2分钟）
newman run collection.json -e environment.json \
  --folder "[smoke]" --timeout-request 10000 \
  --reporters cli,htmlextra --reporter-htmlextra-export reports/smoke-report.html

# Regression：每日构建（P0+P1，< 15分钟），含重试
newman run collection.json -e environment.json \
  --folder "[smoke]" --folder "[regression]" \
  --timeout-request 10000 --delay-request 300 \
  --reporters cli,htmlextra --reporter-htmlextra-export reports/regression-report.html
# 若失败则重试最多2次，间隔3s
for i in 1 2; do
  newman run ... && break || sleep 3
done

# E2E：发版前全量（P0+P1+P2，< 60分钟），含重试
newman run collection.json -e environment.json \
  --timeout-request 10000 --delay-request 500 \
  --reporters cli,htmlextra --reporter-htmlextra-export reports/e2e-report.html
```

### Jenkinsfile 参数化构建

```groovy
pipeline {
    parameters {
        choice(name: 'TEST_TAG', choices: ['smoke', 'regression', 'e2e'])
        string(name: 'BASE_URL', default: 'http://localhost:28089')
    }
    stages {
        stage('Postman Tests') {
            steps {
                sh "newman run collection.json -e environment.json --folder [${params.TEST_TAG}] --reporters cli,htmlextra"
            }
        }
        stage('Archive Reports') {
            steps { archiveArtifacts 'reports/*.html' }
        }
    }
}
```

### GitHub Actions 矩阵策略

```yaml
jobs:
  postman:
    strategy:
      matrix:
        tag: [smoke, regression]
        node: [1, 2]  # 并行实例
    steps:
      - run: |
          newman run collection.json --folder "[${{ matrix.tag }}]" \
            --reporters cli,htmlextra \
            --reporter-htmlextra-export reports/${{ matrix.tag }}-${{ matrix.node }}.html
      - uses: actions/upload-artifact@v4
        with: { name: postman-reports, path: reports/ }
```

## 注意事项（续）
- 任何文档模糊、缺失必填信息或无法推断完整用例时，**必须主动向用户提问**，禁止猜测后直接输出。
- 所有交互确认点都必须暂停等待用户回复，严禁跳过。
- 特殊处理（如加密）若需引入外部库，需在脚本注释中说明依赖和在 Postman 中的加载方式。
- 生成的 Collection JSON 必须符合 Postman Collection v2.1 规范，确保可导入。
- **页面型接口（HTML）禁止生成内容关键词断言**。只检查状态码和响应非空。  
- **所有 `pm.response.json()` 必须包裹 try-catch**。鉴权失败时 JSON API 返回 HTML 是常见情况。  
- **状态码断言必须使用弹性写法** `to.be.oneOf([...])`，除非文档 Response 示例中明确写死了具体状态码。  
- **链式变量（order_no, cart_item_id, token 等）的消费方请求必须加 Pre-request 校验**。  
- **禁止硬编码默认值**：验证码、Token、密码等敏感变量统一用 `your_xxx_here` 占位符或空字符串，严禁用假值 `0000`。  
- **错误消息断言仅限文档明确给出的文本**，不得从源码中提取内部常量作为断言。  
- 所有断言使用 Postman 内置 Chai 断言库，语法示例：
  ```javascript
  pm.test("Status code is 200", function () {
      pm.response.to.have.status(200);
  });
  pm.test("Response time is less than 200ms", function () {
      pm.expect(pm.response.responseTime).to.be.below(200);
  });
```

## 故障排查附录

### Top 5 常见问题及解决方案

| # | 问题现象 | 根因 | 解决方案 |
|---|----------|------|----------|
| 1 | `JSONError: Unexpected token '<'` | Session 失效，服务器返回 HTML 登录页 | ① 重新执行登录接口获取新 Session；② 检查断言是否使用 try-catch 防御模式 |
| 2 | 验证码接口全部返回 `resultCode: 500` | 验证码值错误或服务端未启用验证码 | ① 填写正确的 `verify_code`；② 若测试环境未启用验证码，联系开发确认 |
| 3 | 链式调用请求跳过/失败 | 前置依赖变量未设置 | ① 按文件夹顺序执行；② 检查 Pre-request Script 的依赖校验日志 |
| 4 | Newman 运行超时 | 服务响应慢或请求间无延迟 | ① 增加 `--timeout-request 30000`；② 添加 `--delay-request 500` |
| 5 | Collection 导入后认证失败 | 环境变量未填写或 Cookie 已过期 | ① 检查环境变量 `your_xxx_here` 占位符是否已替换；② 重新执行登录获取 Session |

### Postman 配置检查清单

在运行 Collection 前确认以下项：
- [ ] 环境文件中所有 `your_xxx_here` 占位符已替换为真实值
- [ ] `base_url` 指向正确的测试环境
- [ ] 登录接口用例已成功执行并提取了 Session/Token
- [ ] 若接口使用验证码，`verify_code` 已填写或联系开发获取
- [ ] 数据驱动文件（CSV/JSON）路径在 Runner 中配置正确
- [ ] Collection Runner 设置：`Keep variable values` = ON，`Save responses` = ON
- [ ] 关闭不必要的重定向跟随（Postman 默认跟随重定向，可能导致 Session 丢失）

### 断言调试技巧

1. **先看 Raw Body**：在 Postman Tests 中临时添加 `console.log(pm.response.text().substring(0, 500))` 查看实际返回内容
2. **关闭 JSON 解析**：若怀疑返回非 JSON，临时注释 `pm.response.json()` 并用 `pm.response.text()` 排查
3. **逐接口调试**：不要一次运行整个 Collection——按文件夹逐个执行，定位问题接口
4. **使用 Postman Console**：`View → Show Postman Console`，查看 Tests 的 console.log 输出和错误堆栈
5. **弹性断言降级**：若某个状态码断言持续失败，临时改为 `to.be.oneOf([...])` 并收集实际返回状态码

### 版本兼容性

| 工具 | 最低版本 | 推荐版本 | 说明 |
|------|----------|----------|------|
| Postman App | v9.0 | v11+ | Collection v2.1 格式兼容所有 v9+ 版本 |
| Newman | v5.0 | v6+ | `--reporters htmlextra` 需要 `newman-reporter-htmlextra` |
| Node.js | v16 | v20 LTS | Newman 运行环境 |