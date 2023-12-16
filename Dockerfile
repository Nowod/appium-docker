FROM ubuntu:latest
USER root
WORKDIR /root
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 更换国内apt-get源
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
    && sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list \
    && apt clean && apt-get update -y

# 部署Python3环境
RUN apt-get install -y python3 python3-pip \
    && pip3 install -U pip \
    && pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip3 config set install.trusted-host https://mirrors.aliyun.com \
    && pip3 install Appium-Python-Client
# WORKDIR /usr/bin
# RUN ln -s /usr/bin/python3 python


# 部署NodeJS环境
ENV NODE_MAJOR=20
RUN apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update -y \
    && apt-get install nodejs -y \
    && npm config set registry https://registry.npm.taobao.org \
    && npm install -g npm@latest

# 部署Appium2.x环境
RUN npm install -g appium@next

# 部署adb环境, 用于连接Android设备
EXPOSE 5037
RUN apt-get install -y android-tools-adb

# 部署usbmuxd2+tidevice环境, 用于连接iOS设备
RUN apt-get install -y \
    build-essential \
    checkinstall \
    git \
    autoconf \
    automake \
    libtool-bin \
    python-dev-is-python3 \
    systemctl \
    clang \
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
    bluez-tools
## 拉取依赖lib的Github库, 需要能够访问Github
RUN cd ~ \
    && git clone https://github.com/libimobiledevice/libplist.git \
    && cd libplist \
    && ./autogen.sh \
    && make \
    && make install \
    && ldconfig
RUN cd ~ && git clone https://github.com/libimobiledevice/libimobiledevice-glue.git \
    && cd libimobiledevice-glue \
    && ./autogen.sh \
    && make \
    && make install \
    && ldconfig
RUN cd ~ \
    && git clone https://github.com/libimobiledevice/libusbmuxd.git \
    && cd libusbmuxd \
    && ./autogen.sh \
    && make \
    && make install \
    && ldconfig
RUN cd ~ \
    && git clone https://github.com/libimobiledevice/libimobiledevice.git \
    && cd libimobiledevice \
    && ./autogen.sh \
    && make \
    && make install \
    && ldconfig
RUN cd ~ \
    && git clone https://github.com/tihmstar/libgeneral.git \
    && cd libgeneral \
    && ./autogen.sh \
    && make \
    && make install \
    && ldconfig
RUN cd ~ \
    && git clone https://github.com/tihmstar/usbmuxd2.git \
    && cd usbmuxd2 \
    && sed -i 's/$srcdir\/configure "$@"/$srcdir\/configure CC=clang CXX=clang++ "$@"/g' ./autogen.sh \
    && git submodule init \
    && git submodule update \
    # && ./configure CC=clang CXX=clang++ \
    && ./autogen.sh \
    && make \
    && make install \
    && ldconfig
# 更换gcc版本, usbmuxd2编译需要C++17及以上
# RUN apt install gcc-9 g++-9
# RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9

RUN pip3 install -U "tidevice[openssl]"
RUN sed -i s@/#domain-name=local/@/domain-name=local/@g  /etc/avahi/avahi-daemon.conf \
    && sed -i s@/publish-hinfo=no/@/publish-hinfo=yes/@g  /etc/avahi/avahi-daemon.conf \
    && sed -i s@/publish-workstation=no/@/publish-workstation=yes/@g  /etc/avahi/avahi-daemon.conf \
    && systemctl list-unit-files avahi-daemon.service \
    && systemctl enable avahi-daemon.service \
    #     && systemctl start avahi-daemon.service \
    # && systemctl enable ssh.service \
    # && systemctl start ssh.service \