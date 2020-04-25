#!/bin/bash

if [ "${CK_CALIBRATE_IMAGENET}" != "yes" ]; then

  echo ""
  echo "######################################################################################"
  echo "Converting TensorFlow model to OpenVINO format..."
  echo ""

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

  if [ "${?}" != "0" ] ; then
    echo "Error: Conversion to OpenVINO format failed!"
    exit 1
  fi

else # END OF if [ "${CK_CALIBRATE_IMAGENET}" != "yes" ]

  echo ""
  echo "######################################################################################"
  echo "Converting annotations ..."
  echo ""

  VAL_FILE=$(basename ${CK_CAFFE_IMAGENET_VAL_TXT})
  head -n500 ${CK_CAFFE_IMAGENET_VAL_TXT} > ${INSTALL_DIR}/${VAL_FILE}

  read -d '' CMD <<END_OF_CMD
  ${CK_ENV_COMPILER_PYTHON_FILE} \
    ${CK_ENV_LIB_OPENVINO_CONVERT_ANNOTATION_PY} \
    imagenet \
    --annotation_file ${INSTALL_DIR}/${VAL_FILE} \
    --labels_file ${CK_CAFFE_IMAGENET_SYNSET_WORDS_TXT} \
    --has_background True \
    --output_dir ${INSTALL_DIR}
END_OF_CMD

  echo ${CMD}
  eval ${CMD}

  if [ "${?}" != "0" ] ; then
    echo "Error: Converting annotations failed!"
    exit 1
  fi


  echo ""
  echo "######################################################################################"
  echo "Running calibration ..."
  echo ""

  read -d '' CMD <<END_OF_CMD
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CK_ENV_LIB_OPENVINO}/lib/ ; \
  ${CK_ENV_COMPILER_PYTHON_FILE} \
    ${CK_ENV_LIB_OPENVINO_CALIBRATE_PY} \
    -c ${INSTALL_DIR}/config.yml \
    -M ${CK_ENV_LIB_OPENVINO_MO_DIR} \
    -C ${INSTALL_DIR} \
    -e ${CK_ENV_LIB_OPENVINO}/lib/ \
    --output_dir ${INSTALL_DIR}
END_OF_CMD

  echo ${CMD}
  eval ${CMD}

  if [ "${?}" != "0" ] ; then
    echo "Error: Calibration failed!"
    exit 1
  fi

fi # END OF if/else [ "${CK_CALIBRATE_IMAGENET}" != "yes" ]

echo "Done."
exit 0
