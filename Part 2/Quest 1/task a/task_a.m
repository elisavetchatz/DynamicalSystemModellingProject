clc; clear; close all;

dt = 0.0001; 
t_sim = 0:dt:20;

%u_func = @(t) 2.5; 
u_func = @(t) 2.5 * sin(t);

m = 1.315;
b = 0.225;
k = 0.725;

x0 = [0; 0];

system_fun = @(t, x) system_dynamics(t, x, m, k, b, u_func);

[t, X] = ode45(system_fun, t_sim, x0);
x1 = X(:, 1); 
x2 = X(:, 2); 
%u = u_func(t_sim);

%% Parameter estimation using Gradient Method with filtering
lambda = 1;       % filter constant
gamma = 100;        % learning rate
theta0 = [0, 0, 0];

% u = 2.5 * ones(length(t_sim), 1);  % ensures it's a column
%u = arrayfun(u_func, t_sim(:)); 
u = 2.5 * sin(t_sim(:)); % ensures it's a column
[theta_hist, e_hist] = gradient_estimation(X, t_sim, u, lambda, gamma, theta0);
m_est = theta_hist(end, 1);
b_est = theta_hist(end, 2);
k_est = theta_hist(end, 3);

system_fun_est = @(t, x) system_dynamics(t, x, m_est, k_est, b_est, u_func);
[t_est, X_est] = ode45(system_fun_est, t_sim, x0);
x1_est = X_est(:, 1);
x2_est = X_est(:, 2);
disp(x1_est)

%% Plot results
figure;
% Plot x1 (position)
subplot(2,1,1);  % 2 rows, 1 column, subplot 1
plot(t_sim, x1, 'r', 'DisplayName', 'x1 (True)', 'LineWidth', 1.5);
hold on;
plot(t_sim, x1_est, 'r--', 'DisplayName', 'x1 (Estimated)', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('x1 (Position)');
title('x1: True vs Estimated');
legend;
grid on;
% Plot x2 (velocity)
subplot(2,1,2);  % subplot 2
plot(t_sim, x2, 'g', 'DisplayName', 'x2 (True)', 'LineWidth', 1.5);
hold on;
plot(t_sim, x2_est, 'g--', 'DisplayName', 'x2 (Estimated)', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('x2 (Velocity)');
title('x2: True vs Estimated');
legend;
grid on;
sgtitle('State Variables: True vs Estimated');  % super title για όλο το figure

% Plot of estimation errors and input
figure;
subplot(3,1,1);
plot(t_sim, x1-x1_est, 'r', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Error e_x(t)');
title('Estimation Error in Angle)');
grid on;
subplot(3,1,2);
plot(t_sim, x2-x2_est, 'm', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Error e_{q̇}(t)');
title('Estimation Error in Angular Velocity: e_{q̇}(t) = q̇(t) − q̇̂(t)');
grid on;
subplot(3,1,3);
plot(t, u, 'k', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('u(t) [Nm]');
title('Control Input u(t)');
grid on;

figure;
plot(t_sim, theta_hist(:,1), 'r', 'DisplayName', 'Estimated m', 'LineWidth', 1.5);
hold on;
plot(t_sim, theta_hist(:,2), 'g', 'DisplayName', 'Estimated b', 'LineWidth', 1.5);
plot(t_sim, theta_hist(:,3), 'b', 'DisplayName', 'Estimated k', 'LineWidth', 1.5);
yline(m, '--r', 'DisplayName', 'True m', 'LineWidth', 1.5);
yline(b, '--g', 'DisplayName', 'True b', 'LineWidth', 1.5);
yline(k, '--b', 'DisplayName', 'True k', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Parameter Estimate');
title('Parameter Estimation using Gradient Method');
legend;
grid on;

% figure;
% plot(t_sim, e_hist, 'k', 'LineWidth', 1.5);
% xlabel('Time [s]');
% ylabel('Prediction Error');
% title('Prediction Error over Time');
% grid on;

% %% Sweep over different gamma values
% gamma_vals = [0.1, 0.5, 1, 2, 5, 10, 20, 50, 100];
% final_errors = zeros(length(gamma_vals), 3);  % [em, eb, ek]

% for i = 1:length(gamma_vals)
%     gamma = gamma_vals(i);
%     [theta_hist, ~] = gradient_estimation(X, t_sim, u, lambda, gamma);
%     theta_final = theta_hist(end, :);
%     final_errors(i, 1) = abs(theta_final(1) - m);
%     final_errors(i, 2) = abs(theta_final(2) - b);
%     final_errors(i, 3) = abs(theta_final(3) - k);
% end
% % Plot: Estimation Error vs Gamma
% figure;
% semilogx(gamma_vals, final_errors(:,1), '-o', 'DisplayName','|m̂ - m|', 'Color', 'r', 'LineWidth', '1.5');
% hold on;
% semilogx(gamma_vals, final_errors(:,2), '-s', 'DisplayName','|b̂ - b|', 'Color', 'g', 'LineWidth', '1.5');
% semilogx(gamma_vals, final_errors(:,3), '-d', 'DisplayName','|k̂ - k|', 'Color', 'b', 'LineWidth', '1.5');
% xlabel('\gamma (Learning Rate)');
% ylabel('Absolute Estimation Error');
% title('Effect of \gamma on Parameter Estimation Error');
% legend;
% grid on;

% %% Sweep over different initial values of θ0
% init_vals = [0.5, 1, 2];  % test each value for all theta
% combinations = combvec(init_vals, init_vals, init_vals)';  % all combos
% n_combos = size(combinations, 1);
% final_thetas = zeros(n_combos, 3);
% errors = zeros(n_combos, 3);

% for i = 1:n_combos
%     theta0 = combinations(i, :);
%     [theta_hist, ~] = gradient_estimation(X, t_sim, u, lambda, gamma, theta0);
%     final_thetas(i, :) = theta_hist(end, :);

%     errors(i, :) = abs(final_thetas(i,:) - [m_true, b_true, k_true]);
% end

% % Display Results
% disp('Initial θ0     -->      Final Estimate     -->     Abs Error');
% for i = 1:n_combos
%     fprintf('[%.2f %.2f %.2f]   -->   [%.4f %.4f %.4f]   -->   [%.4f %.4f %.4f]\n', ...
%         combinations(i,1), combinations(i,2), combinations(i,3), ...
%         final_thetas(i,1), final_thetas(i,2), final_thetas(i,3), ...
%         errors(i,1), errors(i,2), errors(i,3));
% end

% % 3D Plot of estimation error vs θ0
% figure;
% scatter3(combinations(:,1), combinations(:,2), combinations(:,3), ...
%     80, vecnorm(errors,2,2), 'filled');
% xlabel('\theta_0(1) = m̂_0');
% ylabel('\theta_0(2) = b̂_0');
% zlabel('\theta_0(3) = k̂_0');
% title('Total Estimation Error vs Initial \theta_0');
% colorbar;
% grid on;

