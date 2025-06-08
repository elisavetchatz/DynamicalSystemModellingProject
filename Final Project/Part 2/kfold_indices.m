function indices = kfold_indices(N, K, seed)
    % Χωρίζει N δείγματα σε K περίπου ίσα folds
    % Επιστρέφει διάνυσμα indices: indices(i) = αριθμός fold για το δείγμα i
    %
    % seed: optional, για αναπαραγωγιμότητα

    if nargin == 3
        rng(seed);
    end

    indices = zeros(N, 1);
    perm = randperm(N);          % τυχαία αναδιάταξη
    fold_sizes = repmat(floor(N / K), 1, K);
    fold_sizes(1:mod(N,K)) = fold_sizes(1:mod(N,K)) + 1;  % κατανέμει υπόλοιπο

    current = 1;
    for k = 1:K
        fold_len = fold_sizes(k);
        indices(perm(current:current+fold_len-1)) = k;
        current = current + fold_len;
    end
end
