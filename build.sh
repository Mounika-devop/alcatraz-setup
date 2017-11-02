#!/bin/bash

PACKAGE=alcatraz-puppet
VERSION=0.0.7
BUILDDIR=/tmp/build

rm -rf $BUILDDIR
mkdir -v -p $BUILDDIR

cp -dpR etc DEBIAN $BUILDDIR/
if [ $? -eq 0 ]
then 
    echo -e "INFO: Copied folder to build directory.."
else
    echo -e "ERROR: Not able to copy build dir.."
fi


chmod a+x $BUILDDIR/DEBIAN/postinst
chmod a+x $BUILDDIR/DEBIAN/preinst
chmod a+x $BUILDDIR/DEBIAN/postrm
cd ..
dpkg-deb --build $BUILDDIR ${PACKAGE}\_${VERSION}.deb
rm -rf $BUILDDIR
