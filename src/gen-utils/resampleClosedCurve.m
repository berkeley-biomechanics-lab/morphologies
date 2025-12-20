function Pk = resampleClosedCurve(P, K)

    P = [P; P(1,:)];     % close loop
    d = vecnorm(diff(P),2,2);
    s = [0; cumsum(d)];
    s = s / s(end);
    
    sq = linspace(0,1,K+1)';
    sq(end) = [];
    
    Pk = interp1(s, P, sq, 'linear');

end

