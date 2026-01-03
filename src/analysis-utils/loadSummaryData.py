#######################################################################################
# Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
# Engineering - Etchverry 2162
#
# File: loadSummaryData.py
# Author: Yousuf Abubakr
# Project: Morphologies
# Last Updated: 1-2-2026
#
# Description: loading control and kyphotic experimental summary array variables
# into workspace
#
#######################################################################################

import os
import numpy as np

from scipy.io import loadmat

## IMPORTING SUMMARY DATA ##
# Loading summary data from MATLAB into Python formatting

# Summary data path:
cwd = os.getcwd(); projectDirPath = os.path.dirname(os.path.dirname(cwd))
summaryDirPath = os.path.join(projectDirPath, "data", "summary")

# Setting up summary data file paths:
fileNames = ["discAP.mat", "discLAT.mat", "discVol.mat", "discZ.mat",
             "vertAP.mat", "vertLAT.mat", "vertVol.mat", "vertZ.mat"]
discAPPath = os.path.join(summaryDirPath, fileNames[0])
discLATPath = os.path.join(summaryDirPath, fileNames[1])
discVolPath = os.path.join(summaryDirPath, fileNames[2])
discZPath = os.path.join(summaryDirPath, fileNames[3])

vertAPPath = os.path.join(summaryDirPath, fileNames[4])
vertLATPath = os.path.join(summaryDirPath, fileNames[5])
vertVolPath = os.path.join(summaryDirPath, fileNames[6])
vertZPath = os.path.join(summaryDirPath, fileNames[7])

# Loading morphlogy data with loadmat, disc data -->
discAPData = loadmat(discAPPath)
YcDiscAP = discAPData['Y_control']; YkDiscAP = discAPData['Y_kyphotic']
lvlRangeDiscAP = np.array([e[0] for e in np.concatenate(discAPData['levels']).tolist()])

discLATData = loadmat(discLATPath)
YcDiscLAT = discLATData['Y_control']; YkDiscLAT = discLATData['Y_kyphotic']
lvlRangeDiscLAT = np.array([e[0] for e in np.concatenate(discLATData['levels']).tolist()])

discVolData = loadmat(discVolPath)
YcDiscVol = discVolData['Y_control']; YkDiscVol = discVolData['Y_kyphotic']
lvlRangeDiscVol = np.array([e[0] for e in np.concatenate(discVolData['levels']).tolist()])

discZData = loadmat(discZPath)
YcDiscZ = discZData['Y_control']; YkDiscZ = discZData['Y_kyphotic']
lvlRangeDiscZ = np.array([e[0] for e in np.concatenate(discZData['levels']).tolist()])

# Vertebra data -->
vertAPData = loadmat(vertAPPath)
YcVertAP = vertAPData['Y_control']; YkVertAP = vertAPData['Y_kyphotic']
lvlRangeVertAP = np.array([e[0] for e in np.concatenate(vertAPData['levels']).tolist()])

vertLATData = loadmat(vertLATPath)
YcVertLAT = vertLATData['Y_control']; YkVertLAT = vertLATData['Y_kyphotic']
lvlRangeVertLAT = np.array([e[0] for e in np.concatenate(vertLATData['levels']).tolist()])

vertVolData = loadmat(vertVolPath)
YcVertVol = vertVolData['Y_control']; YkVertVol = vertVolData['Y_kyphotic']
lvlRangeVertVol = np.array([e[0] for e in np.concatenate(vertVolData['levels']).tolist()])

vertZData = loadmat(vertZPath)
YcVertZ = vertZData['Y_control']; YkVertZ = vertZData['Y_kyphotic']
lvlRangeVertZ = np.array([e[0] for e in np.concatenate(vertZData['levels']).tolist()])

