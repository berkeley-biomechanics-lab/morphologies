#######################################################################################
# Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
# Engineering - Etchverry 2162
#
# File: main.py
# Author: Yousuf Abubakr
# Project: Morphologies
# Last Updated: 1-2-2026
#
# Description: main pipeline for accessing, computing, and visualizing summary 
# statistics across control and kyphotic experimental groups
#
#######################################################################################

# Import statements
import numpy as np

from spmUtils import runSPM1D

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

from loadSummaryData import (YcVertAP, YcVertLAT, YcVertZ, 
                             YkVertAP, YkVertLAT, YkVertZ)

from loadSummaryData import (YcDiscAP, YcDiscLAT, YcDiscZ, 
                             YkDiscAP, YkDiscLAT, YkDiscZ)

from loadSummaryData import (lvlRangeVertAP, lvlRangeVertLAT, lvlRangeVertZ, 
                             lvlRangeDiscAP, lvlRangeDiscLAT, lvlRangeDiscZ)

## SPM ANALYSIS ##
# Running continuous two-sample t-tests and plotting results

# Vertebra and disc SPM:
runSPM1D(Yc=YcVertAP,Yk=YkVertAP,lvlRange=lvlRangeVertAP,title="Height (AP) - Vertebra",ylabel="inf-sup height [mm]")
runSPM1D(Yc=YcVertLAT,Yk=YkVertLAT,lvlRange=lvlRangeVertLAT,title="Height (LAT) - Vertebra",ylabel="inf-sup height [mm]")
runSPM1D(Yc=YcVertZ,Yk=YkVertZ,lvlRange=lvlRangeVertZ,title="CSA (Z) - Vertebra",ylabel="csa [mm²]")

runSPM1D(Yc=YcDiscAP,Yk=YkDiscAP,lvlRange=lvlRangeDiscAP,title="Height (AP) - Disc",ylabel="inf-sup height [mm]")
runSPM1D(Yc=YcDiscLAT,Yk=YkDiscLAT,lvlRange=lvlRangeDiscLAT,title="Height (LAT) - Disc",ylabel="inf-sup height [mm]")
runSPM1D(Yc=YcDiscZ,Yk=YkDiscZ,lvlRange=lvlRangeDiscZ,title="CSA (Z) - Disc",ylabel="csa [mm³]")

# Measuring relative mean percentile differences between control and kyphotic groups, relative to control group mean values:
vertAPPerDiffDist = (np.mean(YcVertAP, axis=0) - np.mean(YkVertAP, axis=0)) / np.mean(YcVertAP, axis=0) * 100
vertLATPerDiffDist = (np.mean(YcVertLAT, axis=0) - np.mean(YkVertLAT, axis=0)) / np.mean(YcVertLAT, axis=0) * 100
vertZPerDiffDist = (np.mean(YcVertZ, axis=0) - np.mean(YkVertZ, axis=0)) / np.mean(YcVertZ, axis=0) * 100

discAPPerDiffDist = (np.mean(YcDiscAP, axis=0) - np.mean(YkDiscAP, axis=0)) / np.mean(YcDiscAP, axis=0) * 100
discLATPerDiffDist = (np.mean(YcDiscLAT, axis=0) - np.mean(YkDiscLAT, axis=0)) / np.mean(YcDiscLAT, axis=0) * 100
discZPerDiffDist = (np.mean(YcDiscZ, axis=0) - np.mean(YkDiscZ, axis=0)) / np.mean(YcDiscZ, axis=0) * 100

# Max/min percentile differences:
vertAPMax = np.max(vertAPPerDiffDist, where=~np.isnan(vertAPPerDiffDist), initial=-1)
vertAPMin = np.min(vertAPPerDiffDist, where=~np.isnan(vertAPPerDiffDist), initial=100)

vertLATMax = np.max(vertLATPerDiffDist, where=~np.isnan(vertLATPerDiffDist), initial=-1)
vertLATMin = np.min(vertLATPerDiffDist, where=~np.isnan(vertLATPerDiffDist), initial=100)

vertZMax = np.max(vertZPerDiffDist, where=~np.isnan(vertZPerDiffDist), initial=-1)
vertZMin = np.min(vertZPerDiffDist, where=~np.isnan(vertZPerDiffDist), initial=100)

discAPMax = np.max(discAPPerDiffDist, where=~np.isnan(discAPPerDiffDist), initial=-1)
discAPMin = np.min(discAPPerDiffDist, where=~np.isnan(discAPPerDiffDist), initial=100)

discLATMax = np.max(discLATPerDiffDist, where=~np.isnan(discLATPerDiffDist), initial=-1)
discLATMin = np.min(discLATPerDiffDist, where=~np.isnan(discLATPerDiffDist), initial=100)

discZMax = np.max(discZPerDiffDist, where=~np.isnan(discZPerDiffDist), initial=-1)
discZMin = np.min(discZPerDiffDist, where=~np.isnan(discZPerDiffDist), initial=100)

# Displaying results:
print(f"Differences in vertebral AP height between control and kyphotic groups range from {vertAPMin:.2f} - {vertAPMax:.2f}%")
print(f"Differences in vertebral LAT height between control and kyphotic groups range from {vertLATMin:.2f} - {vertLATMax:.2f}%")
print(f"Differences in vertebral Z-plane CSA between control and kyphotic groups range from {vertZMin:.2f} - {vertZMax:.2f}%\n")

print(f"Differences in disc AP height between control and kyphotic groups range from {discAPMin:.2f} - {discAPMax:.2f}%")
print(f"Differences in disc LAT height between control and kyphotic groups range from {discLATMin:.2f} - {discLATMax:.2f}%")
print(f"Differences in disc Z-plane CSA between control and kyphotic groups range from {discZMin:.2f} - {discZMax:.2f}%")

