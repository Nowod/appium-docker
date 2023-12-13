FROM ubuntu:latest
USER root

# 基础设置
ENV NODE_MAJOR=20
WORKDIR /root
## Android ADB端口
EXPOSE 4723
## 更换gcc版本
RUN apt install gcc-9 g++-9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9
## 更换apt-get源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt clean
RUN apt-get update -y

# 配置appium2 环境
RUN apt-get install -y python3 python3-pip
WORKDIR /usr/bin
RUN ln -s /usr/bin/python3 python
RUN pip3 install -U pip
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip3 config set install.trusted-host https://mirrors.aliyun.com
RUN pip3 install Appium-Python-Client
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update -y
RUN apt-get install nodejs -y
RUN npm config set registry https://registry.npm.taobao.org
RUN npm install -g npm@latest
RUN npm install -g appium@next

## 配置Android 环境
RUN apt-get install -y android-tools-adb

## 配置iOS 环境
RUN apt-get install -y \
    build-essential \
    checkinstall \
    git \
    autoconf \
    automake \
    libtool-bin \
    python-dev-is-python3 \
    systemctl
RUN apt-get install -y clang
### USB和WiFi连接所需的依赖包
RUN apt-get install -y \
    libplist-dev \
    libusbmuxd-dev \
    libimobiledevice-dev \
    libusb-1.0-0-dev \
    libplist++-dev \
    libssl-dev \
    usbmuxd \
    udev \
    libavahi-client-dev \
    avahi-utils \
    libatomic-ops-dev \
    libatomic1 \
    bluez-tools

#### libplist
WORKDIR /root
RUN git clone https://github.com/libimobiledevice/libplist.git
WORKDIR /root/libplist
RUN ./autogen.sh && make && make install
RUN ldconfig
#### libimobiledevice-glue
WORKDIR /root
RUN git clone https://github.com/libimobiledevice/libimobiledevice-glue.git
WORKDIR /root/libimobiledevice-glue
RUN ./autogen.sh && make && make install
RUN ldconfig
#### libusbmuxd
WORKDIR /root
RUN git clone https://github.com/libimobiledevice/libusbmuxd.git
WORKDIR /root/libusbmuxd
RUN ./autogen.sh && make && make install
RUN ldconfig
#### libimobiledevice
WORKDIR /root
RUN git clone https://github.com/libimobiledevice/libimobiledevice.git
WORKDIR /root/libimobiledevice
RUN ./autogen.sh && make && make install
RUN ldconfig
#### libgeneral
WORKDIR /root
RUN git clone https://github.com/tihmstar/libgeneral.git
WORKDIR /root/libgeneral
# RUN git checkout 72
RUN ./autogen.sh
RUN make CFLAGS="-g -O2 -std=c11 -latomic" LDFLAGS=-latomic
RUN make install
RUN ldconfig
#### usbmuxd2
WORKDIR /root
RUN git clone https://github.com/tihmstar/usbmuxd2.git
WORKDIR /root/usbmuxd2
RUN git submodule init
RUN git submodule update
RUN sed -i '1 i LDFLAGS+="-latomic -lstdc++fs"' configure.ac
RUN ./autogen.sh && make && make install
RUN ldconfig
#### tidevice
# RUN npm install -g tidevice

#### 服务启动
# WORKDIR /root
# RUN sed -i s@/#domain-name=local/@/domain-name=local/@g  /etc/avahi/avahi-daemon.conf
# RUN sed -i s@/publish-hinfo=no/@/publish-hinfo=yes/@g  /etc/avahi/avahi-daemon.conf
# RUN sed -i s@/publish-workstation=no/@/publish-workstation=yes/@g  /etc/avahi/avahi-daemon.conf
# RUN systemctl list-unit-files avahi-daemon.service
# RUN systemctl enable avahi-daemon.service
# RUN systemctl start avahi-daemon.service
# RUN systemctl enable ssh.service
# RUN systemctl start ssh.service

