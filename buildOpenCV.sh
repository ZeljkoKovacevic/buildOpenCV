#!/bin/bash

OPENCV_VERSION=4.1.1

WHEREAMI=$PWD
# NUM_JOBS is the number of jobs to run simultaneously when using make
# This will default to the number of CPU cores (on the Nano, that's 4)
# If you are using a SD card, you may want to change this
# to 1. Also, you may want to increase the size of your swap file
NUM_JOBS=$(nproc)


git clone --branch "$OPENCV_VERSION" https://github.com/opencv/opencv.git
git clone --branch "$OPENCV_VERSION" https://github.com/opencv/opencv_contrib.git

cd opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D INSTALL_C_EXAMPLES=OFF \
-D PYTHON_EXECUTABLE=$(which python3) \
-D BUILD_opencv_python2=OFF \
-D CMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
-D PYTHON3_EXECUTABLE=$(which python3) \
-D PYTHON3_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
-D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
-D WITH_GSTREAMER=ON \
-D WITH_CUDA=ON \
-D BUILD_opencv_python3=ON \
-D CUDA_FAST_MATH=ON \
-D WITH_CUBLAS=ON \
-D WITH_LIBV4L=ON \
-D WITH_V4L=ON \
-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
-D BUILD_EXAMPLES=OFF ..

if [ $? -eq 0 ] ; then
  echo "CMake configuration make successful"
else
  # Try to make again
  echo "CMake issues " >&2
  echo "Please check the configuration being used"
  exit 1
fi


make -j$(nproc)

if [ $? -eq 0 ] ; then
  echo "OpenCV make successful"
else
  # Try to make again
  echo "Make did not successfully build" >&2
  echo "Please fix issues and retry build"
  exit 1
fi

make install
ldconfig

if [ $? -eq 0 ] ; then
   echo "OpenCV installed"
else
   echo "There was an issue with the final installation"
   exit 1
fi

echo $(python3 -c "import cv2 ; print( cv2.getBuildInformation())")
