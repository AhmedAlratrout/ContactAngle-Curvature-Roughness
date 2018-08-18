<img align="right" width="40%" height="40%" src="https://github.com/AhmedAlratrout/ContactAngle-Curvature-Roughness/blob/master/docs/Fig2.png"/>

# ContactAngle-Curvature-Roughness
Automatic measurements of contact angle, interfacial curvature and surface roughness in pore-scale 3D-images

## Summary
This document presents the implementation of codes and scripts and the instructions for using them to run the automatic measurements of contact angle, fluid/fluid interface curvature and solid surface roughness applied on segmented 3D pore-space images. This package, when installed, performs surface extraction between contact phases, smoothing the extracted surface, measuring the distributions of contact angle, fluid/fluid interface curvature and solid roughness.

# Installation

## Prerequisites
You should have official OpenFOAM (version 1612+ in this document: https://www.openfoam.com/releases/openfoam-v1612+) installed in your Linux machine. Paraview should be installed for visualization, preferably through system provided packages.

## Downloading and extracting files
Create a directory in your home (`~`) folder named "works" and extract/download the codes inside it in a folder named apps. You can choose any other folder and the scripts will work, but this ducument assumes you install the codes in "`~/works/apps`" folder.

To clone and unzip this repo
```bash
git clone https://github.com/AhmedAlratrout/ContactAngle-Curvature-Roughness
tar -zxvf contactAngle.tar.gz
cd contactAngle
```

To check that the directories are created correctly, type in a terminal:

```  {.bash language="bash"}
#  Important: replace ~/works/apps with the 
#  directory in which you have extracted the codes 
ls   ~/works/apps/scripts   ~/works/apps/contactAngle/voxelImage
```

and it should not show the error message "`No such file or directory`".

## Compiling the codes
Edit the [`~/works/apps/contactAngle/bashrc`](../contactAngle/bashrc) file making sure it sources
the OpenFOAM-1612+/etc/bashrc file based on your OpenFOAM installation
directories.

The mesh generation code requires a recent C++
compiler, you can set it either in the `voxelImage/Makefile` or by
setting the variable `CXX` in file `~/works/apps/bashrc`. The default
(g++) may work and hence you don't need to do any change.

Then open a terminal and type the following commands to compile the
codes:

```  {.bash language="bash"}
(cd ~/works/apps/contactAngle && ./AllMake) 
``` 

Setting the Environmental variables:
------------------------------------

Add the following line to your `~/.bashrc` file (optional but
recomended),

```  {.bash language="bash"}
source ~/works/apps/contactAngle/bashrc
``` 

This makes the contact angle and roughness scripts available in any new terminal you open.


# Usage

## Input file format

The following required input files are provided in `docs/Example`:

1.  Segmented dataset from 3D multiphase images (i.e. Micro-CT) should be given in ascii (suffix should be `.dat`)
    or binary files (better to have `.raw` suffix, the data should be in
    8bit unsigned char). For contact angle and oil/brine interface curvature - the voxel values of the segmented phases are required to be in the following: oil = 2, rock (solid) = 1 and brine = 0. The contact angle is measured through the brine phase (voxel value = 0). An example is provided in `docs/Example/Carbonate1_WW.raw`, which is a binary segmented image cropped from Sample-1 image available on Digital Rocks Portal website:
<https://www.digitalrocksportal.org/projects/151>. For measuring roughness - it is required to be applied on dry images (contain solid phase only). The voxel values of the segmented dry image should be solid = 1 and brine (or air) = 0.
    
2.  Input header file: to declare the number of voxels in the three dimensions (x, y and z), the voxel dimensions (x, y and z) in microns and the offset distance (0 0 0 for no shifting). Rename the header file as the image file.

3.  A sub-directory called `system` to comply with the basic directory structure for an OpenFOAM case. Make sure that there are two files (`controlDict` file and `meshingDict` file) in the system folder that contain the setting parameters.
Note: the `controlDict` file is where run control parameters are set including start/end time. The `meshingDict` file is where the input and output files in each step of the algorithm is specified.

## Running the contact angle and fluid/fluid interface curvature code

Open a terminal and type the following to run the code:

```  {.bash language="bash"}
voxelToSurfaceML && surfaceAddLayerToCL && surfaceSmoothVP && more contactAngles.txt >>Kc.txt && more Kc.txt >> *_Layered_Smooth.vtk
``` 

This command will execute the following:

1.  Extract the surface (multi-zone mesh _M_).
Note: Mesh _M_ is divided into three face-zones: **z**<sub>1</sub> represents the oil/rock interface, **z**<sub>2</sub> is the oil/brine interface and **z**<sub>3</sub> is the brine/rock interface in an oil-brine system. All vertices are given a label i. The set of vertices that belong to each zone will be denoted as _V_<sub>_OR_</sub>, _V_<sub>_OB_</sub> and _V_<sub>_BR_</sub> respectively. _V_<sub>_CL_</sub> is the set of vertices which are shared by all three face-zones representing the three-phase contact line. The name of the output file here (\*.vtk) is specified.

2. Add a “layer” near the three-phase contact line.
Note: Here the extracted file from the previous step is used as an input file (\*.vtk) and the name of the output file (\*\_Layered.vtk) is specified. Each vertex in the contact line set (i ∈ _V_<sub>_CL_</sub>) is constrained to have a single edge connection with a neighboring vertex of each zone.

3. Smooth the surface and curvature measurement.
Note: In this step, the output file from the previous step (\*\_Layered.vtk) is used as an input mesh to apply the smoothing algorithm. The name of the smoothed output file (\*\_Layered\_Smooth.vtk) is specified. In this step, a volume-preserving Gaussian smoothing is applied on mesh _M_, and then a volume-preserving curvature uniform smoothing is applied, which is consistent with capillary equilibrium. Two output files (Kc_x.txt and Kc.txt) are specified. The file Kc_x.txt contains the curvature values of the vertices belonging to the oil/brine interface (_i_ ∈ _V_<sub>_OB_</sub>) and their spatial location coordinates.

4. Contact angle measurement.
Note: The contact angle is computed on each vertex that belongs to the contact line set, i ∈ _V_<sub>_CL_</sub>. The contact angle (\theta <sub>_i_</sub>)for each vertex is calculated through the brine phase by:
<!-- \theta_i = \pi - \acos (\textbf{n}_i|_{\textbf{z}_2} \cdot \textbf{n}_i|_{\textbf{z}_3}),   i \in V_{CL} -->
<img src="http://latex.codecogs.com/svg.latex?\theta_i=\pi-\cos^{-1}(\textbf{n}_i|_{\textbf{z}_2}\cdot\textbf{n}_i|_{\textbf{z}_3}),$\quad$i$\in$V_{_{CL}}" border="0"/>
The normal vectors are computed on the vertices comprising the contact line, i ∈ _V_<sub>_CL_</sub>. Each vertex is represented with two vectors normal to the oil/brine interface (**z**<sub>2</sub>) and the brine/rock interface (**z**<sub>3</sub>), as shown in abstract figure.

## Running the surface roughness code

Open a terminal and type the following to run the code:

```  {.bash language="bash"}
voxelToSurfaceML && surfaceRoughness && more Ra.txt >> *_Smooth_Roughness.vtk

``` 

This command will execute the following:

1.  Extract the surface (single-zone mesh _S_).
Note: Mesh _S_ is a single face-zone mesh that represents the rock surface only. For best results, it is better to apply this code on dry images (contain solid phase only).

## Visualization
The generated files: surface (\*.vtk), layered surface (\*\_Layered.vtk) and smoothed surfcae (\*\_Layered\_Smooth.vtk). These files can be visualized using three-dimensional image visualization software (in this work Paraview software was used), as demonstrated in the abstract figure.

