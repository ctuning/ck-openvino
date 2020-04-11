#!/bin/bash

BLD_DIR=${PWD}
SRC_DIR=../ov_mlperf/

# Configure.
${CK_ENV_TOOL_CMAKE_BIN}/${CK_CMAKE} ${CK_VERBOSE:-"--verbose=1"} \
-DInferenceEngine_DIR=${CK_ENV_LIB_DLDT_IE}/obj \
-DCMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES=${CK_ENV_LIB_DLDT_IE}/dldt/inference-engine/src/extension/ \
-DLOADGEN_LIB_DIR=${CK_ENV_LIB_MLPERF_LOADGEN_LIB} \
-DLOADGEN_DIR=${CK_ENV_LIB_MLPERF_LOADGEN_INCLUDE} \
-DBUILD_DIR=${BLD_DIR} \
${SRC_DIR}
err=$?; if [ $err != 0 ]; then exit $err; fi

# Build.
make VERBOSE=1
err=$?; if [ $err != 0 ]; then exit $err; fi

# MIsc.
${CK_OBJDUMP} a.out > a.out.dump
md5sum < a.out.dump > a.out.md5
git rev-parse HEAD > a.out.git_hash 2>null
exit 0
