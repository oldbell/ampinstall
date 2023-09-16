#!/bin/bash

yum -y install vim-enhanced.x86_64
yum -y install net-tools 
yum -y install wget

yum -y install systemd-devel.x86_64

# pcre 설치시 필요함
yum -y install bzip2-devel.x86_64 libzip-devel.x86_64

# pcre 설치, valgrind 옵션 사용시
yum -y install valgrind-devel.x86_64

# apr-1.7.4 설치 시 필요함
yum -y install expat-devel

# apache 설치 시 필요
yum -y install libxml2-devel.x86_64 

# cmake3 설치하기
# cmake가 없는 경우 설치
is_f=`whereis cmake |awk -F" " '{print $2}'`
if [ ${#is_f} -eq 0 ]
then
    yum remove cmake.x86_64
    yum -y install cmake3.x86_64
    if [ -e /usr/cmake3 ];
    then
        ln -s /usr/cmake3 /usr/cmake
    fi

    if [ -e /usr/share/cmake3 ];
    then
        ln -s /usr/share/cmake3 /usr/share/cmake
    fi
fi

yum -y install epel-release
yum -y install --enablerepo=epel libnghttp2 libnghttp2-devel

# gcc 최신설치
yum -y install centos-release-scl   
yum -y update scl-utils
yum -y install devtoolset-11
scl enable devtoolset-11 bash 
gcc -v



exit


src="/opt/source"
yum -y install vim-enhanced.x86_64

yum -y groupinstall "Development Tools"
yum -y install wget
#yum -y install cmake
yum -y install ncurses-devel
yum -y install libtool-ltdl
yum -y install expat-devel
yum -y install db4-devel
#yum -y install pcre-devel
yum -y install openssl-devel
yum -y install libxml2-devel.x86_64 
yum -y install libtool-ltdl-devel.x86_64
yum -y install systemd-devel.x86_64

# pcre 설치시 필요함
yum -y install bzip2-devel.x86_64 libzip-devel.x86_64

# cmake3 설치하기
# cmake가 없는 경우 설치
is_f=`whereis cmake |awk -F" " '{print $2}'`
if [ $is_f = "" ];
then
    yum -y install cmake3.x86_64
    yum remove cmake.x86_64
    if [ -e /usr/cmake3 ];
    then
            ln -s /usr/cmake3 /usr/cmake
    fi

    if [ -e /usr/share/cmake3 ];
    then
            ln -s /usr/share/cmake3 /usr/share/cmake
    fi
fi



# 
# “configure: WARNING: nghttp2 version is too old” when compile httpd-2 support http2 오류 발생시
# https://smarthink.tistory.com/23
yum -y install epel-release
yum -y install --enablerepo=epel libnghttp2 libnghttp2-devel

# gcc 최신설치
yum -y install centos-release-scl   
yum -y update scl-utils
yum -y install devtoolset-11
scl enable devtoolset-11 bash 
gcc -v

yum -y install vim-enhanced.x86_64