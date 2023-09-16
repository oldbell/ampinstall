#!/bin/bash
# apache-2.24.8.sh 
src="/opt/source"
ldconf="/etc/ld.so.conf"
target_base="/usr/local"
is_remove=0

add_ldconfig()
{
    # ex) add_ldconfig ${name} ${target}/lib
    #     add_ldconfig openssl-1.1.1w /usr/local/openssl-1.1.1w/lib
    libname=$1
    libpath=$2
    ldconfig_base="/etc/ld.so.conf.d"
    ldconfig=${ldconfig_base}/${libname}
    isok=1

    if [ -e "${ldconfig}" ];
    then
        #echo "found $ldconfig"
        isok=0
    fi

    if [ ! -e "${libpath}" ];
    then
        #echo "ERROR can't found $libpath"
        isok=0
    fi

    cnt=`grep "$libpath" $ldconfig_base/*.conf |wc -l`
    if [ ! $cnt -eq 0 ];
    then
        #echo "found $libpath in $ldconfig_base/*.conf"
        isok=0
    fi

    if [ ${#libname} -eq 1 ];
    then
        #echo "ERROR found $libname is empty"
        isok=0
    fi

    #echo "libname : $libname"
    #echo "libpath : $libpath"
    #echo "isok    : $isok"

    if [ $isok -eq 1 ]
    then
        echo "$libpath" > $ldconfig_base/${libname}.conf
        echo "add $libpath to ${ldconfig_base}/${libname}.conf"
    fi
}

remove_path()
{
	link="/usr/local/$1"
	realpath="/usr/local/$2"
	if [ $is_remove -eq 1 ];
	then
		if [ -e "${link}" ];
		then
			rm -f ${link}
		fi

		if [ -e "${realpath}" ];
		then
			rm -fR ${realpath}
		fi
	fi
}

# ------ start ------

if [ ! -e "${src}" ];
then
	mkdir -p ${src}
fi

ver="1.1.1w"
name="openssl"
app="${name}-${ver}"
tar="${app}.tar"
gz="${tar}.gz"
target="${target_base}/${app}"
openssl_target="${target_base}/${name}"

cd ${src}
if [ ! -e "${src}/${app}" ];
then
    wget -O "${gz}" "https://www.openssl.org/source/$gz"
    if [ -e "${gz}" ];
    then
        if [ ! -e "${tar}" ];
        then
            gzip -d ${gz}
        fi
    fi

    if [ -e "${tar}" ];
    then
        tar -xvf ${tar}
    fi
    chown -R root:root ${app}
fi

# 기존에 있는 /usr/local/의 link와 설치 폴더 삭제하기
remove_path $name $app


if [ ! -e "${target}" ];
then
    cd ${app}
    make clean
    ./config --prefix=${target} shared zlib
    make -j4
    make install

    if [ -e "${target}" ];
    then
        cd ${target_base}
        ln -s ${app} ${name}
    fi
fi
add_ldconfig ${name} ${target}/lib
echo "done $app : $target"

# ----------------------------
# apache - pcre 8.39
# https://jaist.dl.sourceforge.net/project/pcre/pcre2/10.37/pcre2-10.37.tar.bz2
# https://jaist.dl.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.gz
ver="8.45"
name="pcre"
app="${name}-${ver}"
tar="${app}.tar"
gz="${tar}.gz"
target="${target_base}/${app}"
pcre_ver=$app
pcre_target=${target}
cd ${src}
if [ ! -e "${src}/${app}" ];
then
    wget -O "${gz}" "http://downloads.sourceforge.net/project/pcre/${name}/${ver}/${gz}"
    if [ -e "${gz}" ];
    then
        gzip -d ${gz}
    fi

    if [ -e "${tar}" ];
    then
        tar -xvf ${tar}
    fi
    chown -R root:root ${app}
fi

# 기존에 있는 /usr/local/의 link와 설치 폴더 삭제하기
remove_path $name $app



if [ ! -e "${target}" ];
then
    cd ${app}
    make clean
	# @see https://93it-serverengineer.co.kr/147
    #./configure --prefix=${target} --enable-utf8 --enable-unicode-properties --enable-pcregrep-libz  --enable-pcregrep-libbz2  --enable-jit 
	./configure --prefix=${target} --enable-pcre16 --enable-pcre32 --enable-jit --enable-utf8 --enable-unicode-properties --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-valgrind --with-gnu-ld
	
    make
    make install
    if [ -e "${target}" ];
    then
        cd ${target_base}
        ln -s ${app} ${name}
    fi
fi
add_ldconfig ${name} ${target}/lib
echo "done $app : $target"

# ----------------------------
# apache - pcre2 10.37
# https://jaist.dl.sourceforge.net/project/pcre/pcre2/10.37/pcre2-10.37.tar.bz2
ver="10.37"
name="pcre2"
app="${name}-${ver}"
tar="${app}.tar"
gz="${tar}.gz"
target="${target_base}/${app}"
pcre2_ver=$app
# @see https://king-ja.tistory.com/94
pcre2_target=$target/bin/pcre2-config
cd ${src}
if [ ! -e "${src}/${app}" ];
then
    wget -O "${gz}" "http://downloads.sourceforge.net/project/pcre/${name}/${ver}/${gz}"
    if [ -e "${gz}" ];
    then
        gzip -d ${gz}
    fi

    if [ -e "${tar}" ];
    then
        tar -xvf ${tar}
    fi
    chown -R root:root ${app}
fi

# 기존에 있는 /usr/local/의 link와 설치 폴더 삭제하기
remove_path $name $app


#read -p "check $app start..." -n 1 -r
if [ ! -e "${target}" ];
then
    cd ${app}
    make clean
	# @see https://93it-serverengineer.co.kr/147
    #./configure --prefix=${target} --enable-utf8 --enable-unicode-properties --enable-pcregrep-libz  --enable-pcregrep-libbz2  --enable-jit 
	./configure --prefix=${target} --enable-pcre2-8 --enable-pcre2-16 --enable-pcre2-32 --enable-jit --enable-jit-sealloc --enable-pcre2grep-jit --enable-pcre2grep-callout --enable-pcre2grep-callout-fork --enable-unicode --enable-pcre2grep-libz --enable-pcre2grep-libbz2 --enable-valgrind --enable-fuzz-support --enable-percent-zt --with-gnu-ld --with-pcre2grep-bufsize=20480 --with-pcre2grep-max-bufsize=1048576 --with-link-size=2 --with-parens-nest-limit=250 --with-heap-limit=20000000 --with-match-limit-depth=MATCH_LIMIT --enable-utf8 --enable-unicode-properties --enable-pcregrep-libz  --enable-pcregrep-libbz2
	
    make
    make install
    if [ -e "${target}" ];
    then
        cd ${target_base}
        ln -s ${app} ${name}
    fi
fi
add_ldconfig ${name} ${target}/lib
echo "done $app : $target"



#ls -lha "/usr/local/"
#read -p "check pcre-8.39 end..." -n -r

# ----------------------------
# apache - apr-1.7.0
# https://archive.apache.org/dist/apr/apr-1.7.0.tar.gz
cd ${src}
name="apr"
aprver="1.7.4"
ver="1.7.4"
app="${name}-${ver}"
tar="${app}.tar"
gz="${tar}.gz"
target="${target_base}/${app}"
apr_ver=$app
apr_target=$target
if [ ! -e "${src}/${app}" ];
then
    #wget http://mirror.apache-kr.org/apr/apr-${ver}.tar.gz
    wget https://archive.apache.org/dist/apr/${gz}
    if [ -e "${gz}" ];
    then
        gzip -d ${gz}
    fi

    if [ -e "${tar}" ];
    then
        tar -xvf ${tar}
    fi
    chown -R root:root ${app}
fi

# 기존에 있는 /usr/local/의 link와 설치 폴더 삭제하기
remove_path $name $app


if [ ! -e "${target}" ];
then
    cd ${app}
    cp -apr libtool libtoolT

    make clean
    ./configure --prefix=${target} --enable-posix-shm --enable-threads --enable-profile --enable-pool-concurrency-check 
    make && make install
    if [ -e "${target}" ];
    then
        cd ${target_base}
        ln -s ${app} ${name}
    fi
fi
add_ldconfig ${name} ${target}/lib
echo "done $app : $target"

# ----------------------------
# wget https://mirror.navercorp.com/apache/apr/apr-iconv-1.2.2.tar.gz
ver="1.2.2"
name="apr-iconv"
app="${name}-${ver}"
tar="${app}.tar"
gz="${tar}.gz"
target="${target_base}/${app}"
aprconv_ver=$app
aprconv_target=$target
cd ${src}
if [ ! -e "${src}/${app}" ];
then
    #wget http://mirror.apache-kr.org/apr/apr-iconv-${ver}.tar.gz
    wget http://mirror.apache-kr.org/apr/${gz}
    if [ -e "${gz}" ];
    then
        gzip -d ${gz}
    fi

    if [ -e "${tar}" ];
    then
        tar -xvf ${tar}
    fi
    chown -R root:root ${app}
fi

# 기존에 있는 /usr/local/의 link와 설치 폴더 삭제하기
remove_path $name $app

if [ ! -e "${target}" ];
then
    cd apr-iconv-${ver}
    make clean
    #./configure --prefix=/usr/local/apr-iconv-${ver} --with-apr=/usr/local/apr-${aprver}
    ./configure --prefix=${aprconv_target} --with-apr=${apr_target}
    make && make install
    if [ -e "${target}" ];
    then
        cd ${target_base}
        ln -s ${app} ${name}
    fi
fi
add_ldconfig ${name} ${target}/lib
echo "done $app : $target"



# ----------------------------
# https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz
# apache - apr-util-1.5.4
cd ${src}
aprutilver="1.6.3"
ver="1.6.3"
name="apr-util"
app="${name}-${ver}"
tar="${app}.tar"
gz="${tar}.gz"
target="${target_base}/${app}"
aprutil_ver=$app
aprutil_target=$target
cd ${src}
if [ ! -e "${src}/${app}" ];
then
    wget http://mirror.apache-kr.org/apr/$gz
    if [ -e "${gz}" ];
    then
        gzip -d ${gz}
    fi

    if [ -e "${tar}" ];
    then
        tar -xvf ${tar}
    fi
    chown -R root:root ${app}
fi

# 기존에 있는 /usr/local/의 link와 설치 폴더 삭제하기
remove_path $name $app

if [ ! -e "${target}" ];
then

    cd $app
    make clean
    #./configure --enable-layout=RedHat --prefix=${target} --with-crypto --with-apr=/usr/local/apr-${aprver}/ --with-openssl=${openssl_target}
    ./configure --enable-layout=RedHat --prefix=${target} --with-crypto --with-apr=${apr_target}/ --with-openssl=${openssl_target}
    make && make install
fi
add_ldconfig ${name} ${target}/lib
echo "done $app : $target"




# ----------------------------
# apache 2.4.23
#ver="2.4.48"
ver="2.4.57"
name="apache"
app="${name}-${ver}"
tar="${app}.tar"
gz="${tar}.gz"
target="${target_base}/${app}"
cd ${src}
if [ ! -e "${src}/httpd-${ver}" ];
then
    wget -O "httpd-${ver}.tar.gz" "http://apache.mirror.cdnetworks.com/httpd/httpd-${ver}.tar.gz"
    gzip -d httpd-${ver}.tar.gz
    tar -xvf httpd-${ver}.tar
    chown -R root:root httpd-${ver}
fi

echo "preforck 방식 및 worker 방식의 최대접속 값을 지정하는것이다. 기본값은 너무 낮게 설정되어있기 때문에 튜닝이 필요하다."
echo "vi ${src}/httpd-${ver}/server/mpm/prefork/prefork.c"
grep "define DEFAULT_SERVER_LIMIT" "${src}/httpd-${ver}/server/mpm/prefork/prefork.c"
echo "#define DEFAULT_SERVER_LIMIT 4096 (수정)"

grep "define DEFAULT_SERVER_LIMIT" "${src}/httpd-${ver}/server/mpm/worker/worker.c"
echo "vi ${src}/httpd-${ver}/server/mpm/worker/worker.c"
echo "#define DEFAULT_SERVER_LIMIT 20"
read -p "------ 위 source 수정 후 Enter를 치세요 ------ $ "

cd "${src}/httpd-${ver}"
make clean
./configure --prefix=${target} \
--enable-ssl \
--enable-http2 \
--enable-heartbeat --enable-heartmonitor \
--enable-info \
--enable-vhost-alias \
--enable-negotiation \
--enable-imagemap \
--enable-actions \
--enable-rewrite \
--enable-expires \
--enable-remoteip \
--enable-session --enable-session-cookie --enable-session-crypto \
--enable-http \
--enable-deflate \
--enable-so \
--enable-cache-disk \
--enable-cache \
--enable-cache-socache \
--enable-socache-memcache \
--enable-socache-redis \
--enable-charset-lite \
--enable-include \
--enable-ext-filter \
--enable-request    \
--enable-ratelimit \
--enable-xml2enc \
--enable-expires \
--enable-unique-id \
--enable-usertrack \
--enable-proxy --enable-proxy-connect --enable-proxy-http --enable-proxy-fcgi --enable-proxy-balancer --enable-proxy-express \
--enable-systemd \
--with-apr-util=${aprutil_target} \
--with-apr=${apr_target} \
--with-pcre=${pcre2_target} \
--with-ssl=${openssl_target}

# 기존에 있는 /usr/local/의 link와 설치 폴더 삭제하기
remove_path $name $app

make
make install

if [ -e "${target}" ];
then
    if [ -e "${target}" ];
    then
        cd ${target_base}
        ln -s ${app} ${name}
    fi
    #ln -s /usr/local/apache-${ver} /usr/local/apache
fi
echo "done $app : $target"
echo ""
echo ""
echo ""
echo "add  'AddType application/x-httpd-php .php' to ${target}/conf/httpd.conf"
# /usr/local/apache/bin/apachctl restart
# add 


# config syntax test
/usr/local/apache/bin/apachectl -t
