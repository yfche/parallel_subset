#!/bin/bash
set -eu
export PATH=/bin:$PATH

export PETSC_DIR=$SRC_DIR
export PETSC_ARCH=arch-conda-c-opt

if [[ $mpi == "openmpi" ]]; then
  export OMPI_MCA_plm=isolated
  export OMPI_MCA_rmaps_base_oversubscribe=yes
  export OMPI_MCA_btl_vader_single_copy_mechanism=none
elif [[ $mpi == "moose-mpich" ]]; then
  export HYDRA_LAUNCHER=fork
fi

unset CFLAGS CPPFLAGS CXXFLAGS FFLAGS LIBS LDFLAGS
if [[ $(uname) == Darwin ]]; then
    if [[ $HOST == arm64-apple-darwin20.0.0 ]]; then
        LDFLAGS="${LDFLAGS:-} -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
        CTUNING="-march=armv8.3-a -I$PREFIX/include"
        FTUNING="-march=armv8.3-a -I$PREFIX/include"
        export LIBRARY_PATH="$PREFIX/lib"
    else
        CTUNING="-march=core2 -mtune=haswell"
        FTUNING="-I$PREFIX/include"
    fi
    LDFLAGS="${LDFLAGS:-} -Wl,-headerpad-max-install-names"
else
    CTUNING="-march=nocona -mtune=haswell"
    FTUNING="-I$PREFIX/include"
fi

# for MPI discovery
export C_INCLUDE_PATH=$PREFIX/include
export CPLUS_INCLUDE_PATH=$PREFIX/include
export FPATH_INCLUDE_PATH=$PREFIX/include

source $PETSC_DIR/configure_petsc.sh
configure_petsc \
       --COPTFLAGS=-O3 \
       --CXXOPTFLAGS=-O3 \
       --FOPTFLAGS=-O3 \
       --with-x=0 \
       --with-ssl=0 \
       AR="${AR:-ar}" \
       CC="mpicc" \
       CXX="mpicxx" \
       FC="mpifort" \
       F90="mpifort" \
       F77="mpifort" \
       CFLAGS="${CTUNING}" \
       CXXFLAGS="${CTUNING}" \
       FFLAGS="${FTUNING}" \
       FCFLAGS="${FTUNING}" \
       LDFLAGS="${LDFLAGS:-}" \
       --prefix=$PREFIX || (cat configure.log && exit 1)

# Verify that gcc_ext isn't linked
for f in $PETSC_ARCH/lib/petsc/conf/petscvariables $PETSC_ARCH/lib/pkgconfig/PETSc.pc; do
  if grep gcc_ext $f; then
    echo "gcc_ext found in $f"
    exit 1
  fi
done

sedinplace() {
  if [[ $(uname) == Darwin ]]; then
    sed -i "" "$@"
  else
    sed -i"" "$@"
  fi
}

# Remove abspath of ${BUILD_PREFIX}/bin/python
sedinplace "s%${BUILD_PREFIX}/bin/python%python%g" $PETSC_ARCH/include/petscconf.h
sedinplace "s%${BUILD_PREFIX}/bin/python%python%g" $PETSC_ARCH/lib/petsc/conf/petscvariables
sedinplace "s%${BUILD_PREFIX}/bin/python%/usr/bin/env python%g" $PETSC_ARCH/lib/petsc/conf/reconfigure-arch-conda-c-opt.py

# Replace abspath of ${PETSC_DIR} and ${BUILD_PREFIX} with ${PREFIX}
for path in $PETSC_DIR $BUILD_PREFIX; do
    for f in $(grep -l "${path}" $PETSC_ARCH/include/petsc*.h); do
        echo "Fixing ${path} in $f"
        sedinplace s%$path%\${PREFIX}%g $f
    done
done

make

# FIXME: Workaround mpiexec setting O_NONBLOCK in std{in|out|err}
# See https://github.com/conda-forge/conda-smithy/pull/337
# See https://github.com/pmodels/mpich/pull/2755
make check MPIEXEC="${RECIPE_DIR}/mpiexec.sh"

make install

# Remove unneeded files
rm -f ${PREFIX}/lib/petsc/conf/configure-hash
find $PREFIX/lib/petsc -name '*.pyc' -delete

# Replace ${BUILD_PREFIX} after installation,
# otherwise 'make install' above may fail
for f in $(grep -l "${BUILD_PREFIX}" -R "${PREFIX}/lib/petsc"); do
  echo "Fixing ${BUILD_PREFIX} in $f"
  sedinplace s%${BUILD_PREFIX}%${PREFIX}%g $f
done

echo "Removing example files"
du -hs $PREFIX/share/petsc/examples/src
rm -fr $PREFIX/share/petsc/examples/src
echo "Removing data files"
du -hs $PREFIX/share/petsc/datafiles/*
rm -fr $PREFIX/share/petsc/datafiles

# Set PETSC_DIR environment variable for those that need it
mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cat <<EOF > "${PREFIX}/etc/conda/activate.d/activate_${PKG_NAME}.sh"
export PETSC_DIR=${PREFIX}
EOF
cat <<EOF > "${PREFIX}/etc/conda/deactivate.d/deactivate_${PKG_NAME}.sh"
unset PETSC_DIR
EOF
