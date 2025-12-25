function [Pi_aligned, Ps_aligned] = alignDiscBoundaries(Pi, Ps)
% Arc-length based one-to-one correspondence

    K = max(size(Pi,1), size(Ps,1));

    Pi = resampleClosedCurve(Pi, K);
    Ps = resampleClosedCurve(Ps, K);

    Pi_aligned = Pi;
    Ps_aligned = Ps;
end

