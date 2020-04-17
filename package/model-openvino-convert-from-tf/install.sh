#!/bin/bash

if [ "${CK_ENV_TENSORFLOW_MODEL_MODEL_NAME}" = "MLPerf SSD-MobileNet" ] ; then
  CUSTOM="--tensorflow_object_detection_api_pipeline_config $(dirname ${CK_ENV_TENSORFLOW_MODEL_TF_FROZEN_FILEPATH})/pipeline.config \
      --tensorflow_use_custom_operations_config ${CK_ENV_LIB_OPENVINO_MO_DIR}/extensions/front/tf/ssd_v2_support.json"
else
  CUSTOM=""
fi

if [ ${ML_MODEL_COLOUR_CHANNELS_BGR:-NO} == "YES" ] ; then
  REVERSE_INPUT_CHANNELS="--reverse_input_channels"
else
  REVERSE_INPUT_CHANNELS=""
fi

read -d '' CMD <<END_OF_CMD
${CK_ENV_COMPILER_PYTHON_FILE} \
  ${CK_ENV_LIB_OPENVINO_MO_DIR}/mo.py \
  --model_name ${MODEL_NAME} \
  --input_model ${CK_ENV_TENSORFLOW_MODEL_TF_FROZEN_FILEPATH} \
  --input_shape [1,${CK_ENV_TENSORFLOW_MODEL_IMAGE_HEIGHT},${CK_ENV_TENSORFLOW_MODEL_IMAGE_WIDTH},3] \
  ${REVERSE_INPUT_CHANNELS} \
  ${CUSTOM}
END_OF_CMD

echo ${CMD}
eval ${CMD}

echo "Done."
