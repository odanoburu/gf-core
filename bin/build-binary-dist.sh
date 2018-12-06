#! /bin/bash

### This script builds a binary distribution of GF from the source
### package that this script is a part of. It assumes that you have installed
### the Haskell Platform, version 2013.2.0.0 or 2012.4.0.0.
### Two binary package formats are supported: plain tar files (.tar.gz) and
### OS X Installer packages (.pkg).

os=$(uname)     # Operating system name (e.g. Darwin or Linux)
hw=$(uname -m)  # Hardware name (e.g. i686 or x86_64)

# GF version number:
ver=$(grep -i ^version: gf.cabal | sed -e 's/version://' -e 's/ //g')

name="gf-$ver"
destdir="$PWD/dist/$name"          # assemble binary dist here
prefix=${PREFIX:-/usr/local}       # where to install
fmt=${FMT:-tar.gz}                 # binary package format (tar.gz or pkg)
ghc=${GHC:-ghc}                    # which Haskell compiler to use

extralib="$destdir$prefix/lib"
extrainclude="$destdir$prefix/include"
extra="--extra-lib-dirs=$extralib --extra-include-dirs=$extrainclude"

set -e                             # Stop if an error occurs
set -x                             # print commands before executing them

## First configure & build the C run-time system
pushd src/runtime/c
bash setup.sh configure --prefix="$prefix"
bash setup.sh build
bash setup.sh install prefix="$destdir$prefix"
popd

# ## Build the python binding to the C run-time system
# if which >/dev/null python; then
#     pushd src/runtime/python
#     EXTRA_INCLUDE_DIRS="$extrainclude" EXTRA_LIB_DIRS="$extralib" python setup.py build
#     python setup.py install --prefix="$destdir$prefix"
#     if [ "$fmt" == pkg ] ; then
# 	# A hack for Python on OS X to find the PGF modules
# 	pyver=$(ls "$destdir$prefix/lib" | sed -n 's/^python//p')
# 	pydest="$destdir/Library/Python/$pyver/site-packages"
# 	mkdir -p "$pydest"
# 	ln "$destdir$prefix/lib/python$pyver/site-packages"/pgf* "$pydest"
#     fi
#     popd
# else
#     echo "Python is not installed, so the Python binding will not be included"
# fi

# ## Build the Java binding to the C run-time system
# if which >/dev/null javac && which >/dev/null jar ; then
#     pushd src/runtime/java
#     rm -f libjpgf.la # In case it contains the wrong INSTALL_PATH
#     if make CFLAGS="-I$extrainclude -L$extralib" INSTALL_PATH="$prefix/lib"
#     then
# 	make INSTALL_PATH="$destdir$prefix/lib" install
#     else
# 	echo "*** Skipping the Java binding because of errors"
#     fi
#     popd
# else
#     echo "Java SDK is not installed, so the Java binding will not be included"
# fi

# ## Build the Haskell binding to the C run-time system
# pushd src/runtime/haskell-bind
# pgfver=$(grep -i ^version: pgf2.cabal | sed -e 's/version://' -e 's/ //g')
# cabal install -w "$ghc" --only-dependencies $extra
# cabal configure -w "$ghc" --prefix="$prefix" $extra
# DYLD_LIBRARY_PATH="$extralib" LD_LIBRARY_PATH="$extralib" cabal build
# libdir=$(dirname $(find "dist" -name PGF2.hi))
# cabal register --gen-pkg-config=$libdir/pgf-$pgfver.conf
# cabal copy --destdir="$destdir"
# popd

## Build GF, with C run-time support enabled
cabal install -w "$ghc" --only-dependencies -fserver -gftest -fc-runtime $extra
cabal configure -w "$ghc" --prefix="$prefix" -fserver -gftest -fc-runtime $extra
DYLD_LIBRARY_PATH="$extralib" LD_LIBRARY_PATH="$extralib" cabal build exe:gf lib:gf gftest
  # Building the example grammars will fail, because the RGL is missing
cabal copy --destdir="$destdir"  # create www directory

## Build the RGL and copy it to $destdir
PATH=$PWD/dist/build/gf:$PATH
export GF_LIB_PATH="$(dirname $(find "$destdir" -name www))/lib"   # hmm
mkdir -p "$GF_LIB_PATH"
pushd ../gf-rgl
make build
make copy
popd

# Build GF again, including example grammars that need the RGL
DYLD_LIBRARY_PATH="$extralib" LD_LIBRARY_PATH="$extralib" cabal build exe:gf lib:gf gftest

## Copy GF to $destdir
cabal copy --destdir="$destdir"
libdir=$(dirname $(find "$destdir" -name PGF.hi))
cabal register --gen-pkg-config=$libdir/gf-$ver.conf

# ## Build gftest
# pushd ../gftest
# cabal install -w "$ghc" --only-dependencies $extra
# cabal configure -w "$ghc" --prefix="$prefix" $extr
# DYLD_LIBRARY_PATH="$extralib" LD_LIBRARY_PATH="$extralib" cabal build
# cabal copy --destdir="$destdir"
# gftestver=$(grep -i ^version: gftest.cabal | sed -e 's/version://' -e 's/ //g')
# libdir=$(dirname $(find "$destdir" -name PGF2.hi))
# cabal register --gen-pkg-config=$libdir/gftest-$gftestver.conf
# popd

## Create the binary distribution package
case $fmt in
    tar.gz)
	targz="$name-bin-$hw-$os.tar.gz"     # the final tar file
	tar -C "$destdir/$prefix" -zcf "dist/$targz" .
	echo "Created $targz, consider renaming it to something more user friendly"
	;;
    pkg)
	pkg=$name.pkg
	pkgbuild --identifier org.grammaticalframework.gf.pkg --version "$ver" --root "$destdir" --install-location / dist/$pkg
	echo "Created $pkg"
esac

rm -r "$destdir"
