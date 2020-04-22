#! /bin/bash

#
# CK installation script for OpenVINO.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#

# Environment variables defined by CK:
# PACKAGE_DIR - where the package source files are (under $CK_REPOS/ck-openvino).
# INSTALL_DIR - where the libraries, binaries, etc. are to be deployed (under $CK_TOOLS).

function exit_if_error() {
  message=${1:-"unknown"}
  if [ "${?}" != "0" ]; then
    echo "Error: ${message}!"
    exit 1
  fi
}

export DLDT_DIR=${INSTALL_DIR}/dldt
if [ "${PACKAGE_GIT_CHECKOUT}" == "2019_R3.1" ] || [ "${PACKAGE_GIT_CHECKOUT}" == "2019_R3" ] || [ "${PACKAGE_GIT_CHECKOUT}" == "pre-release" ]; then
  export SRC_DIR=${DLDT_DIR}/inference-engine
else
  export SRC_DIR=${DLDT_DIR}
fi

# NB: Must be called 'obj' for make to work properly if PACKAGE_SKIP_LINUX_MAKE != "YES".
export OBJ_DIR=${INSTALL_DIR}/obj

export BIN_DIR=${INSTALL_DIR}/bin
export LIB_DIR=${INSTALL_DIR}/lib
export INC_DIR=${INSTALL_DIR}/include

rm -rf   ${OBJ_DIR} ${LIB_DIR} ${BIN_DIR} ${INC_DIR}
mkdir -p ${OBJ_DIR} ${LIB_DIR} ${BIN_DIR} ${INC_DIR}

# Configure the package.
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
  -DENABLE_PYTHON=ON \
  -DPYTHON_EXECUTABLE=${CK_ENV_COMPILER_PYTHON_FILE} \
  -DPYTHON_INCLUDE_DIR=$(${CK_ENV_COMPILER_PYTHON_FILE} -c "from distutils.sysconfig import get_config_var; print('{}'.format(get_config_var('INCLUDEPY')))") \
  -DPYTHON_LIBRARY=$(${CK_ENV_COMPILER_PYTHON_FILE} -c "from distutils.sysconfig import get_config_var; print('{}/{}'.format(get_config_var('LIBDIR'), get_config_var('INSTSONAME')))") \
  "${SRC_DIR}"
EO_CMK_CMD

# NB: Omitting since OpenVINO does not support CMAKE_INSTALL_PREFIX yet!: https://github.com/opencv/dldt/issues/423
#  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \

# First, print the EXACT command we are about to run (with all interpolations that have not been specifically blocked).
echo "Configuring the package with 'CMake' ..."
echo ${CMK_CMD}

echo

# Now, run it from the build directory.
cd ${OBJ_DIR} && eval ${CMK_CMD}
exit_if_error "CMake failed"

echo

# Build the package.
num_jobs=${CK_HOST_CPU_NUMBER_OF_PROCESSORS:-1}
echo "Building the package with 'make' using ${num_jobs} job(s) ..."
make --jobs ${num_jobs}  "VERBOSE=1"
exit_if_error "make failed"

# Install the binaries, libraries and include files.
echo "Copying the binaries to '${BIN_DIR}' ..."
cp ${SRC_DIR}/bin/intel64/Release/* ${BIN_DIR}
exit_if_error "copying the binaries failed"

echo "Copying the libraries to '${LIB_DIR}' ..."
cp ${SRC_DIR}/bin/intel64/Release/lib/* ${LIB_DIR}
cp ${DLDT_DIR}/inference-engine/temp/omp/lib/libiomp*.so ${LIB_DIR}
exit_if_error "copying the libraries failed"

echo "Copying the include files to '${INC_DIR}' ..."
cp -r ${DLDT_DIR}/inference-engine/include/* ${INC_DIR}
exit_if_error "copying the include files failed"

return 0
