#!/usr/bin/env bash

set -e

N_PROC=${N_PROC:- 10}

OUTPUT_DIR=/build
INSTALL_DIR=/opt/lambda-runtime
BUILD_DIR=/tmp/build

yum install -y autoconf bison gcc gcc-c++ tar gzip re2c make git unzip zip xz cmake3

#cmake3 -> cname
ln -s /usr/bin/cmake3 /usr/bin/cmake

# We need some default compiler variables setup
PKG_CONFIG_PATH="$INSTALL_DIR/lib64/pkgconfig:$INSTALL_DIR/lib/pkgconfig"
PKG_CONFIG="/usr/bin/pkg-config"
PATH="$INSTALL_DIR/bin:$PATH"

export LD_LIBRARY_PATH="$INSTALL_DIR/lib64:$INSTALL_DIR/lib"

# Enable parallelism for cmake (like make -j)
# See https://stackoverflow.com/a/50883540/245552
export CMAKE_BUILD_PARALLEL_LEVEL=$N_PROC


mkdir -p $BUILD_DIR  \
$INSTALL_DIR/bin \
$INSTALL_DIR/doc \
$INSTALL_DIR/etc/php \
$INSTALL_DIR/etc/php/conf.d \
$INSTALL_DIR/include \
$INSTALL_DIR/lib \
$INSTALL_DIR/lib64 \
$INSTALL_DIR/libexec \
$INSTALL_DIR/sbin \
$INSTALL_DIR/share

# ZLIB Build
# https://github.com/madler/zlib/releases
# Needed for:
#   - openssl
#   - curl
#   - php
# Used By:
#   - xml2
VERSION_ZLIB=1.2.11
ZLIB_BUILD_DIR=$BUILD_DIR/xml2

mkdir -p $ZLIB_BUILD_DIR; curl -Ls  http://zlib.net/zlib-$VERSION_ZLIB.tar.xz | tar xJC $ZLIB_BUILD_DIR --strip-components=1

# Move into the unpackaged code directory
cd  $ZLIB_BUILD_DIR

make distclean \
&& CFLAGS="" \
CPPFLAGS="-I$INSTALL_DIR/include  -I/usr/include" \
LDFLAGS="-L$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib" \
./configure \
--prefix=$INSTALL_DIR \
--64

make -j$N_PROC install && rm $INSTALL_DIR/lib/libz.a

# OPENSSL Build
# https://github.com/openssl/openssl/releases
# Needs:
#   - zlib
# Needed by:
#   - curl
#   - php
VERSION_OPENSSL=1.1.1a
OPENSSL_BUILD_DIR=$BUILD_DIR/openssl
CA_BUNDLE_SOURCE="https://curl.haxx.se/ca/cacert.pem"
CA_BUNDLE="$INSTALL_DIR/ssl/cert.pem"

mkdir -p $OPENSSL_BUILD_DIR; curl -Ls  https://github.com/openssl/openssl/archive/OpenSSL_${VERSION_OPENSSL//./_}.tar.gz \
| tar xzC $OPENSSL_BUILD_DIR --strip-components=1

# Move into the unpackaged code directory
cd  $OPENSSL_BUILD_DIR/

# Configure the build
CFLAGS="" \
CPPFLAGS="-I$INSTALL_DIR/include  -I/usr/include" \
LDFLAGS="-L$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib" \
./config \
--prefix=$INSTALL_DIR \
--openssldir=$INSTALL_DIR/ssl \
--release \
no-tests \
shared \
zlib

make install && curl -k -o $CA_BUNDLE $CA_BUNDLE_SOURCE

# LIBZIP Build
# https://github.com/nih-at/libzip/releases
# Needed by:
#   - php
VERSION_ZIP=1.5.1
ZIP_BUILD_DIR=$BUILD_DIR/zip

mkdir -p $ZIP_BUILD_DIR/bin/; curl -Ls https://github.com/nih-at/libzip/archive/rel-${VERSION_ZIP//./-}.tar.gz | tar xzC $ZIP_BUILD_DIR --strip-components=1

# Move into the unpackaged code directory
cd  $ZIP_BUILD_DIR/bin/

# Configure the build
CFLAGS="" \
CPPFLAGS="-I$INSTALL_DIR/include -I/usr/include" \
LDFLAGS="-L$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib" \
cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DCMAKE_BUILD_TYPE=RELEASE

cmake  --build . --target install

# Download php source
PHP_BUILD_DIR=$BUILD_DIR/php
PHP_VER=7.2.33

mkdir -p $PHP_BUILD_DIR;curl -sL https://github.com/php/php-src/archive/php-$PHP_VER.tar.gz | tar xzC $PHP_BUILD_DIR --strip-components=1

# Move into the unpackaged code directory
cd $PHP_BUILD_DIR/

yum install -y curl-devel readline-devel libxml2-devel libicu-devel

./buildconf --force
CFLAGS="-fstack-protector-strong -fpic -fpie -Os -ffunction-sections -fdata-sections" \
CPPFLAGS="-fstack-protector-strong -fpic -fpie -Os -ffunction-sections -fdata-sections" \
LDFLAGS="-L$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib -Wl,-O1 -Wl,--strip-all -Wl,--hash-style=both -pie" \
./configure \
--prefix=$INSTALL_DIR \
--build=x86_64-pc-linux-gnu \
--enable-option-checking=fatal \
--with-config-file-path=$INSTALL_DIR/etc/php \
--with-config-file-scan-dir=$INSTALL_DIR/etc/php/conf.d:/var/task/php/conf.d \
--with-openssl=$INSTALL_DIR \
--with-libdir=lib64 \
--with-curl \
--with-pdo-mysql \
--with-zlib=$INSTALL_DIR \
--with-zlib-dir=$INSTALL_DIR \
--enable-ftp \
--enable-mbstring \
--disable-cgi \
--disable-phpdbg \
--disable-phpdbg-webhelper \
--without-pear

make -j$N_PROC install

# handle php.ini
cp php.ini-production ${INSTALL_DIR}/etc/php/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "GPCSE"/g' ${INSTALL_DIR}/etc/php/php.ini

# libpng
VERSION_LIBPNG=1.5.13
LIBPNG_BUILD_DIR=$BUILD_DIR/libpng

mkdir -p $LIBPNG_BUILD_DIR; curl -Ls http://prdownloads.sourceforge.net/libpng/libpng-$VERSION_LIBPNG.tar.gz | tar xzC $LIBPNG_BUILD_DIR --strip-components=1

# Move into the unpackaged code directory
cd  $LIBPNG_BUILD_DIR/
CFLAGS="" \
CPPFLAGS="-I$INSTALL_DIR/include  -I/usr/include" \
LDFLAGS="-L$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib" \
./configure \
--disable-dependency-tracking \
--prefix=$INSTALL_DIR

make && make -j$N_PROC install

# PHP ext image manipulation layer
# libjpg
VERSION_LIBJPEG=v9d
LIBJPEG_BUILD_DIR=$BUILD_DIR/libpng

mkdir -p $LIBJPEG_BUILD_DIR; curl -Ls http://ijg.org/files/jpegsrc.$VERSION_LIBJPEG.tar.gz | tar xzC $LIBJPEG_BUILD_DIR --strip-components=1

# Move into the unpackaged code directory
cd  $LIBJPEG_BUILD_DIR/
CFLAGS="" \
CPPFLAGS="-I$INSTALL_DIR/include  -I/usr/include" \
LDFLAGS="-L$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib" \
./configure \
--disable-dependency-tracking \
--prefix=$INSTALL_DIR

make && make -j$N_PROC install

GD_DIR=$BUILD_DIR/php/ext/gd

cd $GD_DIR

$INSTALL_DIR/bin/phpize --with-php-config=$INSTALL_DIR/bin/php-config
CFLAGS="-fstack-protector-strong -fpic -fpie -Os -ffunction-sections -fdata-sections" \
CPPFLAGS="-fstack-protector-strong -fpic -fpie -Os -ffunction-sections -fdata-sections" \
LDFLAGS="-L$INSTALL_DIR/lib64 -L$INSTALL_DIR/lib -Wl,-O1 -Wl,--strip-all -Wl,--hash-style=both -pie" \
./configure --enable-option-checking=fatal \
--with-png-dir=$INSTALL_DIR \
--with-jpeg-dir=$INSTALL_DIR

make && make -j$N_PROC install

EXTENSION_DIR=$(php -r "echo ini_get('extension_dir');")
GD_DIR=${EXTENSION_DIR#/opt/}
REL_DIR=${INSTALL_DIR#/opt/}
INI_PATH=$INSTALL_DIR/etc/php/conf.d/gd.ini

# Activate extension
echo "extension=gd.so" > $INI_PATH

cd /opt
zip --symlinks -r $OUTPUT_DIR/layer.zip $REL_DIR/etc/php/conf.d/gd.ini $GD_DIR/gd.so $REL_DIR/lib/libjpeg*.* $REL_DIR/lib/libpng*.*