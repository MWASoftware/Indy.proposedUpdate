#!/bin/sh

#This script copies revision information into the lpk files amd Makefile.fpc.

V1=$1
V2=$2
V3=$3
V4=$4
REVISION=`git rev-list --count HEAD`
echo "Update in `pwd`"
for PKG in `find . -name '*.lpk' -print`; do
	sed -i "/<CompilerOptions/,/<\/CompilerOptions/ ! { /<PublishOptions/,/<\/PublishOptions/ ! {s/<Version.*\/>/<Version Major=\"$V1\" Minor=\"$V2\" Release = \"$V3\" Build=\"$REVISION\" \/>/}}" $PKG
done
sed -i "s/INDY_VERSION=[0-9\.]\+/INDY_VERSION=$V1.$V2.$V3.$V4/" ../Makefile.fpc
	
cd ..
git commit -a -m "Updated Lazarus Package to version $1.$2.$3" 

exit 0

