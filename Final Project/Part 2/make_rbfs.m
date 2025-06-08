function gaussians = make_rbfs(phi_vec, centers, sigma)
    % Apply RBFs to each element of phi_vec across given centers
    n = length(phi_vec);
    C = length(centers);
    gaussians = zeros(n * C, 1);
    
    for i = 1:n
        for j = 1:C
            gaussians((i-1)*C + j) = exp(-(phi_vec(i) - centers(j))^2 / (2 * sigma^2));
        end
    end
end
