function [theta_hist, y_hat, error] = rls_estimator(Phi, Y)
    % Recursive Least Squares Estimator
    M = size(Phi, 1);
    n = size(Phi, 2);

    theta = zeros(n, 1);
    P = 1000 * eye(n);
    theta_hist = zeros(n, M);
    y_hat = zeros(M, 1);
    error = zeros(M, 1);

    for k = 1:M
        phi_k = Phi(k, :)';
        y_k = Y(k);

        K = (P * phi_k) / (1 + phi_k' * P * phi_k);
        theta = theta + K * (y_k - phi_k' * theta);
        P = P - (K * phi_k') * P;

        theta_hist(:, k) = theta;
        y_hat(k) = phi_k' * theta;
        error(k) = y_k - y_hat(k);
    end
end
