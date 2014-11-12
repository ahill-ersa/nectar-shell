#!/bin/sh -e

if [ -z "$JAVA_URL" ] ; then
  echo "required environment: JAVA_URL; skipping java"
  exit 0
fi

aria2c -o javatmp.$$ --file-allocation=falloc -x 4 $JAVA_URL
tar xf javatmp.$$ -C /usr/local
rm -f javatmp.$$

for executable in `ls -1 /usr/local/java*/bin` ; do
  update-alternatives --install /usr/bin/$executable $executable /usr/local/java*/bin/$executable 10
done
