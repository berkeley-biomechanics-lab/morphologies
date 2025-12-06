#######################################################################################
# Grace O'Connell Biomechanics Lab, UC Berkeley Department of Mechanical
# Engineering - Etchverry 2162
#
# Processing vertebral segmentation measurement data and computing summary
# statistics across control/kyphotic + regions of interest experimental groups.
#
#######################################################################################

import os
import spm1d

import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt

# path of the segmentation measurement data:
folderPath = "C:\\Users\\16233\\Desktop\\grad\\projects\\scoliosis\\subject measurements\\subject statistical modeling\\measurement summaries"
fileName = "summary_arrays.mat"

# looping summary array files:
filePath = os.path.join(folderPath, fileName)
dataMat = sio.loadmat(filePath)

# cross sectional area data:
csa_ca = dataMat['area_ca_summary']
csa_ka = dataMat['area_ka_summary']
csa_cb = dataMat['area_cb_summary']
csa_kb = dataMat['area_kb_summary']

# AP height data:
hap_ca = dataMat['hap_ca_summary']
hap_ka = dataMat['hap_ka_summary']
hap_cb = dataMat['hap_cb_summary']
hap_kb = dataMat['hap_kb_summary']

# Lateral height data:
hl_ca = dataMat['hl_ca_summary']
hl_ka = dataMat['hl_ka_summary']
hl_cb = dataMat['hl_cb_summary']
hl_kb = dataMat['hl_kb_summary']

# AP width data:
wap_ca = dataMat['wAP_ca_summary']
wap_ka = dataMat['wAP_ka_summary']
wap_cb = dataMat['wAP_cb_summary']
wap_kb = dataMat['wAP_kb_summary']

# Lateral width data:
wl_ca = dataMat['wlat_ca_summary']
wl_ka = dataMat['wlat_ka_summary']
wl_cb = dataMat['wlat_cb_summary']
wl_kb = dataMat['wlat_kb_summary']

# Volume data:
vol_ca = dataMat['vol_ca_summary']
vol_ka = dataMat['vol_ka_summary']
vol_cb = dataMat['vol_cb_summary']
vol_kb = dataMat['vol_kb_summary']

# Total surface area data:
sa_ca = dataMat['sa_ca_summary']
sa_ka = dataMat['sa_ka_summary']
sa_cb = dataMat['sa_cb_summary']
sa_kb = dataMat['sa_kb_summary']

# Inferior surface area data:
aI_ca = dataMat['aI_ca_summary']
aI_ka = dataMat['aI_ka_summary']
aI_cb = dataMat['aI_cb_summary']
aI_kb = dataMat['aI_kb_summary']

# Superior surface area data:
aS_ca = dataMat['aS_ca_summary']
aS_ka = dataMat['aS_ka_summary']
aS_cb = dataMat['aS_cb_summary']
aS_kb = dataMat['aS_kb_summary']

# A/P height ratio data:
apr_ca = dataMat['apr_ca_summary']
apr_ka = dataMat['apr_ka_summary']
apr_cb = dataMat['apr_cb_summary']
apr_kb = dataMat['apr_kb_summary']

# L/R height ratio data:
lrr_ca = dataMat['lrr_ca_summary']
lrr_ka = dataMat['lrr_ka_summary']
lrr_cb = dataMat['lrr_cb_summary']
lrr_kb = dataMat['lrr_kb_summary']

# vertebral wedging data:
wedge_ca = dataMat['wedge_ca_summary']
wedge_ka = dataMat['wedge_ka_summary']
wedge_cb = dataMat['wedge_cb_summary']
wedge_kb = dataMat['wedge_kb_summary']

def plot_spatial_variable(ca: np.ndarray, ka: np.ndarray, cb: np.ndarray, kb: np.ndarray, xlab: str, ylab: str, roia_lab: str, roib_lab: str, name: str, alpha=0.05):
    """
    Plots the summary statistics and statistical tests of the given goemetric spatial variable
    which is partitioned into regions of interest (ROIa an ROIb) and experimentally seperated into
    control and kyphotic groups as such:
        ca ~ control, ROIa data
        ka ~ kyphotic, ROIa data
        cb ~ control, ROIb data
        kb ~ kyphotic, ROIb data

        * statistical test assumptions:
             --> unequal variance between control and kyphotic groups
             --> hypothesis is one-directional

    Args:
        ca (np.ndarray): control, ROIa array of spatial variable
        ka (np.ndarray): kyphotic, ROIa array of spatial variable
        cb (np.ndarray): control, ROIb array of spatial variable
        kb (np.ndarray): kyphotic, ROIb array of spatial variable
        xlab (string): name of xlabel associated with spatial variable
        ylab (string): name of ylabel associated with spatial variable
        roia_lab (string): name of ROIa label associated with spatial variable
        roib_lab (string): name of ROIb label associated with spatial variable
        name (string): name of spatial variable
    
    Returns:
        None
    """
    # contructing plotting objects:
    f = ca.shape[1] # sampling frequency of spatial variable
    normx = np.linspace(0.0, 1.0, num=f, endpoint=True)
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2)
    
    # plotting mean and standard deviation cloud distribution:
    spm1d.plot.plot_mean_sd(ca, x=normx, ax=ax1, linecolor='b', facecolor=(0.7,0.7,1), edgecolor='b', label='control')
    spm1d.plot.plot_mean_sd(ka, x=normx, ax=ax1, linecolor='r', facecolor=(1,0.7,0.7), edgecolor='r', label='kyphotic')
    spm1d.plot.plot_mean_sd(cb, x=normx, ax=ax2, linecolor='b', facecolor=(0.7,0.7,1), edgecolor='b', label='control')
    spm1d.plot.plot_mean_sd(kb, x=normx, ax=ax2, linecolor='r', facecolor=(1,0.7,0.7), edgecolor='r', label='kyphotic')

    # labeling the figure:
    fig.suptitle("Summary statistics and two-sample t-tests for %s distribution" % (name))
    ymina = np.min([np.min(ca), np.min(ka)])
    yminb = np.min([np.min(cb), np.min(kb)])
    ymaxa = np.max([np.max(ca), np.max(ka)])
    ymaxb = np.max([np.max(cb), np.max(kb)])
    ymin = np.min([ymina, yminb])
    ymax = np.max([ymaxa, ymaxb])
    ax1.set_ylim(ymin, ymax)
    ax2.set_ylim(ymin, ymax)
    ax1.set_ylabel(ylab, fontsize='large')
    ax2.set_ylabel(ylab, fontsize='large')
    ax3.set(xlabel="normalized position along %s " % (xlab))
    ax4.set(xlabel="normalized position along %s " % (xlab))
    ax1.set_title(roia_lab + ' section')
    ax2.set_title(roib_lab + ' section')
    ax1.legend(loc='lower right')
    ax2.legend(loc='lower right')

    # computing statistical test distributions:
    # statistical test assumptions,
    #       equal-variance --> False (different groups of observations can have different variances)
    #       two-tailed --> False (hypothesis is one-directional)
    #       interp --> True (interpolate to more accurately estimate the location and size of threshold crossings (clusters) between the discrete nodes of your data)
    try: # checks for zero variance at boundaries of data
        ta = spm1d.stats.ttest2(ca, ka, equal_var=False) # ROIa test
        tb = spm1d.stats.ttest2(cb, kb, equal_var=False) # ROIb test
    except spm1d.stats._datachecks.SPM1DError:
        ta = spm1d.stats.ttest2(ca[:, 1:-1], ka[:, 1:-1], equal_var=False) # ROIa test
        tb = spm1d.stats.ttest2(cb[:, 1:-1], kb[:, 1:-1], equal_var=False) # ROIb test
    tai = ta.inference(alpha=alpha, two_tailed=False, interp=True) # ROIa inference
    tbi = tb.inference(alpha=alpha, two_tailed=False, interp=True) # ROIb inference

    # plotting significance distribution:
    # figure characteristics,
    #       --> thick black line depicts the test statistic continuum
    #       --> p-value indicates the probability that smooth, random continua would produce a 
    #           supra-threshold cluster as broad as the observed cluster
    #       --> red hashed line depicts the critical threshold at alpha = 5% such that the null 
    #           hypothesis is rejected at alpha if the SPM{t} exceeds this threshold
    tai.plot(ax=ax3)
    tbi.plot(ax=ax4)
    tai.plot_p_values(ax=ax3)
    tbi.plot_p_values(ax=ax4)
    tai.plot_threshold_label(ax=ax3)
    tbi.plot_threshold_label(ax=ax4)

    # normalizing x-axis: relabeling from [0, f] to [0.0, 1.0]
    nn = 6
    xticks = np.linspace(0, f, nn)
    xticklabels = np.linspace(0, 1, nn)
    ax3.set_xticks(xticks)
    ax3.set_xticklabels([f'{x:.1f}' for x in xticklabels])
    ax4.set_xticks(xticks)
    ax4.set_xticklabels([f'{x:.1f}' for x in xticklabels])
        
    # showing the subplot figure:
    plt.show()

def plot_position_variable(ca: np.ndarray, ka: np.ndarray, cb: np.ndarray, kb: np.ndarray, xaticks: np.array, xbticks: np.array, ylab: str, roia_lab: str, roib_lab: str, name: str, alpha=0.05, two_tailed=False):
    """
    Plots the summary statistics and statistical tests of the given goemetric position variable
    which is partitioned into regions of interest (ROIa an ROIb) and experimentally seperated into
    control and kyphotic groups as such:
        ca ~ control, ROIa data
        ka ~ kyphotic, ROIa data
        cb ~ control, ROIb data
        kb ~ kyphotic, ROIb data

        * statistical test assumptions:
             --> unequal variance between control and kyphotic groups
             --> hypothesis is one-directional

    Args:
        ca (np.ndarray): control, ROIa array of position variable
        ka (np.ndarray): kyphotic, ROIa array of position variable
        cb (np.ndarray): control, ROIb array of position variable
        kb (np.ndarray): kyphotic, ROIb array of position variable
        xaticks (np.narray): x-axis tick labels associated with ROIa
        xbticks (np.narray): x-axis tick labels associated with ROIb
        ylab (string): name of ylabel associated with position variable
        roia_lab (string): name of ROIa label associated with position variable
        roib_lab (string): name of ROIb label associated with position variable
        name (string): name of position variable
    
    Returns:
        None
    """
    # contructing plotting objects:
    fa = ca.shape[1] # sampling frequency of position variable wrt ROIa section
    fb = cb.shape[1] # sampling frequency of position variable wrt ROIb section
    normxa = np.linspace(0.0, 1.0, num=fa, endpoint=True)
    normxb = np.linspace(0.0, 1.0, num=fb, endpoint=True)
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2)
    
    # plotting mean and standard deviation cloud distribution:
    spm1d.plot.plot_mean_sd(ca, x=normxa, ax=ax1, linecolor='b', facecolor=(0.7,0.7,1), edgecolor='b', label='control')
    spm1d.plot.plot_mean_sd(ka, x=normxa, ax=ax1, linecolor='r', facecolor=(1,0.7,0.7), edgecolor='r', label='kyphotic')
    spm1d.plot.plot_mean_sd(cb, x=normxb, ax=ax2, linecolor='b', facecolor=(0.7,0.7,1), edgecolor='b', label='control')
    spm1d.plot.plot_mean_sd(kb, x=normxb, ax=ax2, linecolor='r', facecolor=(1,0.7,0.7), edgecolor='r', label='kyphotic')

    # labeling the figure:
    fig.suptitle("Summary statistics and non-parametric two-sample t-tests for %s distribution" % (name))
    ymina = np.min([np.min(ca), np.min(ka)])
    yminb = np.min([np.min(cb), np.min(kb)])
    ymaxa = np.max([np.max(ca), np.max(ka)])
    ymaxb = np.max([np.max(cb), np.max(kb)])
    ymin = np.min([ymina, yminb])
    ymax = np.max([ymaxa, ymaxb])
    ax1.set_ylim(ymin, ymax)
    ax2.set_ylim(ymin, ymax)
    ax1.set_ylabel(ylab, fontsize='large')
    ax2.set_ylabel(ylab, fontsize='large')
    ax3.set(xlabel="position along spine")
    ax4.set(xlabel="position along spine")
    ax1.set_title(roia_lab + ' section')
    ax2.set_title(roib_lab + ' section')
    ax1.legend(loc='upper left')
    ax2.legend(loc='upper left')

    # normalizing x-axis: relabel from [0.0, 1.0] to [T1, L6]
    xaticks_range = np.linspace(0.0, 1.0, fa)
    xbticks_range = np.linspace(0.0, 1.0, fb)
    xaticksn_range = np.linspace(0.0, fa - 1, fa)
    xbticksn_range = np.linspace(0.0, fb - 1, fb)
    ax1.set_xticks(xaticks_range)
    ax1.set_xticklabels(xaticks)
    ax2.set_xticks(xbticks_range)
    ax2.set_xticklabels(xbticks)
    ax3.set_xticks(xaticksn_range)
    ax3.set_xticklabels(xaticks)
    ax4.set_xticks(xbticksn_range)
    ax4.set_xticklabels(xbticks)

    # computing statistical test distributions:
    # statistical test assumptions,
    #       nonparam --> data is not normally distributed
    #       two-tailed --> False (hypothesis is one-directional)
    #       interp --> True (interpolate to more accurately estimate the location and size of threshold crossings (clusters) between the discrete nodes of your data)
    try: # checks for zero variance at boundaries of data
        ta = spm1d.stats.nonparam.ttest2(ca, ka) # ROIa test
        tb = spm1d.stats.nonparam.ttest2(cb, kb) # ROIb test
    except spm1d.stats._datachecks.SPM1DError:
        ta = spm1d.stats.nonparam.ttest2(ca[:, 1:-1], ka[:, 1:-1]) # ROIa test
        tb = spm1d.stats.nonparam.ttest2(cb[:, 1:-1], kb[:, 1:-1]) # ROIb test
    tai = ta.inference(alpha=alpha, two_tailed=two_tailed, interp=True, iterations=-1) # ROIa inference
    tbi = tb.inference(alpha=alpha, two_tailed=two_tailed, interp=True, iterations=-1) # ROIb inference

    # plotting significance distribution:
    # figure characteristics,
    #       --> thick black line depicts the test statistic continuum
    #       --> p-value indicates the probability that smooth, random continua would produce a 
    #           supra-threshold cluster as broad as the observed cluster
    #       --> red hashed line depicts the critical threshold at alpha = 5% such that the null 
    #           hypothesis is rejected at alpha if the SPM{t} exceeds this threshold
    tai.plot(ax=ax3)
    tbi.plot(ax=ax4)
    tai.plot_p_values(ax=ax3)
    tbi.plot_p_values(ax=ax4)
    tai.plot_threshold_label(ax=ax3)
    tbi.plot_threshold_label(ax=ax4)
        
    # showing the subplot figure:
    plt.show()

# plotting spatial variable summary statistic and statistical test distributions:
# spatial variables include,
#       cross sectional area VS inf-sup axis
#       height VS post-ant axis
#       height VS left-right lat axis
#       AP width VS inf-sup axis
#       lateral width VS inf-sup axis
ROIa_label = dataMat['DisplayNameIa'][0]
ROIb_label = dataMat['DisplayNameIb'][0]
plot_spatial_variable(csa_ca, csa_ka, csa_cb, csa_kb, xlab="inferior-superior axis", ylab="area [mm^2]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="CSA")
plot_spatial_variable(hap_ca, hap_ka, hap_cb, hap_kb, xlab="posterior-anterior axis", ylab="inf-sup height [mm]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="AP height")
plot_spatial_variable(hl_ca, hl_ka, hl_cb, hl_kb, xlab="left-right lateral axis", ylab="inf-sup height [mm]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="lateral height")
plot_spatial_variable(wap_ca, wap_ka, wap_cb, wap_kb, xlab="inf-sup axis", ylab="ant-pos width [mm]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="AP width")
plot_spatial_variable(wl_ca, wl_ka, wl_cb, wl_kb, xlab="inf-sup axis", ylab="left-right width [mm]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="lateral width")

# plotting vertebrae-position variable summary statistic and statistical test distributions:
# vertebrae-position variables include,
#       volume VS position along spine
#       total surface area VS position along spine
#       inferior surface area VS position along spine
#       superior surface area VS position along spine
#       ap height ratio VS position along spine
#       lr height ratio VS position along spine
#       vertebral wedging VS position along spine
xaticklabels = np.array([item[0] for item in dataMat['ROIa_levels'][0]], dtype='<U3')
xbticklabels = np.array([item[0] for item in dataMat['ROIb_levels'][0]], dtype='<U3')
plot_position_variable(vol_ca, vol_ka, vol_cb, vol_kb, xaticks=xaticklabels, xbticks=xbticklabels, ylab="volume [mm^3]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="volume")
plot_position_variable(sa_ca, sa_ka, sa_cb, sa_kb, xaticks=xaticklabels, xbticks=xbticklabels, ylab="surface area [mm^2]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="total surface area")
plot_position_variable(aI_ca, aI_ka, aI_cb, aI_kb, xaticks=xaticklabels, xbticks=xbticklabels, ylab="surface area [mm^2]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="inferior surface area", two_tailed=True)
plot_position_variable(aS_ca, aS_ka, aS_cb, aS_kb, xaticks=xaticklabels, xbticks=xbticklabels, ylab="surface area [mm^2]", roia_lab=ROIa_label, roib_lab = ROIb_label, name="superior surface area", two_tailed=True)
plot_position_variable(apr_ca, apr_ka, apr_cb, apr_kb, xaticks=xaticklabels, xbticks=xbticklabels, ylab="A/P ratio", roia_lab=ROIa_label, roib_lab = ROIb_label, name="AP height ratio", two_tailed=True)
plot_position_variable(lrr_ca, lrr_ka, lrr_cb, lrr_kb, xaticks=xaticklabels, xbticks=xbticklabels, ylab="L/R ratio", roia_lab=ROIa_label, roib_lab = ROIb_label, name="lateral height ratio", two_tailed=True)
plot_position_variable(wedge_ca, wedge_ka, wedge_cb, wedge_kb, xaticks=xaticklabels, xbticks=xbticklabels, ylab="wedging (deg)", roia_lab=ROIa_label, roib_lab = ROIb_label, name="vertebral body wedging", two_tailed=True)
