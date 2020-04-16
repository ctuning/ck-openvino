#!/bin/bash

if [ "${CK_ENV_TENSORFLOW_MODEL_MODEL_NAME}" = "MLPerf SSD-MobileNet" ] ; then
  CUSTOM="--tensorflow_object_detection_api_pipeline_config $(dirname ${CK_ENV_TENSORFLOW_MODEL_TF_FROZEN_FILEPATH})/pipeline.config \
      --tensorflow_use_custom_operations_config ${CK_ENV_LIB_OPENVINO_MO_DIR}/extensions/front/tf/ssd_v2_support.json"
else
    CUSTOM=""
fi

read -d '' CMD <<END_OF_CMD
${CK_ENV_COMPILER_PYTHON_FILE} \
  ${CK_ENV_LIB_OPENVINO_MO_DIR}/mo.py \
  --model_name ${MODEL_NAME} \
  --input_model ${CK_ENV_TENSORFLOW_MODEL_TF_FROZEN_FILEPATH} \
  --input_shape [1,${CK_ENV_TENSORFLOW_MODEL_IMAGE_HEIGHT},${CK_ENV_TENSORFLOW_MODEL_IMAGE_WIDTH},3] \
  --reverse_input_channels \
  ${CUSTOM}
END_OF_CMD

echo ${CMD}
eval ${CMD}

echo "Done."
