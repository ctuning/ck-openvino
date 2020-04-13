#!/bin/bash

BLD_DIR=${PWD}
SRC_DIR=../ov_mlperf_cpu/

# Configure.
${CK_ENV_TOOL_CMAKE_BIN}/${CK_CMAKE} ${CK_VERBOSE:-"--verbose=1"} \
-DOPENCV_DIR=${CK_ENV_LIB_OPENCV}                  \
-DOPENVINO_DIR=${CK_ENV_LIB_OPENVINO}              \
-DLOADGEN_LIB_DIR=${CK_ENV_LIB_MLPERF_LOADGEN_LIB} \
-DLOADGEN_DIR=${CK_ENV_LIB_MLPERF_LOADGEN_INCLUDE} \
-DBUILD_DIR=${BLD_DIR} \
${SRC_DIR}
err=$?; if [ $err != 0 ]; then exit $err; fi

# Build.
make VERBOSE=1
err=$?; if [ $err != 0 ]; then exit $err; fi

exit 0
