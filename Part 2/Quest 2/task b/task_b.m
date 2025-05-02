clear; clc; close all;

%% === TRUE SYSTEM PARAMETERS ===
theta_true = [-1.315; -0.725; 0.225; 1.175];

% === Learning Rates (Gamma Matrix) ===
Gamma = diag([20, 20, 50, 20]);

% === Observer Gain ===
observer_gain = 50;

% === Control Parameters ===
phi_0 = 0.3;
phi_inf = 0.01;
lambda = 1.5;

rho = 3;
k_alpha = 8;
k_beta = 8;

% === Simulation Parameters ===
sim_time = [0 20];
desired_angle = pi/10;

% === Initial Conditions ===
% [x1, x2, x1_hat, x2_hat, theta1_hat, ..., theta4_hat]
x_init = zeros(8,1);
x_init(1) = 0.1;   % x1 = r
x_init(2) = 0.05;  % x2 = r_dot
x_init(5:8) = [-1.5; -0.2; 0.2; -5];

% === Solver Options ===
options = odeset('RelTol',1e-3, 'AbsTol',1e-5);

[t, state] = ode45(@(t, x) estimation_func(t, x, theta_true, Gamma, observer_gain, ...
                            phi_0, phi_inf, lambda, rho, k_alpha, k_beta, desired_angle), ...
                            sim_time, x_init, options);

% === Output Processing ===
x_real = state(:,1);
x_est  = state(:,3);
theta_est = state(:,5:8);
estimation_error = x_real - x_est;
final_theta = theta_est(end,:);

fprintf('\n--- Final Parameter Estimates ---\n');
for i = 1:4
    fprintf('True θ_%d = %.4f, Estimated θ_%d = %.4f\n', ...
        i, theta_true(i), i, final_theta(i));
end

%% === PLOTS ===

% 1. Real vs Estimated State
figure;
plot(t, x_real, 'b', 'LineWidth', 2); hold on;
plot(t, x_est, 'r--', 'LineWidth', 2);
xlabel('Time [s]'); ylabel('Roll Angle [rad]');
title('Real vs Estimated Roll Angle');
grid on;

% 2. Estimation Error
figure;
plot(t, estimation_error, 'k', 'LineWidth', 2);
xlabel('Time [s]');
ylabel('Estimation Error [rad]');
title('Error e(t) = x_1(t) - x̂_1(t)');
grid on;

% 3. Parameter Estimations
figure;
plot(t, theta_est(:,1), 'r', 'LineWidth', 2); hold on;
plot(t, theta_est(:,2), 'g', 'LineWidth', 2);
plot(t, theta_est(:,3), 'b', 'LineWidth', 2);
plot(t, theta_est(:,4), 'm', 'LineWidth', 2);
xlabel('Time [s]');
ylabel('Parameter Estimates');
title('Adaptive Parameter Convergence');
legend('\theta_1', '\theta_2', '\theta_3', '\theta_4', 'Interpreter', 'latex');
grid on;