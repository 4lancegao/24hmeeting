# 24hMeeting（iOS + macOS）

这是一个跨平台（iOS / macOS）的 **24 小时长会视频软件** 起步骨架，基于 SwiftUI。

> 目标：先把可运行的“产品骨架 + 会话状态机 + 24 小时会议控制逻辑”搭起来，再接入真实音视频 SDK（WebRTC / Agora / Tencent RTC / Zoom SDK）。

## 功能范围（MVP）

- 创建会议（支持最长 24 小时）
- 加入会议（房间号 + 昵称）
- 会议状态管理：idle / connecting / connected / reconnecting / ended / failed
- 会议中计时与剩余时长提示
- 跨平台 UI（iOS 与 macOS 共用同一套 SwiftUI 代码）

## 目录结构

- `App/Meeting24hApp.swift`：应用入口
- `App/ContentView.swift`：跨平台页面
- `Core/MeetingRoom.swift`：会议模型
- `Core/CallSessionManager.swift`：会话管理与 SDK 抽象层
- `Docs/roadmap.md`：下一步落地路线

## 如何在 Xcode 中运行

1. 新建 `App` 模板（SwiftUI），勾选 iOS + macOS。
2. 将本仓库的 `App/*`、`Core/*` 文件拖入项目。
3. 设置 `Meeting24hApp` 为主入口。
4. 先使用内置 `MockVideoEngine` 验证流程。
5. 后续替换成真实视频 SDK。

## 生产化建议

- 音视频：优先选带 iOS/macOS 官方 SDK 的服务商
- 信令：WebSocket + 心跳 + 重连（建议服务端做房间状态持久化）
- 录制：云端录制（避免本地录制带来的性能与文件管理问题）
- 24 小时稳定性：
  - 断线重连策略（指数退避）
  - 设备锁屏/网络切换处理
  - 后台策略（iOS 需评估系统限制）

