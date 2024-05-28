---
layout: port
title: 替代Rviz的Foxglove可视化及调参平台
date: 2024-05-13 16:09:37
tags:
- ros2
- foxglove
- c/cpp
categories:
- ros2
---

### 准备工作
1. 在NUC环境中下载`Foxglove Bridge`，此为[文档连接](https://docs.foxglove.dev/docs/connecting-to-data/ros-foxglove-bridge/)，在`Linux`环境中使用下面指令下载
```sh
sudo apt install ros-$ROS_DISTRO-foxglove-bridge
```

2. 在调试用电脑中下载`Foxglove Studio`，此为[下载链接](https://foxglove.dev/download)，亦可使用[`Webview`](https://app.foxglove.dev/)，注意，`Webview` 在消息负载较大时会卡顿崩溃

3. 与 `NUC` 构建网络连接，可以通过Wifi或者网线使调试电脑和 NUC 在同一局域网段，不推荐使用 Wifi 进行调试，卡顿是常有的事

### 启动 Foxglove Bridge

在你的**车载 NUC** 中进行
```sh
# terminal in nuc, then topics will be forwarded to your pc
ros2 launch foxglove_bridge foxglove_bridge_launch.xml
```

### 启动 Foxglove Studio

在你的**调试用电脑**中进行
1. 打开 `Webview` 或者 `Application`
2. 登陆账户`(optional)`

### 使用 Foxglove Studio 查看可视化消息
### 使用 Foxglove Studio 查看参数曲线
### 使用 Foxglove Studio 调节参数，发布消息