# [Collective Knowledge](http://cknowledge.org) workflows for [OpenVINO](https://01.org/openvinotoolkit) toolkit

**All CK components for AI and ML are now collected in [one repository](https://github.com/ctuning/ai)!**

## MLPerf Inference v0.5 demo

Download and run a [Docker image](https://hub.docker.com/r/ctuning/mlperf-inference-v0.5.openvino) built from reusable CK components:

```bash
$ docker pull ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04
$ docker run  ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04
...
accuracy=75.600%, good=378, total=500
```

The [source Dockerfile](https://github.com/ctuning/ck-mlperf/blob/master/docker/mlperf-inference-v0.5.openvino/Dockerfile.ubuntu-18.04) should be self-explanatory.

Contact info@dividiti.com for more information.


## Benchmarking quantized SSD-MobileNet

We compare performance for the symmetrically quantized SSD-MobileNet-v1 model 
on a HP Z640 G1X62EA workstation with ten-core Intel Xeon CPU E5-2650 v3 @ 2.30GHz using:
- [OpenVINO](#openvino) ([pre-release](https://github.com/mlperf/inference_results_v0.5/issues/27#issuecomment-617844245));
- MKL-optimized [TensorFlow 2.0](#tf_2_0);
- MKL-optimized (?) [TensorFlow 2.1](#tf_2_1).

<a name="openvino"></a>
### OpenVINO

```
$ docker pull ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04
```

#### Accuracy on the COCO 2017 validation set

```bash
$ export NPROCS=`grep -c processor /proc/cpuinfo` && docker run --rm ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04 \
  "ck run ck-openvino:program:mlperf-inference-v0.5 --cmd_key=object-detection --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE=Accuracy --env.CK_LOADGEN_DATASET_SIZE=5000 \
  --env.CK_OPENVINO_NTHREADS=$NPROCS --env.CK_OPENVINO_NSTREAMS=$NPROCS --env.CK_OPENVINO_NIREQ=$NPROCS \
  && cat /home/dvdt/CK_REPOS/ck-openvino/program/mlperf-inference-v0.5/tmp/accuracy.txt"
...
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.226
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.347
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.246
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.018
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.158
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.520
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.205
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.257
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.258
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.023
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.183
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.594
mAP=22.617%
```

#### Performance (with all virtual CPU cores)

```bash
$ export NPROCS=`grep -c processor /proc/cpuinfo` && docker run --rm ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04 \
  "ck run ck-openvino:program:mlperf-inference-v0.5 --cmd_key=object-detection --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE=Performance --env.CK_LOADGEN_TARGET_QPS=7 \
  --env.CK_OPENVINO_NTHREADS=$NPROCS --env.CK_OPENVINO_NSTREAMS=$NPROCS --env.CK_OPENVINO_NIREQ=$NPROCS \
  && echo '--------------------------------------------------------------------------------' \
  && echo 'mlperf_log_summary.txt' \
  && echo '--------------------------------------------------------------------------------' \
  && cat  /home/dvdt/CK_REPOS/ck-openvino/program/mlperf-inference-v0.5/tmp/mlperf_log_summary.txt \
  && echo '--------------------------------------------------------------------------------'" 
...
================================================
MLPerf Results Summary
================================================
SUT name : SUT
Scenario : Offline
Mode     : Performance
Samples per second: 260.554
Result is : INVALID
  Min duration satisfied : NO
  Min queries satisfied : Yes
Recommendations:
 * Increase expected QPS so the loadgen pre-generates a larger (coalesced) query.
```

(We set `CK_LOADGEN_TARGET_QPS=7` to workaround a [known issue](https://github.com/ctuning/ck-openvino/issues/10) with Intel's code leading to a segfault.)

#### Performance (with all physical CPU cores)

```bash
$ export NPROCS=$((`grep -c processor /proc/cpuinfo` / 2)) && docker run --rm ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04 \
  "ck run ck-openvino:program:mlperf-inference-v0.5 --cmd_key=object-detection --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE=Performance --env.CK_LOADGEN_TARGET_QPS=7 \
  --env.CK_OPENVINO_NTHREADS=$NPROCS --env.CK_OPENVINO_NSTREAMS=$NPROCS --env.CK_OPENVINO_NIREQ=$NPROCS \
  && echo '--------------------------------------------------------------------------------' \
  && echo 'mlperf_log_summary.txt' \
  && echo '--------------------------------------------------------------------------------' \
  && cat  /home/dvdt/CK_REPOS/ck-openvino/program/mlperf-inference-v0.5/tmp/mlperf_log_summary.txt \
  && echo '--------------------------------------------------------------------------------'" 
...
================================================
MLPerf Results Summary
================================================
SUT name : SUT
Scenario : Offline
Mode     : Performance
Samples per second: 235.173
Result is : INVALID
  Min duration satisfied : NO
  Min queries satisfied : Yes
Recommendations:
 * Increase expected QPS so the loadgen pre-generates a larger (coalesced) query.
```

<a name="tf_2_0"></a>
### MKL-optimized TensorFlow 2.0

```bash
$ docker pull ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.0.1-mkl-py3
```

#### Accuracy on the COCO 2017 validation set

```bash
$ export NPROCS=$((`grep -c processor /proc/cpuinfo` / 2)) && \
  docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.0.1-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='--accuracy' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 5000 --max-batchsize 1' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized"
  --env.KMP_SETTINGS=1 --env.KMP_BLOCKTIME=1 --env.KMP_AFFINITY='granularity=fine,compact,1,0' \
  --env.OMP_NUM_THREADS=$NPROCS"
...
INFO:main:Namespace(accuracy=True, backend='tensorflow', backend_params='BATCH_SIZE:1,TENSORRT_PRECISION:FP32,TENSORRT_DYNAMIC:0', cache=0, config='/home/dvdt/CK_TOOLS/mlperf-inference-upstream.master/inference/v0.5/mlperf.conf', count=5000, data_format=None, dataset='coco-standard', dataset_height=300, dataset_list=None, dataset_path='/home/dvdt/CK_TOOLS/dataset-coco-2017-val', dataset_width=300, find_peak_performance=False, inputs=['image_tensor:0'], max_batchsize=1, max_latency=None, model='/home/dvdt/CK_TOOLS/model-tf-mlperf-ssd-mobilenet-quantized-finetuned/graph.pb', model_name='${CK_ENV_TENSORFLOW_MODEL_MODEL_NAME}', output=None, outputs=['num_detections:0', 'detection_boxes:0', 'detection_scores:0', 'detection_classes:0'], profile='default_tf_object_det_zoo', qps=None, samples_per_query=None, scenario='Offline', threads=20, time=None)
INFO:coco:loaded 5000 images, cache=0, took=38.3sec
2020-06-04 12:18:32.395924: I tensorflow/core/platform/cpu_feature_guard.cc:145] This TensorFlow binary is optimized with Intel(R) MKL-DNN to use the following CPU instructions in performance critical operations:  AVX2 FMA
To enable them in non-MKL-DNN operations, rebuild TensorFlow with the appropriate compiler flags.
2020-06-04 12:18:32.402349: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 12:18:32.403571: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x5158100 executing computations on platform Host. Devices:
2020-06-04 12:18:32.403589: I tensorflow/compiler/xla/service/service.cc:175]   StreamExecutor device (0): Host, Default Version
2020-06-04 12:18:32.404598: I tensorflow/core/common_runtime/process_util.cc:115] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
...
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.235
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.362
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.257
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.019
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.166
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.545
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.212
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.267
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.268
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.024
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.191
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.617
TestScenario.Offline qps=123.63, mean=4.3781, time=40.444, acc=94.0344%, mAP=23.538530905017076%, queries=5000, tiles=50.0:4.5576,80.0:5.4431,90.0:5.6411,95.0:5.7654,99.0:6.0230,99.9:6.2053
```

#### Performance with the default parameters

```bash
$ docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.0.1-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 462' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized"
...
2020-06-04 11:44:44.287762: I tensorflow/core/platform/cpu_feature_guard.cc:145] This TensorFlow binary is optimized with Intel(R) MKL-DNN to use the following CPU instructions in performance critical operations:  AVX2 FMA
To enable them in non-MKL-DNN operations, rebuild TensorFlow with the appropriate compiler flags.
2020-06-04 11:44:44.294142: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 11:44:44.295588: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x8474510 executing computations on platform Host. Devices:
2020-06-04 11:44:44.295606: I tensorflow/compiler/xla/service/service.cc:175]   StreamExecutor device (0): Host, Default Version
2020-06-04 11:44:44.296235: I tensorflow/core/common_runtime/process_util.cc:115] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
TestScenario.Offline qps=26.31, mean=10.1521, time=17.561, queries=462, tiles=50.0:9.7158,80.0:16.2235,90.0:16.3415,95.0:17.5336,99.0:17.5336,99.9:17.5336
```

#### Performance with all virtual CPU cores

```bash
$ export NPROCS=`grep -c processor /proc/cpuinfo` && \
  docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.0.1-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 462' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized \
  --env.KMP_SETTINGS=1 --env.KMP_BLOCKTIME=1 --env.KMP_AFFINITY='granularity=fine,compact,1,0' \
  --env.OMP_NUM_THREADS=$NPROCS"
...
2020-06-04 11:55:31.771622: I tensorflow/core/platform/cpu_feature_guard.cc:145] This TensorFlow binary is optimized with Intel(R) MKL-DNN to use the following CPU instructions in performance critical operations:  AVX2 FMA
To enable them in non-MKL-DNN operations, rebuild TensorFlow with the appropriate compiler flags.

User settings:

   KMP_AFFINITY=granularity=fine,compact,1,0
   KMP_BLOCKTIME=1
   KMP_SETTINGS=1
   OMP_NUM_THREADS=20
...
2020-06-04 11:55:31.778172: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 11:55:31.779562: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x846b2b0 executing computations on platform Host. Devices:
2020-06-04 11:55:31.779580: I tensorflow/compiler/xla/service/service.cc:175]   StreamExecutor device (0): Host, Default Version
2020-06-04 11:55:31.780533: I tensorflow/core/common_runtime/process_util.cc:115] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
TestScenario.Offline qps=34.74, mean=7.6564, time=13.300, queries=462, tiles=50.0:7.4600,80.0:11.9973,90.0:12.9363,95.0:13.2779,99.0:13.2779,99.9:13.2779
```

#### Performance with all physical CPU cores

```bash
$ export NPROCS=$((`grep -c processor /proc/cpuinfo` / 2)) && \
  docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.0.1-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 462' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized \
  --env.KMP_SETTINGS=1 --env.KMP_BLOCKTIME=1 --env.KMP_AFFINITY='granularity=fine,compact,1,0' \
  --env.OMP_NUM_THREADS=$NPROCS"
...
2020-06-04 11:52:06.230481: I tensorflow/core/platform/cpu_feature_guard.cc:145] This TensorFlow binary is optimized with Intel(R) MKL-DNN to use the following CPU instructions in performance critical operations:  AVX2 FMA
To enable them in non-MKL-DNN operations, rebuild TensorFlow with the appropriate compiler flags.

User settings:

   KMP_AFFINITY=granularity=fine,compact,1,0
   KMP_BLOCKTIME=1
   KMP_SETTINGS=1
   OMP_NUM_THREADS=10
...
2020-06-04 11:52:06.237142: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 11:52:06.238523: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x7f15070 executing computations on platform Host. Devices:
2020-06-04 11:52:06.238551: I tensorflow/compiler/xla/service/service.cc:175]   StreamExecutor device (0): Host, Default Version
2020-06-04 11:52:06.239762: I tensorflow/core/common_runtime/process_util.cc:115] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
TestScenario.Offline qps=44.04, mean=6.1680, time=10.490, queries=462, tiles=50.0:6.0186,80.0:9.5817,90.0:10.2260,95.0:10.4660,99.0:10.4660,99.9:10.4660
```

<a name="tf_2_1"></a>
### MKL-optimized (?) TensorFlow 2.1

```bash
$ docker pull ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.1.0-mkl-py3
```

#### Accuracy on the COCO 2017 validation set

```bash
$ export NPROCS=$((`grep -c processor /proc/cpuinfo` / 2)) && \
  docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.1.0-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='--accuracy' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 5000 --max-batchsize 1' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized"
  --env.KMP_SETTINGS=1 --env.KMP_BLOCKTIME=1 --env.KMP_AFFINITY='granularity=fine,compact,1,0' \
  --env.OMP_NUM_THREADS=$NPROCS"
...
INFO:main:Namespace(accuracy=True, backend='tensorflow', backend_params='BATCH_SIZE:1,TENSORRT_PRECISION:FP32,TENSORRT_DYNAMIC:0', cache=0, config='/home/dvdt/CK_TOOLS/mlperf-inference-upstream.master/inference/v0.5/mlperf.conf', count=5000, data_format=None, dataset='coco-standard', dataset_height=300, dataset_list=None, dataset_path='/home/dvdt/CK_TOOLS/dataset-coco-2017-val', dataset_width=300, find_peak_performance=False, inputs=['image_tensor:0'], max_batchsize=1, max_latency=None, model='/home/dvdt/CK_TOOLS/model-tf-mlperf-ssd-mobilenet-quantized-finetuned/graph.pb', model_name='${CK_ENV_TENSORFLOW_MODEL_MODEL_NAME}', output=None, outputs=['num_detections:0', 'detection_boxes:0', 'detection_scores:0', 'detection_classes:0'], profile='default_tf_object_det_zoo', qps=None, samples_per_query=None, scenario='Offline', threads=20, time=None)
INFO:coco:loaded 5000 images, cache=0, took=93.7sec
2020-06-04 13:07:12.428599: I tensorflow/core/platform/cpu_feature_guard.cc:142] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
2020-06-04 13:07:13.269997: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 13:07:13.282636: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x8ec4570 initialized for platform Host (this does not guarantee that XLA will be used). Devices:
2020-06-04 13:07:13.282681: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Host, Default Version
2020-06-04 13:07:13.294754: I tensorflow/core/common_runtime/process_util.cc:147] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
...
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.236
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.362
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.258
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.019
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.166
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.544
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.212
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.267
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.268
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.025
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.191
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.618
TestScenario.Offline qps=129.41, mean=4.1776, time=38.637, acc=94.0231%, mAP=23.566332815709149%, queries=5000, tiles=50.0:4.2399,80.0:5.2161,90.0:5.4090,95.0:5.5132,99.0:5.6607,99.9:5.7809
```

#### Performance with the default parameters

```bash
$ docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.1.0-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 462' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized"
...
2020-06-04 13:14:03.208913: I tensorflow/core/platform/cpu_feature_guard.cc:142] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
2020-06-04 13:14:03.215571: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 13:14:03.216924: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x43f0270 initialized for platform Host (this does not guarantee that XLA will be used). Devices:
2020-06-04 13:14:03.216942: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Host, Default Version
2020-06-04 13:14:03.217047: I tensorflow/core/common_runtime/process_util.cc:147] Creating new thread pool with default inter op setting: 2. Tune using inter_op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
TestScenario.Offline qps=26.05, mean=10.1722, time=17.736, queries=462, tiles=50.0:10.3504,80.0:15.4264,90.0:17.6162,95.0:17.7094,99.0:17.7094,99.9:17.7094
```

#### Performance with all virtual CPU cores

```bash
$ export NPROCS=`grep -c processor /proc/cpuinfo` && \
  docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.1.0-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 462' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized \
  --env.KMP_SETTINGS=1 --env.KMP_BLOCKTIME=1 --env.KMP_AFFINITY='granularity=fine,compact,1,0' \
  --env.OMP_NUM_THREADS=$NPROCS"
...
2020-06-04 13:15:27.034484: I tensorflow/core/platform/cpu_feature_guard.cc:142] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA

User settings:

   KMP_AFFINITY=granularity=fine,compact,1,0
   KMP_BLOCKTIME=1
   KMP_SETTINGS=1
   OMP_NUM_THREADS=20
...
2020-06-04 13:15:27.041504: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 13:15:27.043613: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x7a66ab0 initialized for platform Host (this does not guarantee tha
t XLA will be used). Devices:
2020-06-04 13:15:27.043649: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Host, Default Version
2020-06-04 13:15:27.043776: I tensorflow/core/common_runtime/process_util.cc:147] Creating new thread pool with default inter op setting: 2. Tune using inter_
op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
TestScenario.Offline qps=33.82, mean=8.0507, time=13.659, queries=462, tiles=50.0:7.9636,80.0:12.4265,90.0:13.3861,95.0:13.6354,99.0:13.6354,99.9:13.6354
```

#### Performance with all physical CPU cores

```bash
$ export NPROCS=$((`grep -c processor /proc/cpuinfo` / 2)) && \
  docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.1.0-mkl-py3 \
  "ck run program:mlperf-inference-vision --cmd_key=direct --skip_print_timers \
  --env.CK_LOADGEN_SCENARIO=Offline --env.CK_LOADGEN_MODE='' \
  --env.CK_LOADGEN_EXTRA_PARAMS='--count 462' \
  --env.CK_LOADGEN_REF_PROFILE=default_tf_object_det_zoo \
  --dep_add_tags.weights=ssd,mobilenet-v1,mlperf,quantized \
  --env.KMP_SETTINGS=1 --env.KMP_BLOCKTIME=1 --env.KMP_AFFINITY='granularity=fine,compact,1,0' \
  --env.OMP_NUM_THREADS=$NPROCS"
...
2020-06-04 13:16:54.080275: I tensorflow/core/platform/cpu_feature_guard.cc:142] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA

User settings:

   KMP_AFFINITY=granularity=fine,compact,1,0
   KMP_BLOCKTIME=1
   KMP_SETTINGS=1
   OMP_NUM_THREADS=10
...
2020-06-04 13:16:54.087292: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2294550000 Hz
2020-06-04 13:16:54.088427: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x6765560 initialized for platform Host (this does not guarantee tha
t XLA will be used). Devices:
2020-06-04 13:16:54.088444: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Host, Default Version
2020-06-04 13:16:54.088520: I tensorflow/core/common_runtime/process_util.cc:147] Creating new thread pool with default inter op setting: 2. Tune using inter_
op_parallelism_threads for best performance.
INFO:main:starting TestScenario.Offline
TestScenario.Offline qps=44.26, mean=6.1474, time=10.438, queries=462, tiles=50.0:6.0423,80.0:9.4969,90.0:10.1914,95.0:10.4173,99.0:10.4173,99.9:10.4173
```

**NB:** Note that the performance with the `2.1.0-mkl-py3`-based image is the same as with the `2.0.1-mkl-py3`-based image despite the scary message:
> Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA

MKL is actually enabled, as can be confirmed by running:
```bash
$ docker run ctuning/mlperf-inference-vision-with-ck.intel.ubuntu-18.04:2.1.0-mkl-py3 \
"python -c 'from tensorflow.python import _pywrap_util_port; print(_pywrap_util_port.IsMklEnabled())'"
True
```
