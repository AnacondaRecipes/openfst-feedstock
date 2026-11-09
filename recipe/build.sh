#!/bin/bash
set -ex

export CXXFLAGS="$(echo "${CXXFLAGS}" | sed -E 's@-std=c\+\+[^ ]+@@g')"
if [[ "${target_platform}" == osx-* ]]; then
  export CXXFLAGS="$(echo "${CXXFLAGS}" | sed -E 's@-fvisibility-inlines-hidden@@g')"
fi

cp "${BUILD_PREFIX}"/share/gnuconfig/config.* .

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
  OPENFST_CROSS_COMPILATION_CONFIGURE_OPTS=("--build=${BUILD}" "--host=${HOST}")
else
  OPENFST_CROSS_COMPILATION_CONFIGURE_OPTS=()
fi

./configure \
   --prefix="${PREFIX}" \
   --enable-static=no \
   --enable-compress \
   --enable-fsts \
   --enable-grm \
   --enable-special "${OPENFST_CROSS_COMPILATION_CONFIGURE_OPTS[@]}"

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make -j"${CPU_COUNT}" check || { if [[ -f src/test/test-suite.log ]]; then cat src/test/test-suite.log; fi; exit 1; }
fi

make -j"${CPU_COUNT}" install

