#!/bin/bash

echo "## added by $0 :" >> ~/.bashrc
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
export PATH=$HOME/.local/bin:$PATH

python3 -m pip install ck --user
python3 -m pip install --ignore-installed pip setuptools --user
python3 -m pip install nibabel pillow progress py-cpuinfo pyyaml shapely sklearn tqdm xmltodict yamlloader --user

ck version
ck pull repo:ck-openvino
ck detect platform.os --platform_init_uoa=generic-linux-dummy

ck detect soft:compiler.gcc --full_path=`which gcc`
ck detect soft:compiler.python --full_path=`which python3`
ck detect soft --tags=cmake --full_path=`which cmake`
ck show env --tags=64bits

ck install package --tags=lib,python-package,tensorflow --force_version=1.15.2
ck install package --tags=lib,python-package,networkx --force_version=2.3.0
ck install package --tags=lib,python-package,defusedxml
ck install package --tags=lib,python-package,cython
ck install package --tags=lib,python-package,numpy
ck install package --tags=lib,python-package,test-generator
ck install package --tags=lib,python-package,absl
ck install package --tags=lib,opencv,v3.4.10
ck install package --tags=lib,boost,v1.67.0 --no_tags=min-for-caffe
ck install package --tags=mlperf,inference,source,dividiti.v0.5-intel
ck install package --tags=lib,loadgen,static
ck install package --tags=lib,openvino,pre-release
ck compile ck-openvino:program:mlperf-inference-v0.5
ck install package --tags=lib,python-package,cv2,opencv-python-headless

ck install package --tags=model,tf,ssd-mobilenet,quantized,for.openvino
ck install package --tags=model,openvino,ssd-mobilenet
echo | ck install package --tags=object-detection,dataset,coco.2017,val,original,full \
	&& ck virtual env --tags=object-detection,dataset,coco.2017,val,original,full --shell_cmd=\
	'rm $CK_ENV_DATASET_COCO_LABELS_DIR/*train2017.json'

ck install package --tags=lib,python-package,matplotlib
ck install package --tags=tool,coco,api

#ck install package --tags=dataset,imagenet,cal,all.500
#ck install package --tags=model,tf,mlperf,resnet --no_tags=ssd
#
#cd /home/dividiti/CK-TOOLS/lib-openvino-gcc-7.5.0-pre-release-linux-64/openvino/inference-engine/bin/intel64/Release/lib/python_api/
#mv python3.6 python3
#
#ck install package --tags=model,openvino,resnet50
#
#head -n 500 `ck locate env --tags=aux`/val.txt > `ck locate env --tags=raw,val`/val_map.txt
#
