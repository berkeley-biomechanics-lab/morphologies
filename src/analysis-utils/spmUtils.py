# Import statements
import spm1d
import numpy as np
import matplotlib.pyplot as plt

def runSPM1D(Yc,Yk,lvlRange,*,xMode="norm",alpha=0.05,equal_var=False,two_tailed=False,title="",ylabel="Measurement"):
    """
    Runs two-sample 1D SPM t-test and plots results.

    Parameters
    ----------
    Yc, Yk : (N x Q) arrays
        Control and kyphotic summary arrays
    lvlRange : (M,) array
        string array of levels associated with measurement
    xMode : str
        "normalized" or "levels" for x-axis mode
    alpha : float
        Significance level
    equal_var : bool
        Assume equal variance?
    two_tailed : bool
        Two-tailed test if True
    title : str
        Plot title
    """

    Q  = Yc.shape[1] # sampling frequency (for scalar vars, Q = # of levels)

    ## DATA PROCESSING ##
    # SPM does NOT automatically handle NaNs node-wise, so we will 
    # mask invalid continuum points away before t-tesing
    mask = validNodes(Yc, Yk)
    Yc = Yc[:, mask]; Yk = Yk[:, mask]

    # -------------------------
    # Sanity checks
    # -------------------------
    assert Yc.ndim == 2 and Yk.ndim == 2
    assert Yc.shape[1] == Yk.shape[1]

    if not np.any(mask):
        raise RuntimeError("No valid nodes remain after masking.")

    if Yc.shape[0] < 2 or Yk.shape[0] < 2:
        raise RuntimeError("Insufficient subjects after cleaning.")

    # -------------------------
    # Two-sample t-test
    # -------------------------
    ttest = spm1d.stats.ttest2(Yc, Yk, equal_var=equal_var)
    inference = ttest.inference(
        alpha=alpha,
        two_tailed=two_tailed,
        interp=True
    )

    # -------------------------
    # Plot
    # -------------------------
    fig = plt.figure(figsize=(10, 6))

    # --- Mean ± SD ---
    ax0 = fig.add_subplot(211)
    spm1d.plot.plot_mean_sd(Yc, ax=ax0, 
                            linecolor='r', facecolor=(1,0.7,0.7), 
                            edgecolor='r', label='Control')
    spm1d.plot.plot_mean_sd(Yk,ax=ax0, 
                            linecolor='b', facecolor=(0.7,0.7,1), 
                            edgecolor='b', label='Kyphotic')

    ax0.set_ylabel(ylabel)
    ax0.legend()
    ax0.set_title(title + ' (Levels: ' + lvlRange[0] + ' --> '+ lvlRange[-1] + ')')

    # --- SPM{t} ---
    ax1 = fig.add_subplot(212, sharex=ax0)
    inference.plot(ax=ax1)
    inference.plot_threshold_label(ax=ax1)
    inference.plot_p_values(ax=ax1)

    ax1.set_ylabel("SPM{t}")

    if xMode == "norm":
        # normalizing x-axis: relabeling from [0, Yc.shape[1] - 1] to [0.0, 1.0]
        nn = 6; xticks = np.linspace(0, Yc.shape[1] - 1, nn)
        xticklabels = np.linspace(0, 100, nn)
        ax1.set_xticks(xticks); ax1.set_xticklabels([f'{x:.1f}' for x in xticklabels])
        ax1.set_xlabel("Measurement domain (%)")
    elif xMode == "levels":
        # normalizing x-axis: relabel from [0.0, 1.0] to lvlRange
        nn = len(lvlRange); xticks = np.linspace(0, Yc.shape[1] - 1, nn)
        ax1.set_xticks(xticks); ax1.set_xticklabels(lvlRange)
        ax1.set_xlabel("Spinal position")
    else:
        raise ValueError("xMode must be 'normalized' or 'levels'!")

    plt.tight_layout()
    plt.show()

    return inference

def validNodes(Yc, Yk):
    """
    Node mask
    """
    return (
        np.all(np.isfinite(Yc), axis=0) &
        np.all(np.isfinite(Yk), axis=0)
    )

