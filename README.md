# photometric-stereo
A MATLAB Implementation of the Basic Photometric Stereo Algorithm

This project implements the basic photometric stereo algorithm that essentially uses the least squares method. Given twelve photometric images and their corresponding light directions, the surface normals are first computed as an overdetermined linear system. Basically, this linear system captures a simple physics relationship: a pixel’s intensity is proportional to the dot product between the light direction and the surface normal at that pixel.

Next, from the surface normals can the height map be solved as another overdetermined system. This second linear system captures the relationship that the surface normal at a pixel is perpendicular to the vector formed by this pixel and its immediate neighbor.

## Results

![](https://raw.githubusercontent.com/xiumingzhang/photometric-stereo/master/results/all1.png)![](https://raw.githubusercontent.com/xiumingzhang/photometric-stereo/master/results/all2.png)

## Example Usage

Just run script `run_ps.m`.

### Acknowledgements

The data is by courtesy of Steven Seitz and available at [here](http://www.cs.washington.edu/education/courses/csep576/05wi/projects/project3/psmImages.zip). Dirk-Jan Kroon holds the copyright of `tga_toolbox`, containing `tga_read_image.m` and `tga_read_header.m`.
