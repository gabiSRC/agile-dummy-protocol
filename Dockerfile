FROM resin/raspberrypi2-debian:jessie-20161010

# Install wget and curl
RUN apt-get clean && apt-get update && apt-get install -y \
  wget \
  curl \
  && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Java
# with sources from https://launchpad.net/~webupd8team/+archive/ubuntu/java
# using the fix described at http://www.all4pages.com/2014/03/23/wie-installieren-wir-oracle-java-8-auf-wheezy-ueber-die-debian-sourcelist/
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    apt-get update && \
    apt-get install -y oracle-java8-installer --no-install-recommends && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/cache/oracle-jdk8-installer/ && \
    rm -rf /var/lib/apt/lists/*



# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Add packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git\
    ca-certificates \
    apt \
    software-properties-common \
    unzip \
    cpp \
    binutils \
    maven \
    gettext \
    libc6-dev \
    make \
    cmake \
    cmake-data \
    pkg-config \
    clang \
    gcc-4.9 \
    g++-4.9 \
    libglib2.0-0 \
    libglib2.0-dev \
    qdbus \
    && apt-get clean && rm -rf /var/lib/apt/lists/*




# resin-sync will always sync to /usr/src/app, so code needs to be here.
WORKDIR /usr/src/app
ENV APATH /usr/src/app

COPY scripts scripts

RUN CC=clang CXX=clang++ CMAKE_C_COMPILER=clang CMAKE_CXX_COMPILER=clang++ \
scripts/install-dbus-java.sh $APATH/deps

RUN CC=clang CXX=clang++ CMAKE_C_COMPILER=clang CMAKE_CXX_COMPILER=clang++ \
scripts/install-agile-interfaces.sh $APATH/deps

# we need dbus-launch
RUN apt-get update && apt-get install --no-install-recommends -y \
    dbus-x11 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# copy directories into WORKDIR
COPY iot.agile.protocol.DummyProtocol iot.agile.protocol.DummyProtocol

RUN mvn package


CMD [ "bash", "/usr/src/app/scripts/start.sh" ]
