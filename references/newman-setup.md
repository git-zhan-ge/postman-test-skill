```markdown
# Newman 安装与环境检查

## 安装 Node.js
Newman 基于 Node.js，需先安装 Node.js (建议 v16+)。  
安装方式：
- Windows/Mac：下载安装包 [nodejs.org](https://nodejs.org/)
- Linux：使用 `nvm` 或包管理器

```

验证安装：
```bash
node -v
npm -v
```



## 安装 Newman

```
npm install -g newman
```

验证：

```
newman --version
```



## 可能遇到的问题

- **权限错误 (EACCES)**：Linux/Mac 下加 `sudo`，或配置 npm 全局路径。
- **网络问题**：设置国内镜像 `npm config set registry https://registry.npmmirror.com`