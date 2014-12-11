#!/bin/sh -e

if [ -z "$JAVA_URL" ] ; then
  echo "required environment: JAVA_URL; skipping java"
  exit 0
fi

aria2c -o javatmp.$$ --file-allocation=falloc -x 4 $JAVA_URL
tar xf javatmp.$$ -C /usr/local
rm -f javatmp.$$

for executable in /usr/local/java*/bin/* ; do
    execname=`basename $executable`
    update-alternatives --install /usr/bin/$execname $execname $executable 10
done
