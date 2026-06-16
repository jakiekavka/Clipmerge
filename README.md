# ClipMerge

macOS 剪贴板合并工具 — 后台监控剪贴板，通过全局快捷键将最近两次复制的内容合并。

## 功能

- 自动记录剪贴板历史（最多 15 条）
- **Control + Option + M** 合并最近两次复制：旧内容在上，新内容在下
- 合并后播放系统提示音，合并结果自动写入剪贴板

## 使用方式

1. 复制第一段文字（Cmd+C）
2. 复制第二段文字（Cmd+C）
3. 按下 **Control + Option + M**
4. 粘贴（Cmd+V）得到合并结果

## 文件结构

```
clipmerge           # Swift 编译的二进制文件
main.swift          # 源代码
sound_daemon.sh     # 提示音守护脚本
```

## 开机自启

通过 `~/Library/LaunchAgents/com.jakieh.clipmerge.plist` 配置 launchd 自动启动，登录时同时拉起主程序和提示音守护进程。

## 提示音

默认播放系统 Pop 提示音。可在 `sound_daemon.sh` 中修改 `afplay` 的目标文件来更换声音。

## 许可

个人使用。
