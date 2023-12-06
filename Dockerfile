FROM ubuntu:latest
USER root

# nodejs版本设置
ENV NODE_MAJOR=20

RUN cd ~

# 更换apt-get源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt clean
RUN apt-get update -y

# 安装python环境
RUN apt-get install -y python3 python3-pip
# 更换pip源
RUN pip3 install -U pip
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip3 config set install.trusted-host https://mirrors.aliyun.com
RUN pip3 install Appium-Python-Client

# 安装NodeJS环境
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -y
RUN apt-get install nodejs -y
RUN npm config set registry https://registry.npm.taobao.org
RUN npm install -g npm@latest


# 安装appium2环境
RUN npm install -g appium@next
RUN appium driver install uiautomator2
RUN appium driver install xcuitest
RUN appium plugin install --source=npm appium-reporter-plugin

# 安装adb环境
RUN apt-get install -y android-tools-adb

# 安装tidevice环境
RUN pip3 install -U "tidevice[openssl]"   # Recommend

EXPOSE 4723