function dx = reject_dist(t, x, theta, Gamma, gain, phi0, phi_inf, lambda, rho, k1, k2, r_target)
    y = x(1); dy = x(2);
    y_hat = x(3); dy_hat = x(4);
    theta_hat = x(5:8);

    % Disturbance
    disturbance = 0.15 * sin(0.5 * t);

    % Desired trajectory
    y_ref = r_target * sin(pi*t/20);

    % Nonlinear basis
    basis1 = sin(y);
    basis2 = dy^2 * sin(2*y);

    % Control law
    phi = (phi0 - phi_inf)*exp(-lambda*t) + phi_inf;
    z1 = (y - y_ref)/phi;
    alpha = -k1 * log((1 + z1)/(1 - z1));
    z2 = (dy - alpha)/rho;
    ctrl = -k2 * log((1 + z2)/(1 - z2));

    % True system
    dy1 = dy;
    dy2 = theta(1)*dy + theta(2)*basis1 + theta(3)*basis2 + theta(4)*ctrl + disturbance;

    % Observer
    err1 = y - y_hat;
    err2 = dy - dy_hat;

    dy1_hat = dy_hat;
    dy2_hat = theta_hat(1)*dy + theta_hat(2)*basis1 + theta_hat(3)*basis2 + theta_hat(4)*ctrl + gain*(err1 + err2);

    % Adaptive laws
    dtheta = Gamma * err2 * [dy; basis1; basis2; ctrl];

    % Derivatives
    dx = zeros(8,1);
    dx(1:2) = [dy1; dy2];
    dx(3:4) = [dy1_hat; dy2_hat];
    dx(5:8) = dtheta;
end
