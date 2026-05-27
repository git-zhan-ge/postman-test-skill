# Postman Test Case Generator Skill

适用于 Claude Code 的 Postman 测试用例生成技能。从接口文档自动生成结构完整、可直接执行的 Postman 测试用例集合，达到企业级测试标准。

## 功能特性

### 核心能力
- 解析多种格式接口文档（OpenAPI/Swagger/Markdown/Word）
- 自动划分接口分支树：内部接口 vs 外部接口
- 提取请求四要素（方法、路径、请求头、请求体）和响应四要素（状态码、消息、响应头、响应体）
- 设计正例（验证正确响应）和反例（鉴权异常、参数异常、业务场景异常）
- 识别并实现特殊处理：数据加密、动态传参、链式调用、复杂认证、验证码/2FA

### 企业级特性 (v2.0.0)
- **测试优先级分级**: P0(阻断)/P1(重要)/P2(完善) 三级，支持风险导向执行
- **测试标签分类**: smoke(部署后 <2min) / regression(每日 <15min) / e2e(发版前 <60min)
- **重试策略**: Collection 级失败重试 2 次，间隔 3s
- **环境晋升流程**: dev -> staging -> prod 逐级验证
- **测试数据生命周期管理**: Setup/Teardown 模式
- **JSON Schema 校验**: 仅对 P0 接口强制执行
- **性能阈值断言**: P95/P99 分级，警告/阻断双阈值
- **测试覆盖率矩阵**: 正例 100% + 反例 >=80% 量化标准
- **多 CI 平台模板**: Jenkins / GitHub Actions / GitLab CI
- **边界值分析 (BVA)**: min/max/boundary 完整覆盖

### 断言生成规范 (10 条规则)
1. 响应类型分类（JSON API / HTML页面 / 重定向）
2. 防御性 JSON 解析（try-catch 模式）
3. 弹性状态码断言（oneOf 替代精确值）
4. 链式依赖变量的 Pre-request 校验
5. 错误消息断言规则
6. 异步/动态变量的取值时机
7. 断言自信心分级（High/Medium/Low）
8. JSON Schema 校验
9. 性能阈值断言
10. 边界值分析指导

## 产出文件结构

```
test-case/
├── README.md
├── api-branch-tree.md
├── coverage-matrix.md
├── environment.postman_environment.json
├── collection.postman_collection.json
├── cases/
│   ├── 01-auth/          # [smoke] (P0)
│   ├── 02-goods/         # [regression] (P1)
│   ├── 03-cart/          # (P0-P1)
│   ├── 04-order/         # (P0-P1)
│   ├── 05-personal/      # (P1)
│   ├── 06-backend-auth/  # (P0)
│   ├── 07-backend-mgmt/  # (P1)
│   └── 08-security/      # (P2)
├── newman-commands.sh
├── ci-templates/
├── test-data/
├── schemas/
└── mock-config/
```

## 安装

```bash
git clone https://github.com/git-zhan-ge/postman-test-skill.git ~/.claude/skills/postman-test/
```

## 依赖

| 工具 | 最低版本 | 推荐版本 |
|------|----------|----------|
| Postman App | v9.0 | v11+ |
| Newman | v5.0 | v6+ |
| Node.js | v16 | v20 LTS |

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|----------|
| v2.0.0 | 2026-05-28 | 企业级增强：优先级分级、标签体系、重试策略、环境晋升、数据生命周期、JSON Schema、性能断言、BVA、多CI模板、覆盖率矩阵、故障排查 |
| v1.0.0 | 2026-05-27 | 初始版本：分支树、正反例设计、cURL+Collection输出、断言生成规范 |

## License

MIT
