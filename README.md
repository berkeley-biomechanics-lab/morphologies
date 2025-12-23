# Morphologies
**Author:** Yousuf Abubakr (yousufabubakr123@berkeley.edu)

**Lab:** Grace O’Connell Biomechnics Lab ([https://oconnell.berkeley.edu/](https://oconnell.berkeley.edu/))

**Description:** A toolkit for processing, analyzing, and visualizing morphological data from medical imaging datasets (e.g., STL meshes, MATLAB measurement files).

<br/>

## Overview
This repository contains scripts, data, and utilities for reconstructing, cleaning, and measuring vertebral and disc morphologies.
It includes:
- Measurement extraction (MATLAB .mat files)
- Visualization scripts
- Reproducible workflows for morphological analysis

## Motivation
Morphological analysis of vertebrae and discs requires consistent, reproducible pipelines. This project organizes those pipelines into a structured, maintainable framework for personal research and future extensions.

## Getting Started
Clone the repo
```
git clone https://github.com/YousufAbubakr/morphologies.git
```

## Repository Setup
```
📦morphoogies                
 ┣ 📂results                 ← output files, figures, exported meshes, etc.
 ┣ 📂src                     ← utility, analysis, and vertebrae/disc codes
 ┃ ┣ 📂analysis
 ┃ ┣ 📂disc-utils            ← utility functions related to disc morphology processing
 ┃ ┣ 📂gen-utils             ← utility functions related to general processing
 ┃ ┣ 📂vert-utils            ← utility functions related to vertebra morphology processing
 ┃ ┣ 📜main.m                ← end-to-end workflow program for processing vertebral and disc morphology data
 ┣ 📂stl-geometries          ← source .stl geometry data
 ┃ ┣ 📂disc-stls             ← automated disc construction process in pipeline
 ┃ ┃ ┣ 📂Subject A
 ┃ ┃ ┃ ┣ 📜L1-L2.stl
 ┃ ┃ ┃ ┣ 📜L2-L3.stl
 ┃ ┃ ┃ ┣ ...
 ┃ ┣ 📂vertebra-stls         ← imported from manual 3D slicer segmentations
 ┃ ┃ ┣ 📂Subject A
 ┃ ┃ ┃ ┣ 📜L1.stl
 ┃ ┃ ┃ ┣ 📜L2.stl
 ┃ ┃ ┃ ┣ ...
 ┣ 📜.gitattributes          ← to ignore large / binary / generated files
 ┗ 📜README.md               ← project overview, how to run, etc.
```

## Notes to Consider
This repository is almost entirely self-contained in that all the files required for this workflow are located inside of these folders. The only files that aren't included are the 3D Slicer segmentation files that were used to develop the vertebrae geometry stls. These files are of considerable size and are stored elsewhere. Feel free to reach out to Yousuf Abubakr at yousufabubakr123@berkeley.edu if interested in obtaining these files.
