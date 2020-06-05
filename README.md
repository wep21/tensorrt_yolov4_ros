# ROS wrapper for TensorRT YOLOv4

## Referenced repositiory
Please check this repository for detail implementation.
The trained files are provided by the following repository. The trained files are automatically downloaded when you build.

https://github.com/lewes6369/TensorRT-Yolov3

https://github.com/wang-xinyu/tensorrtx

## Trained model
- tranined file (608) :
  https://drive.google.com/drive/folders/1F3f2_CZTOIcuUhvubNaLlMoIx0_Pv6_x?usp=sharing


Please note that above repository is under MIT license.
## How to use
1. Build this package.(Automatically download necessary files during build process)
2. Place trained models in data directory.
3. `roslaunch tensorrt_yolo4 tensorrt_yolo4.launch`

## Interface
### Input topic type
  `sensor_msgs::Image`
### Output topic type
  `autoware_perception_msgs::DynamicObjectWithFeatureArray`
