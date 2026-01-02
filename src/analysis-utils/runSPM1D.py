def runSPM1D(Yc,Yk,X,*,alpha=0.05,equal_var=False,two_tailed=True,title=""):
    """
    Runs two-sample 1D SPM t-test and plots results.

    Parameters
    ----------
    Yc, Yk : (N x Q) arrays
        Control and kyphotic summary arrays
    X : (Q,) array
        Spatial coordinate (levels or normalized)
    alpha : float
        Significance level
    equal_var : bool
        Assume equal variance?
    two_tailed : bool
        Two-tailed test if True
    title : str
        Plot title
    """

    # -------------------------
    # Sanity checks
    # -------------------------
    assert Yc.ndim == 2 and Yk.ndim == 2
    assert Yc.shape[1] == Yk.shape[1] == len(X)

    # -------------------------
    # Two-sample t-test
    # -------------------------
    ttest = spm1d.stats.ttest2(Yk, Yc, equal_var=equal_var)
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
    ax0.plot(X, np.nanmean(Yc, axis=0), 'r', label='Control')
    ax0.plot(X, np.nanmean(Yk, axis=0), 'b', label='Kyphotic')

    ax0.fill_between(
        X,
        np.nanmean(Yc, axis=0) - np.nanstd(Yc, axis=0),
        np.nanmean(Yc, axis=0) + np.nanstd(Yc, axis=0),
        color='r', alpha=0.2
    )

    ax0.fill_between(
        X,
        np.nanmean(Yk, axis=0) - np.nanstd(Yk, axis=0),
        np.nanmean(Yk, axis=0) + np.nanstd(Yk, axis=0),
        color='b', alpha=0.2
    )

    ax0.set_ylabel("Measurement")
    ax0.legend()
    ax0.set_title(title)

    # --- SPM{t} ---
    ax1 = fig.add_subplot(212, sharex=ax0)
    inference.plot(ax=ax1)
    inference.plot_threshold_label(ax=ax1)
    inference.plot_p_values(ax=ax1)

    ax1.set_xlabel("Spinal position")
    ax1.set_ylabel("SPM{t}")

    plt.tight_layout()
    plt.show()

    return inference

