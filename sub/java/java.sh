#!/bin/sh -e

if [ -z "$JAVA_URL" ] ; then
  echo "required environment: JAVA_URL; skipping java"
  exit 0
fi

fs=data/java
installdir=/$fs

aria2c -o javatmp.$$ --file-allocation=falloc -x 4 $JAVA_URL
zfs create $fs
tar xf javatmp.$$ -C $installdir
rm -f javatmp.$$

for executable in $installdir/java*/bin/* ; do
    execname=`basename $executable`
    update-alternatives --install /usr/bin/$execname $execname $executable 10
done
