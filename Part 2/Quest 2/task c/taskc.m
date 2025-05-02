clear; clc; close all;

%% === SYSTEM TRUE PARAMETERS ===
true_params = [-1.315; -0.725; 0.225; 1.175];

%% === ADAPTATION AND CONTROL GAINS ===
adapt_gain = diag([25, 45, 75, 25]);
feedback_gain = 50;

% Control parameters
phi_init = 0.3;
phi_final = 0.01;
decay_rate = 1.5;
damping = 3;
k_ctrl_1 = 8;
k_ctrl_2 = 8;

% Reference trajectory
target_angle = pi/10;

%% === SIMULATION SETTINGS ===
time_window = [0 20];
x_init = zeros(8,1);
x_init(1) = 0.1;   % state_1 (angle)
x_init(2) = 0.05;  % state_2 (rate)
x_init(5:8) = [-1.50; -0.2; 0.2; -5];  % initial guesses


[t, X] = ode45(@(t, x) reject_dist(t, x, true_params, adapt_gain, feedback_gain, ...
                phi_init, phi_final, decay_rate, damping, k_ctrl_1, k_ctrl_2, target_angle), ...
                time_window, x_init);

%% === EXTRACT STATES ===
y_real = X(:,1);
y_est  = X(:,3);
y_error = y_real - y_est;
param_est = X(:,5:8);

fprintf('\n--- Estimated Parameters under Disturbance ---\n');
for i = 1:4
    fprintf('Theta_%d: True = %.4f, Estimated = %.4f\n', i, true_params(i), param_est(end,i));
end

%% === PLOTS ===
figure;
plot(t, y_real, 'b', 'LineWidth', 2); hold on;
plot(t, y_est, 'r--', 'LineWidth', 2);
xlabel('Time [s]'); ylabel('Angle [rad]');
title('Output vs Estimated Output under Disturbance');
legend('y(t)', '\hat{y}(t)'); grid on;

figure;
plot(t, y_error, 'k', 'LineWidth', 2);
xlabel('Time [s]'); ylabel('Error [rad]');
title('Estimation Error under Disturbance'); grid on;

figure;
plot(t, param_est(:,1), 'r', 'LineWidth', 2); hold on;
plot(t, param_est(:,2), 'g', 'LineWidth', 2);
plot(t, param_est(:,3), 'b', 'LineWidth', 2);
plot(t, param_est(:,4), 'm', 'LineWidth', 2);
xlabel('Time [s]'); ylabel('Parameter Estimates');
title('Parameter Adaptation under Disturbance');
legend('\theta_1','\theta_2','\theta_3','\theta_4','Interpreter','latex'); grid on;

%% === DYNAMICS FUNCTION ===
function dx = disturbance_adaptive_model(t, x, theta, Gamma, gain, phi0, phi_inf, lambda, rho, k1, k2, r_target)
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
