clear; clc; close all;

%% === SYSTEM TRUE PARAMETERS ===
true_params = [-1.315; -0.725; 0.225; 1.175];

%% === ADAPTATION AND CONTROL GAINS ===
adapt_gain = diag([20, 50, 80, 20]);
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
