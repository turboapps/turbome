# OpenPose

Source: [Github Repository](https://github.com/CMU-Perceptual-Computing-Lab/openpose)

## Build and Run Instructions

To build the CPU version of OpenPose:
`turbo build openpose-cpu\turbo.me`

To build the GPU version of OpenPose:
`turbo build openpose-gpu\turbo.me`

To run a container (works for both CPU and GPU version, just replace the image name after new with the desired image):
`turbo new --mount=C:\path\to\image\dirs openpose-cpu -- --image_dir C:\path\to\image\dirs\input --write_images C:\path\to\image\dirs\output --disable_blending --display 0`

This will run OpenPose, and it will take an image(s) from the specified input image directory and output an image(s) to the specified output directory; the output image contains just the multi-colored pose estimation skeleton on a black background. Output images are named the same as the input image, but with "_rendered" appended to the end of the filename. Output images are .png files by default, but they can be output as .jpg files by adding `--write_images_format jpg` to the arguments when creating a container.

It is possible to make the image input and output directories the same, but if you are running OpenPose more than once with identical input/output directories, be aware that subsequent runs after the first will also do pose estimation on the output image as well, so each subsequent run will add another completely black image to the directory if the output image was left in the directory.

If you get a `Check failed: error == cudaSuccess (2 vs. 0) out of memory` error, try the following: add the `-net_resolution` flag to the container arguments, like `-net_resolution -1x256`. The default value for this that OpenPose uses is -1x368. Both dimensions need to be multiples of 16, and putting -1 as either of the dimensions chooses the optimal aspect ratio based on the input value for the other dimension (for instance, -1x368 becomes 656x358).
