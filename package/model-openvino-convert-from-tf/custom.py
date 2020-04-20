#!/usr/bin/python

#
# Developer: Anton Lokhmotov, anton@dividiti.com
#

import os
import sys
import json
from pprint import pprint

################################################################################
# OpenVINO configuration file template.
# Original: https://raw.githubusercontent.com/mlperf/inference_results_v0.5/master/closed/Intel/calibration/OV_RN-50-sample/resnet_v1.5_50.yml
template = \
'''
models:
  - name: %(name)s
    launchers:
      - framework: dlsdk
        device: CPU
        tf_model: %(tf_model)s
        adapter: classification
        mo_params:
          data_type: FP32 (or FP16)
          input_shape: (%(batch_size)d, %(height)d, %(width)d, %(channels)d)
          output: %(output)s
        cpu_extensions: AUTO
    datasets:
      - name: ImageNet2012_bkgr
        data_source: %(data_source)s
        annotation: </path/to/mlperf_list_1/imagenet.pickle>
        dataset_meta: </path/to/mlperf_list_1/imagenet.json>
        annotation_conversion:
          converter: imagenet
          annotation_file: %(annotation_file)s
          labels_file: %(labels_file)s
          has_background: True
        subsample_size: 500
        preprocessing:
          - type: resize
            size: 256
            aspect_ratio_scale: greater
          - type: crop
            size: 224
          - type: normalization
            mean: %(mean_r)d, %(mean_g)d, %(mean_b)d
        metrics:
          - name: accuracy @ top1
            type: accuracy
            top_k: 1
          - name: accuracy @ top5
            type: accuracy
            top_k: 5
'''

def configure(i):
    ck=i['ck_kernel']
    deps=i['deps']

    model_env = deps['model-source']['dict']['env']
    [ mean_r, mean_g, mean_b ] = [ int(float(mean_str)+0.5) for mean_str in model_env['ML_MODEL_GIVEN_CHANNEL_MEANS'].split() ]
 
    aux_env = deps['imagenet-aux']['dict']['env']
    val_env = deps['imagenet-val']['dict']['env']

    return template % {
        "name"            : model_env['CK_ENV_TENSORFLOW_MODEL_NAME'],
        "tf_model"        : model_env['CK_ENV_TENSORFLOW_MODEL_TF_FROZEN_FILEPATH'],
        "output"          : model_env['CK_ENV_TENSORFLOW_MODEL_OUTPUT_LAYER_NAME'],
        "batch_size"      : 1,
        "height"          : int(model_env['CK_ENV_TENSORFLOW_MODEL_IMAGE_HEIGHT']),
        "width"           : int(model_env['CK_ENV_TENSORFLOW_MODEL_IMAGE_HEIGHT']),
        "channels"        : 3,
        "mean_r"          : mean_r,
        "mean_g"          : mean_g,
        "mean_b"          : mean_b,
        "data_source"     : val_env['CK_ENV_DATASET_IMAGENET_VAL'],
        "labels_file"     : aux_env['CK_CAFFE_IMAGENET_SYNSET_WORDS_TXT'],
        "annotation_file" : aux_env['CK_CAFFE_IMAGENET_VAL_TXT']
    }

################################################################################
# customize installation
def setup(i):
    """
    Input:  {
              cfg              - meta of this soft entry
              self_cfg         - meta of module soft
              ck_kernel        - import CK kernel module (to reuse functions)

              host_os_uoa      - host OS UOA
              host_os_uid      - host OS UID
              host_os_dict     - host OS meta

              target_os_uoa    - target OS UOA
              target_os_uid    - target OS UID
              target_os_dict   - target OS meta

              target_device_id - target device ID (if via ADB)

              tags             - list of tags used to search this entry

              env              - updated environment vars from meta
              customize        - updated customize vars from meta

              deps             - resolved dependencies for this soft

              interactive      - if 'yes', can ask questions, otherwise quiet

              path             - path to entry (with scripts)
              install_path     - installation path
            }

    Output: {
              return        - return code =  0, if successful
                                          >  0, if error
              (error)       - error text if return > 0
              (install-env) - prepare environment to be used before the install script
            }

    """

    import os
    import shutil

    # Get variables
    o=i.get('out','')

    ck=i['ck_kernel']

    hos=i['host_os_uoa']
    tos=i['target_os_uoa']

    hosd=i['host_os_dict']
    tosd=i['target_os_dict']

    hname=hosd.get('ck_name','')    # win, linux
    hname2=hosd.get('ck_name2','')  # win, mingw, linux, android
    macos=hosd.get('macos','')      # yes/no

    tname=tosd.get('ck_name','')    # win, linux
    tname2=tosd.get('ck_name2','')  # win, mingw, linux, android

    p=i['path']

    pi=i.get('install_path','')
    ck.out('INSTALL_PATH='+pi)

    config_file = configure(i)
    ck.out(config_file)

    with open("config.yml", "w") as config_yml:
        config_yml.write(config_file)
    
    return {'return':0}
