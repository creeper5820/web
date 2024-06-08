---
title: 如何安稳地安装ubuntu系统
date: 2024-06-08 11:27:54
tags:
- ubuntu
categories:
- ubuntu
---
## 前言

ubuntu一直对驱动安装不是很友好，特别是一些比较老的版本，每次安装Nvidia驱动都是一场豪赌，顺利安装，或是**重装系统**。

有一段时间，我几乎是把能够下载到的所有版本的linux发行版试了个遍（`Redmi G 2021 骁龙版`），最终发现最为稳定的版本是最新的`ubuntu 24.04`

对于开发，我需要在`ubuntu`上运行`ros2`系统，编写`C/Cpp`程序，开发嵌入式，`ros2`的版本是和`ubuntu`版本强耦合的，但使用`docker`可以较为完美的解决这个问题，所以使用`ubuntu 24.04`对我的开发需求是没有什么阻碍的

## 准备工作
### 制作Ventoy启动盘

Ventoy是比较优雅的多系统装机方案，其安装较为简单，可以看看[这个教程](https://www.appinn.com/ventoy/)

### 下载ubuntu镜像

[Ubuntu Desktop Download Page](https://ubuntu.com/download/desktop)

## 安装系统

查询自己电脑如何进入Bios，**关闭安全启动**，选择从**U盘**启动，随后看到下面这个界面，选择正确的镜像，回车进入安装，启动方式**默认**即可

![ec1bf6dc99ba06a89ee1c8f51e6e8688.png](https://i2.mjj.rip/2024/06/08/ec1bf6dc99ba06a89ee1c8f51e6e8688.png)

![7b893de671032292bfe433437d5fe4f0.png](https://i2.mjj.rip/2024/06/08/7b893de671032292bfe433437d5fe4f0.png)

等待Ubuntu安装程序启动，随后你会看到这样一个界面，默认使用English即可

![18a688f82399d5d9abcd3ea6efcdce42.png](https://i2.mjj.rip/2024/06/08/18a688f82399d5d9abcd3ea6efcdce42.png)

一路默认下一步，到选择网络的界面，点击 `Connect to a WiFi network` 连接网络，当然，使用有线网络也是可以的

之后没有提及的界面默认下一步即可

![c9c4af26cd5468a89b9b059579f122ab.png](https://i2.mjj.rip/2024/06/08/c9c4af26cd5468a89b9b059579f122ab.png)

![c2cca4f755c49e028f19b5da9e007a19.png](https://i2.mjj.rip/2024/06/08/c2cca4f755c49e028f19b5da9e007a19.png)

随后到达 ``Install recommended proprietary sofrware?`` 界面，把两个推荐选项都勾选上，第一个选项是自动安装一些驱动，诸如nvidia驱动，第二个是额外安装一些视频的解码格式及其他的媒体格式解码，这样就不需要体验手动安装nvidia驱动的痛苦了

![33c8aa4b0dbb31969fcbde5fa705c204.png](https://i2.mjj.rip/2024/06/08/33c8aa4b0dbb31969fcbde5fa705c204.png)

下面到达 `How do you want to install Ubuntu?` 界面，选择安装ubuntu的位置，`Erase disk and install Ubuntu` 表示覆盖一整块硬盘安装，`Manual installation` 是自己指定安装的位置，可以指定在哪块硬盘分区安装

这里我们选择手动安装，即第二个选项

![e57f633ca700a2056a4d46378543ad73.png](https://i2.mjj.rip/2024/06/08/e57f633ca700a2056a4d46378543ad73.png)

在 `Manual partitioning` 界面我们可以对分区进行一些操作，从下面这张图可以看到有两块盘，第一块是U盘，62.06GB，第二块就是电脑上的固态硬盘了，鼠标点击分区，再点击左下角的 `-` ，就可以删除那块分区，删除后的分区会合并在 `Free space` 里面，这里我们不需要保留分区，如果别的分区装了系统，可以手动保留，注意仔细检查删除的分区是不需要使用的

![cfbe428dc4eb0cd2a1c247a61e68ea17.png](https://i2.mjj.rip/2024/06/09/cfbe428dc4eb0cd2a1c247a61e68ea17.png)

![8ddb4dfedb2e5def40dbaa472cc01468.png](https://i2.mjj.rip/2024/06/09/8ddb4dfedb2e5def40dbaa472cc01468.png)

接着点击空闲分区，再点击左下角的 `+`，进入 `create partition` 界面，Size默认最大值即可，`Used as` 表示要使用的文件系统，这里推荐 **Ext4** ，保留默认选项即可，接下来的 `Mount Point` 选择 `/`，即挂载根目录，三个选项都完成后点击 `OK` 即可，然后再点击右下角的 `Next` 进入下一步

![e848b37006c5299a41762028c59cdbd8.png](https://i2.mjj.rip/2024/06/09/e848b37006c5299a41762028c59cdbd8.png)

![46f0168b6e25207048766964d3e389c7.png](https://i2.mjj.rip/2024/06/09/46f0168b6e25207048766964d3e389c7.png)

创建账户，按照界面给出的信息填写即可，设置账户名字，密码，记住最好不要使用**中文**，时刻防范**编码问题**

随后选择时区(Time Zone)选择中国上海，也只能选择这个，都选完后到确认选项界面确认即可

![1095ad777a5edd9fa5e7dc78db95b46c.png](https://i2.mjj.rip/2024/06/09/1095ad777a5edd9fa5e7dc78db95b46c.png)

接着等待安装完成

![7e9f8a3326782c93443e97f2f32737d5.png](https://i2.mjj.rip/2024/06/09/7e9f8a3326782c93443e97f2f32737d5.png)

重启，拔出U盘，按Enter进入系统

![374731a787dc31c2a9d492ec969047ad.png](https://i2.mjj.rip/2024/06/09/374731a787dc31c2a9d492ec969047ad.png)

开机有一个 `Welcome Ubuntu` 界面卡，跳过就行，如果有信息洁癖可以拒绝`分享信息帮助Ubuntu`

![5e0f81975c685551a6e08e508bc1ca6a.png](https://i2.mjj.rip/2024/06/09/5e0f81975c685551a6e08e508bc1ca6a.png)

![a3f6109d08923f726a256f4b1c7b74e9.png](https://i2.mjj.rip/2024/06/09/a3f6109d08923f726a256f4b1c7b74e9.png)

## 系统设置

### 设置中文

打开设置界面，点击右上角的三个图标可以打开一个面板，在那里你可以找到齿轮图表，那就是设置

在左边一栏找到 `System` ，点击后在右边选择 `Region & Language` 选项

![af372e82c777d43181b4a67d4d0e87ab.png](https://i2.mjj.rip/2024/06/09/af372e82c777d43181b4a67d4d0e87ab.png)

接着点击第一个选项 `Manage installed Languages` ，点击后在弹出来的选项卡中选择 `install`

![2b9f955ccd7bb8b311bf07670c4c7c5a.png](https://i2.mjj.rip/2024/06/09/2b9f955ccd7bb8b311bf07670c4c7c5a.png)

等待下载完成后，在界面中找到 `Install/Remove Languages...` ，点击

![a5429cfe0c4a0e835bc9371965dfc216.png](https://i2.mjj.rip/2024/06/09/a5429cfe0c4a0e835bc9371965dfc216.png)

找到并勾选 `Chinese(simplified)` ，点击右下角的 `Apply`

![094f964f1be5fc412ca09827b26bd68b.png](https://i2.mjj.rip/2024/06/09/094f964f1be5fc412ca09827b26bd68b.png)

完成后，选项卡上出现`汉语(中国)`选项，把它拖到第一个

![d5e27cb120cc03a6691e5c500a04db43.png](https://i2.mjj.rip/2024/06/09/d5e27cb120cc03a6691e5c500a04db43.png)

完成后关掉设置，注销账户或者重新登陆，这几个操作都在右上角三个图标点出的卡片中完成，Logout 即可，然后重新登陆系统，会弹出一个警告，选择 `保留旧的名称(K)`（中文文件夹是不可接受的！）

![b70b12009fc3b5519f212740b4202adc.png](https://i2.mjj.rip/2024/06/09/b70b12009fc3b5519f212740b4202adc.png)

不出意外的话，你的Ubuntu已经是中文了，除了意外，就重启一下，重新加载系统即可

### 设置中文输入法

还是找到设置界面，在左边找到 `键盘` ，点击右边的 `+ 添加输入源(A)...`

![b0e40a83a6ad757646a705ecd5fd958d.png](https://i2.mjj.rip/2024/06/09/b0e40a83a6ad757646a705ecd5fd958d.png)

然后选择 `中文(智能拼音)` ，点击 `添加(A)`

![31c0c8046947ca7544cd6b667d22e8d4.png](https://i2.mjj.rip/2024/06/09/31c0c8046947ca7544cd6b667d22e8d4.png)

添加完成后把界面拉到最下面，找到修改快捷键，在 `打字` 那一选项中可以修改切换中英文的快捷键，按自己喜好设置即可

![0b6fc8f34b6051941e22562c6c4b2087.png](https://i2.mjj.rip/2024/06/09/0b6fc8f34b6051941e22562c6c4b2087.png)

到这里，Ubuntu基本上就安装好了


### 美化

在设置的 `外观` 选项中可以修改侧栏的形态，主题颜色等设置，按 `ctrl+alt+t` 可以唤出终端，右键终端面板选择 `配置文件首选项(P)` 可以修改终端的背景颜色，字体等设置，这里晒一下我的外观设置

![5f1cb5602945cb67d20afb3a87c084a8.png](https://i2.mjj.rip/2024/06/09/5f1cb5602945cb67d20afb3a87c084a8.png)