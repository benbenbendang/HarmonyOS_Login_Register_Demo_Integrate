1. 项目概述

主题：HarmonyOS 前端 + Spring Boot 后端 的“登录 / 注册 / 忘记密码 / 退出登录”小系统。

核心功能：

注册账号（用户名唯一、可选邮箱）

登录获取 不透明 Token(UUID)

忘记密码（重置为新密码）

退出登录（服务端令牌失效）

登录后首页展示 当前用户 + 实时时间（每秒刷新），并从后端 /me 拉取资料

2. 系统架构与技术栈

前端（HarmonyOS / ArkTS，DevEco Studio）

Stage 模型、ArkUI 组件编写页面（Login / Register / Forgot / Home）

网络：@ohos.net.http 发起 HTTP 请求

路由：@ohos.router 页面跳转

状态存储：AppStorage 持久保存 token、username（App 级）

时间更新：全局 setInterval/clearInterval，每秒刷新时间

权限/配置：module.json5 声明 ohos.permission.INTERNET；main_pages.json 使用 src/window 新格式

ArkTS 规范：显式类型、显式泛型，规避 any/unknown、不使用结构类型/索引签名

后端（Spring Boot, Java 17）

Web：spring-boot-starter-web 暴露 REST API

数据访问：spring-boot-starter-data-jpa + Hibernate

数据库：MySQL（地址 192.168.10.9）；JPA ddl-auto: update 自动建表

密码安全：BCrypt 加盐哈希存储 passwordHash

参数校验：spring-boot-starter-validation（如 @NotBlank）

跨域：全局 CORS（便于联调）

令牌：自研 TokenService（UUID、不透明、内存存储、24h 过期，可随时撤销）

3. 数据模型

表：t_user

id(PK), username(唯一), passwordHash(BCrypt), email(可空), createdAt

设计原因：不存明文密码，哈希+盐；字段简单、便于演示

4. 后端接口（约定）

POST /api/auth/register 注册：{username,password,email?} → 成功 "注册成功"

POST /api/auth/login 登录：{username,password} → {token, username}

POST /api/auth/forgot 忘记：{username,newPassword} → "密码已重置"

GET /api/auth/me 自查：Authorization: Bearer <token> → {id,username,email}

POST /api/auth/logout 退出：Authorization: Bearer <token> → "已退出"

鉴权流程：
前端登录成功保存 token → 后续请求在 Header 带 Authorization: Bearer <token> → 后端 TokenService.verify() 校验并映射到 userId。

5. 前端页面与交互

LoginPage：输入用户名/密码 → 调用 /login → 存 token/username → 跳转 Home

RegisterPage：两次密码一致校验 → /register → 回到登录

ForgotPasswordPage：提交新密码 → /forgot → 回到登录

HomePage：

从 AppStorage 取 username 展示

定时器每秒更新当前时间

调用 /me 显示 id/email

点击“退出登录”→ 调用 /logout → 清空 token → 回到登录

6. 部署与运行

数据库：在 192.168.10.9 创建库 login_demo，放开远程与 3306 端口。

后端：配置 application.yml 数据源，运行 Spring Boot（端口 8080）。

前端：

module.json5 加 ohos.permission.INTERNET

main_pages.json 使用 {"src":[...],"window":{...}}

Api.ets 中 BASE_URL 指向 http://192.168.10.9:8080

真机/模拟器运行 App 流程可全走通

7. 安全性与取舍

已做：BCrypt 哈希、服务端令牌校验、令牌过期与撤销、基础校验与错误提示。

未做（可扩展）：

令牌持久化到 Redis/MySQL（当前内存存储，服务重启令牌失效，演示足够，生产需持久化）

使用 HTTPS、限流、日志审计、验证码/密码复杂度策略

可切换为 Spring Security + Session 或（如需要）JWT

8. 项目亮点

端到端打通：真机可用的 HarmonyOS 前端 + Spring Boot 后端全链路

严格 ArkTS 实践：显式类型、去 any/unknown、无结构类型，代码规范通过

清晰的鉴权模型：易理解、易演示、易迁移到更强方案（Redis/Session/JWT）

可维护的分层：DTO/Controller/Repository/Service 职责明确
<img width="587" height="1057" alt="forget" src="https://github.com/user-attachments/assets/78c913a6-af91-41ec-928d-d975cba93ee0" />
<img width="587" height="1057" alt="Register" src="https://github.com/user-attachments/assets/074145ed-63e7-49f6-905c-14aac0624d7e" />
<img width="587" height="1057" alt="Loin" src="https://github.com/user-attachments/assets/6a202861-39ec-457f-a712-05ab677dbeea" />
