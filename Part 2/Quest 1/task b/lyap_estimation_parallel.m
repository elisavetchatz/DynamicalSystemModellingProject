function [x_hat, theta_hist, ex] = lyap_estimation_parallel(t, u, x_true, theta0, gamma, x0)
    
    dt = t(2) - t(1);
    N = length(t);

    x_hat = zeros(N, 1);
    xdot_hat = zeros(N, 1);
    theta_hat = theta0(:);  % [m, b, k]
    theta_hist = zeros(N, 3);
    ex = zeros(N, 1);

    % Initial conditions
    x_hat(1) = x0(1);  
    xdot_hat(1) = x0(2);  

    for i = 2:N
        m_hat = theta_hat(1);
        b_hat = theta_hat(2);
        k_hat = theta_hat(3);

        xddot_hat = (1 / m_hat) * (u(i-1) - b_hat * xdot_hat(i-1) - k_hat * x_hat(i-1));

        xdot_hat(i) = xdot_hat(i-1) + dt * xddot_hat;
        x_hat(i) = x_hat(i-1) + dt * xdot_hat(i-1);

        ex(i) = x_true(i) - x_hat(i);

        phi = [xddot_hat; xdot_hat(i); x_hat(i)];
        theta_hat = theta_hat + gamma * phi * ex(i) * dt;

        theta_hist(i, :) = theta_hat';
    end
end