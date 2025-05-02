clear;
clc;
close all;

%% Global parameters
global a1 a2 a3 b G u

% True system parameters
a1 = 1.315;
a2 = 0.725;
a3 = 0.225;
b  = 1.175;

% Simulation time
time = 0:0.1:20;    

% Input signal
u = @(t) 2.5*sin(t);

% Initial conditions
% [r(0) r_dot(0) theta1_hat(0) theta2_hat(0) theta3_hat(0) theta4_hat(0)]
initial_cond = [0 0 0 0 0 0];

% Mode: 0 (no disturbance)
mode = 0;

%% --- Manual Gain Matrix G ---
G = diag([10, 10, 10, 10]);  % Μπορείς να αλλάξεις αυτές τις τιμές χειροκίνητα

%% --- Simulation with Manual G ---

[t_out, var_out] = ode45(@(t,var) estimation_func(t,var,mode), time, initial_cond);

% Extract
r = var_out(:,1);
r_dot = var_out(:,2);
theta1_hat = var_out(:,3);
theta2_hat = var_out(:,4);
theta3_hat = var_out(:,5);
theta4_hat = var_out(:,6);

theta_hat = [theta1_hat, theta2_hat, theta3_hat, theta4_hat];

% True parameters
theta_true = [-a1; -a2; a3; b];

% Regressors
phi1 = r_dot;
phi2 = sin(r);
phi3 = (r_dot).^2 .* sin(2*r);
phi4 = arrayfun(u, t_out);

phi = [phi1, phi2, phi3, phi4];

% Estimated output
r_ddot_est = sum(theta_hat .* phi, 2);

% Real output
r_ddot_true = zeros(size(t_out));
for i = 1:length(t_out)
    r_ddot_true(i,1) = system_dynamics(t_out(i), [r(i); r_dot(i)], mode);
end

% Estimated r(t) by double integration
r_est = cumtrapz(t_out, cumtrapz(t_out, r_ddot_est));

% Error
e_r = r - r_est;

%% --- Plotting ---

% 1. r(t) vs r̂(t)
figure;
plot(t_out, r, 'b-', 'LineWidth', 1.5, 'DisplayName', '$r(t)$ Actual');
hold on;
plot(t_out, r_est, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\hat{r}(t)$ Estimated');
xlabel('Time [s]');
ylabel('Roll Angle [rad]');
legend('Interpreter','latex','Location','best');
title('Actual vs Estimated Roll Angle','Interpreter','latex');
grid on;
sgtitle('Roll Angle Tracking','Interpreter','latex','FontSize',18);

% 2. Error plot
figure;
plot(t_out, e_r, 'k-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Tracking Error [rad]');
title('Error $e_r(t) = r(t) - \hat{r}(t)$','Interpreter','latex');
grid on;

% 3. Parameter estimation
figure;
subplot(4,1,1);
plot(t_out, theta1_hat, 'r', 'LineWidth', 1.5);
hold on;
yline(theta_true(1), '--r');
ylabel('$\theta_1$','Interpreter','latex');
legend('Estimated','True','Interpreter','latex');
grid on;

subplot(4,1,2);
plot(t_out, theta2_hat, 'g', 'LineWidth', 1.5);
hold on;
yline(theta_true(2), '--g');
ylabel('$\theta_2$','Interpreter','latex');
legend('Estimated','True','Interpreter','latex');
grid on;

subplot(4,1,3);
plot(t_out, theta3_hat, 'b', 'LineWidth', 1.5);
hold on;
yline(theta_true(3), '--b');
ylabel('$\theta_3$','Interpreter','latex');
legend('Estimated','True','Interpreter','latex');
grid on;

subplot(4,1,4);
plot(t_out, theta4_hat, 'm', 'LineWidth', 1.5);
hold on;
yline(theta_true(4), '--m');
ylabel('$\theta_4$','Interpreter','latex');
xlabel('Time [s]');
legend('Estimated','True','Interpreter','latex');
grid on;

sgtitle('Parameter Estimations','Interpreter','latex','FontSize',18);
