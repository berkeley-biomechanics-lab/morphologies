#######################################################################################
# Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
# Engineering - Etchverry 2162
#
# File: mainAnalysis.py
# Author: Yousuf Abubakr
# Project: Morphologies
# Last Updated: 1-2-2026
#
# Description: main pipeline for accessing, computing, and visualizing summary 
# statistics across control and kyphotic experimental groups
#
#######################################################################################

import os
import sys
import spm1d
import subprocess
import loadSummaryData

import numpy as np
import matplotlib.pyplot as plt

from scipy.io import loadmat
from runSPM1D import runSPM1D

## IMPORTING SUMMARY DATA ##
# Loading summary data from MATLAB into Python formatting via 'loadSummaryData.py'
# which outputs the following sets of variables:
#       Yc{struc}{axis}
#       Yk{struc}{axis}
#       X{struc}{axis}, 
#           --> where {struc} = {Vert, Disc} and {axis} = {LAT, AP, Vol, Z} which fully
#                           characterizes the measurement arrays
#           --> for example, YcVertZ = (control, vertebra, CSA, Z-axis)
# Variable can be accessed like so: loadSummaryData.Yc{struc}{axis}

## SPM ANALYSIS ##
# Running continuous two-sample t-tests and plotting results

runSPM1D(
    Yc=loadSummaryData.YcVertAP,
    Yk=loadSummaryData.YkVertAP,
    X=loadSummaryData.XVertAP,
    title="Height (AP) - Vertebra"
)

