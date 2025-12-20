function Pord = orderBoundaryLoop(P)
% PCA projection → angle sort (robust for near-planar loops)
% P: [N×3] unordered boundary points
    
    % --- 1. Center points ---
    C = mean(P,1);
    X = P - C;        % [N×3]
    
    % --- 2. PCA via covariance ---
    [U,~,~] = svd(X' * X);   % U is 3×3
    
    % --- 3. Project into best-fit plane ---
    X2 = X * U(:,1:2);      % [N×2]
    
    % --- 4. Polar angle ---
    theta = atan2(X2(:,2), X2(:,1));
    
    % --- 5. Sort ---
    [~, idx] = sort(theta);
    Pord = P(idx,:);

    % Saftey checks:
    assert(size(P,2) == 3, "P must be N×3");
    assert(rank(X) >= 2, "Boundary points are degenerate");
end

