# [Collective Knowledge](http://cknowledge.org) workflows for [OpenVINO](https://01.org/openvinotoolkit) toolkit

## MLPerf Inference v0.5 demo

Download and run a [Docker image](https://hub.docker.com/repository/docker/ctuning/mlperf-inference-v0.5.openvino) built from reusable CK components:

```bash
$ docker pull ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04
$ docker run  ctuning/mlperf-inference-v0.5.openvino:ubuntu-18.04
...
accuracy=75.600%, good=378, total=500
```

The [source Dockerfile](https://github.com/ctuning/ck-mlperf/blob/master/docker/mlperf-inference-v0.5.openvino/Dockerfile.ubuntu-18.04) should be self-explanatory.

Contact info@dividiti.com for more information.
