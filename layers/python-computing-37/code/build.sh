#!/usr/bin/env bash

PY_MAJOR_VER=3
PY_MINOR_VER=7

yum -y install python${PY_MAJOR_VER}${PY_MINOR_VER} zip || exit 1
python3 -m venv python || exit 2
source python/bin/activate || exit 3
pip3 install matplotlib || exit 4
deactivate || exit 5
# to not package numpy with this zip, add 'numpy*' in the list at the end of the next line
rm -rf python/{bin,include,lib64,pyvenv.cfg} python/lib/python${PY_MAJOR_VER}.${PY_MINOR_VER}/site-packages/{__pycache__,easy_install.py,pip*,pkg_resources,setuptools*}
zip -r /build/layer.zip python || exit 6