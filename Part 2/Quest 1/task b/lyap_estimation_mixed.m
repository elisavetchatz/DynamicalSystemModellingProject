function [x_hat, theta_hist, ex] = lyap_estimation_mixed(t, u, x, theta0, gamma, lambda)
     
    dt = t(2) - t(1);
    N = length(t);

    theta_hat = theta0(:);
    theta_hist = zeros(N, 3);
    ex = zeros(N, 1);

    x_hat = zeros(N, 1);
    xdot_hat = zeros(N, 1);

    % Create filters
    syms s
    Lambda = sym2poly((s + lambda)^2);
    D1 = tf([1 0 0], Lambda);
    D2 = tf([0 1 0], Lambda);
    D3 = tf([0 0 1], Lambda);

    phi1 = lsim(D1, x, t);  % approx ddot(x)
    phi2 = lsim(D2, x, t);  % approx dot(x)
    phi3 = lsim(D3, x, t);  % approx x
    yf = lsim(D3, u, t);    % filtered u

    for i = 1:N
        phi = [phi1(i); phi2(i); phi3(i)];
        y_hat = phi' * theta_hat;
        error = yf(i) - y_hat;

        theta_hat = theta_hat + gamma * phi * error * dt;

        theta_hist(i, :) = theta_hat';
        ex(i) = error;
    end

    % Reconstruct x_hat via numerical integration
    for i = 2:N
        m_hat = theta_hist(i-1,1);
        b_hat = theta_hist(i-1,2);
        k_hat = theta_hist(i-1,3);
        xddot_hat = (1/m_hat)*(u(i-1) - b_hat * xdot_hat(i-1) - k_hat * x_hat(i-1));
        xdot_hat(i) = xdot_hat(i-1) + dt * xddot_hat;
        x_hat(i) = x_hat(i-1) + dt * xdot_hat(i-1);
    end
end