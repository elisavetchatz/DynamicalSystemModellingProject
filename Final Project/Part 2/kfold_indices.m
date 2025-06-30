function indices = kfold_indices(N, K, seed)
    % Divides N samples into K folds for cross-validation.
    % N: total number of samples
    % K: number of folds
    % seed: optional random seed for reproducibility

    if nargin == 3
        rng(seed);
    end

    indices = zeros(N, 1);
    perm = randperm(N);          % random permutation
    fold_sizes = repmat(floor(N / K), 1, K);
    fold_sizes(1:mod(N,K)) = fold_sizes(1:mod(N,K)) + 1;  % distribute remainder

    current = 1;
    for k = 1:K
        fold_len = fold_sizes(k);
        indices(perm(current:current+fold_len-1)) = k;
        current = current + fold_len;
    end
end
