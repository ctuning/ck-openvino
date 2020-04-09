#! /bin/bash

#
# CK installation script for OpenVINO.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#

# PACKAGE_DIR
# INSTALL_DIR

function exit_if_error() {
  if [ "${?}" != "0" ]; then exit 1; fi
}


export SRC_DIR=${INSTALL_DIR}/dldt
export OBJ_DIR=${INSTALL_DIR}/obj # NB: Must be called 'obj' for make to work properly.
export LIB_DIR=${INSTALL_DIR}/lib
export INCLUDE_DIR=${INSTALL_DIR}/include

echo "OpenVINO source directory: ${SRC_DIR}"
echo "OpenVINO build  directory: ${OBJ_DIR}"

rm -rf ${OBJ_DIR} ${INCLUDE_DIR} ${LIB_DIR}
mkdir -p ${OBJ_DIR} ${INCLUDE_DIR} ${LIB_DIR}

# Configure.
read -d '' CMK_CMD <<EO_CMK_CMD
${CK_ENV_TOOL_CMAKE_BIN}/cmake \
  -DCMAKE_C_COMPILER="${CK_CC_PATH_FOR_CMAKE}" \
  -DCMAKE_C_FLAGS="${CK_CC_FLAGS_FOR_CMAKE} ${EXTRA_FLAGS}" \
  -DCMAKE_CXX_COMPILER="${CK_CXX_PATH_FOR_CMAKE}" \
  -DCMAKE_CXX_FLAGS="${CK_CXX_FLAGS_FOR_CMAKE} ${EXTRA_FLAGS}" \
  -DCMAKE_AR="${CK_AR_PATH_FOR_CMAKE}" \
  -DCMAKE_RANLIB="${CK_RANLIB_PATH_FOR_CMAKE}" \
  -DCMAKE_LINKER="${CK_LD_PATH_FOR_CMAKE}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DTHREADING=OMP \
  -DENABLE_DLIA=OFF \
  -DENABLE_VPU=OFF \
  -DENABPP=OFF \
  -DENABLE_PROFILING_ITT=OFF \
  -DENABLE_VALIDATION_SET=OFF \
  -DENABLE_TESTS=OFF \
  -DENABLE_GNA=OFF \
  -DENABLE_CLDNN=OFF \
  -DENABLE_OPENCV=OFF \
  -DOpenCV_DIR="${CK_ENV_LIB_OPENCV}" \
  "${SRC_DIR}"
EO_CMK_CMD

# OpenVINO does not supprot CMAKE_INSTALL_PREFIX yet!: https://github.com/opencv/dldt/issues/423
#  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \

# First, print the EXACT command we are about to run (with all interpolations that have not been specifically blocked).
echo ${CMK_CMD}
echo ""
# Now, run it from the build directory.
cd ${OBJ_DIR} && eval ${CMK_CMD}
if [ "${?}" != "0" ] ; then
  echo "Error: CMake failed!"
  exit 1
fi

export CK_MAKE_EXTRA="VERBOSE=1"

# FIXME: Do not create a dummy file.
touch ${LIB_DIR}/libmlperf_loadgen.a

return 0
