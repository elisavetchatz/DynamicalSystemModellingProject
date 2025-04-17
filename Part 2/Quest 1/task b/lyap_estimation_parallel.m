function [x_hat, theta_hist, ex] = lyap_estimation_parallel(t, u, x_true, theta0, gamma)
    dt = t(2) - t(1);
    N = length(t);

    x_hat = zeros(N, 1);
    x_dot_hat = zeros(N, 1);
    theta_hat = theta0(:);  % [m, b, k]
    theta_hist = zeros(N, 3);
    ex = zeros(N, 1);

    % Initial conditions
    x_hat(1) = 0;
    x_dot_hat(1) = 0;

    for i = 2:N
        m_hat = theta_hat(1);
        b_hat = theta_hat(2);
        k_hat = theta_hat(3);

        x_ddot_hat = (1 / m_hat) * (u(i-1) - b_hat * x_dot_hat(i-1) - k_hat * x_hat(i-1));

        x_dot_hat(i) = x_dot_hat(i-1) + dt * x_ddot_hat;
        x_hat(i) = x_hat(i-1) + dt * x_dot_hat(i-1);

        ex(i) = x_true(i) - x_hat(i);

        phi = [x_ddot_hat; x_dot_hat(i); x_hat(i)];
        theta_hat = theta_hat + gamma * phi * ex(i) * dt;

        theta_hist(i, :) = theta_hat';
    end
end