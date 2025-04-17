clc; clear; close all;

sinc_use = false;

dt = 0.0001; 
t_sim = 0:dt:50; 

if sinc_use
    u_func = @(t) 2.5 * sin(t);
    u = 2.5 * sin(t_sim(:)); % ensures it's a column
else 
    u_func = @(t) 2.5;
    u = 2.5 * ones(length(t_sim), 1);  % ensures it's a column
    %u = arrayfun(u_func, t_sim(:));
end

m = 1.315;
b = 0.225;
k = 0.725;

x0 = [0; 0];

system_fun = @(t, x) system_dynamics(t, x, m, k, b, u_func);

[t, X] = ode45(system_fun, t_sim, x0);
x1 = X(:, 1); 
x2 = X(:, 2);

%% Parameter estimation using Gradient Method with filtering
lambda = 1;       % filter constant
gamma = 100;        % learning rate
theta0 = [0, 0, 0];

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
plot(t_sim, x1, 'b', 'DisplayName', 'x1 (True)', 'LineWidth', 1.5);
hold on;
plot(t_sim, x1_est, 'b--', 'DisplayName', 'x1 (Estimated)', 'LineWidth', 1.5);
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
title('Estimation Error in Angular Velocity');
grid on;
subplot(3,1,3);
plot(t, u, 'k', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('u(t) [Nm]');
title('Control Input u(t)');
grid on;

figure('Name','Parameter Estimation History','NumberTitle','off');
% 1. m parameter
subplot(3,1,1);
plot(t_sim, theta_hist(:,1), 'r', 'LineWidth', 1.5);
hold on;
yline(m, '--r', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('\hat{m}(t)');
title('Estimation of Mass Parameter m(t)');
legend({'Estimated m', 'True m'});
grid on;
% 2. b parameter
subplot(3,1,2);
plot(t_sim, theta_hist(:,2), 'g', 'LineWidth', 1.5);
hold on;
yline(b, '--g', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('\hat{b}(t)');
title('Estimation of Damping Parameter b(t)');
legend({'Estimated b', 'True b'});
grid on;
% 3. k parameter
subplot(3,1,3);
plot(t_sim, theta_hist(:,3), 'b', 'LineWidth', 1.5);
hold on;
yline(k, '--b', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('\hat{k}(t)');
title('Estimation of Stiffness Parameter k(t)');
legend({'Estimated k', 'True k'});
grid on;

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