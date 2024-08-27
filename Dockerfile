FROM ubuntu:18.04
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list; \
    else \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse" > /etc/apt/sources.list && \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
        echo "deb http://security.ubuntu.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list; \
    fi
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -o Acquire::https::Verify-Peer=false update && \
    apt-get -y install ca-certificates

RUN update-ca-certificates

RUN apt-get -y update && \
    apt-get -y install python \
                       python3 \
                       sudo
RUN rm /usr/bin/python && ln -s /usr/bin/python2 /usr/bin/python
ADD . /build_tools
WORKDIR /build_tools

# Define build arguments
ARG BRANCH
ARG PLATFORM
ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}

# Set default values for environment variables
ENV BRANCH ${BRANCH}
ENV PLATFORM ${PLATFORM}

# Define the command to run
CMD cd tools/linux && \
    if [ -n "$BRANCH" ]; then \
        BRANCH_ARG="--branch=${BRANCH}"; \
    else \
        BRANCH_ARG=""; \
    fi && \
    if [ -n "$PLATFORM" ]; then \
        PLATFORM_ARG="--platform=${PLATFORM}"; \
    else \
        PLATFORM_ARG=""; \
    fi && \
    python3 ./automate.py $BRANCH_ARG $PLATFORM_ARG

