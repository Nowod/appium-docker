# appium-docker

在 Windows 系统的 Docker 容器中通过 WiFi 连接 Android 和 iOS 真机设备运行 Appium2.x 测试用例。

## 构建 Docker

```bash
    $ git clone https://github.com/Nowod/appium-docker.git
    $ cd appium-docker
    $ docker build -t appium2-docker:v0.2 .
    $ docker run -itd --name appium -p 5037:5678 appium2-docker:v0.2
    $ docker run -itd --network host --name appium2 appium2-docker:v0.2
    $ docker exec -it appium2 /bin/bash
```

## 连接 Android 设备

1. 开启 **开发者选项**
2. 开启 **USB 调试**
3. 通过 USB 连接 PC，设置 Android 设备的监听端口
   ```PowerShell
       $ adb devices -l
       $ adb tcpip 11111
       $ adb kill-server
   ```
4. 拔掉 USB，将 Android 设备与 Docker 容器连接到同一个 Wi-Fi 网络，并查看 Android 设备的网络 IP
5. 在 Docker 容器中连接 Android 设备的网络 IP 和端口
   ```bash
       $ adb connect [devices ip]:11111
       $ adb devices -l
   ```
6. 下次通过 Wi-Fi 连接可直接执行 **Step-4** 和 **Step-5**

## 连接 iOS 设备

1. 下载[WebDriverAgent](https://github.com/appium/WebDriverAgent)代码库，并使用 XCode 构建到 iOS 设备中。
2. 启动 usbmuxd2
   ```bash
       $ usbmuxd -s -d --user root start
       $ iOS方案暂未调通
   ```
