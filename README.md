# Morphologies
**Author:** Yousuf Abubakr ([yousufabubakr123@berkeley.edu](yousufabubakr123@berkeley.edu))

**Lab:** Grace D. O’Connell Lab ([https://oconnell.berkeley.edu/](https://oconnell.berkeley.edu/))

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
 ┣ 📂results
 ┣ 📂source-code
 ┃ ┣ 📂analysis
 ┃ ┣ 📂disc
 ┃ ┣ 📂utils
 ┃ ┣ 📂vertebra
 ┣ 📂stl-geometries
 ┃ ┣ 📂disc-stls
 ┃ ┃ ┣ 📂Subject A
 ┃ ┃ ┃ ┣ 📜L1-L2.stl
 ┃ ┃ ┃ ┣ 📜L2-L3.stl
 ┃ ┃ ┃ ┣ ...
 ┃ ┣ 📂vertebra-stls
 ┃ ┃ ┣ 📂Subject A
 ┃ ┃ ┃ ┣ 📜L1.stl
 ┃ ┃ ┃ ┣ 📜L2.stl
 ┃ ┃ ┃ ┣ ...
 ┣ 📜.gitattributes
 ┗ 📜README.md
```
