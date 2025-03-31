clc; clear; close all;
addpath('C:\Users\30690\DynamicalSystemModellingandSimulation-Projects\Part 1')
addpath('../Part 1')

qdot_measurable = true; % true -> 2a, false -> 2b

% System Parameters
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;
x0 = [0; 0]; % Initial conditions: [q(0); q̇(0)]

% Control Input
u_func = @(t) A0 * sin(omega * t);

% Time Setup
% Sampling
T_sample = 0.1; 
t_sim = 0:T_sample:20;

% System Simulation
[t, X] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func), t_sim, x0);
q = X(:,1);
qdot = X(:,2);
Q = [q, qdot];

%% m, L, c Parameter Estimation - x(t) and u(t) measurable
% Least Squares Estimation
estimations = ls_estimation(Q, t_sim, qdot_measurable); 
L_est = estimations(1);
m_est = estimations(2);
c_est = estimations(3); 

% System Simulation with Estimated Parameters
[t_cont, X_sample] = ode45(@(t, x) system_dynamics(t, x, m_est, L_est, c_est, g, u_func), t_sim, x0);
q_samples = X_sample(:,1);
qdot_samples = X_sample(:,2);
error_est = q - q_samples;
error_est_dot = qdot - qdot_samples;
u_samples = u_func(t_sim);

%% Plotting
% Plot of angle q(t)
figure;
plot(t, q, 'b', 'LineWidth', 2); hold on;
plot(t, q_samples, 'g--', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Angle q(t) [rad]');
legend('True q(t)', 'Estimated q̂(t)');
title('Comparison of Angular Position q(t)');
grid on;

% Plot of angular velocity q̇(t)
figure;
plot(t, qdot, 'b', 'LineWidth', 2); hold on;
plot(t, qdot_samples, 'g--', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Angular Velocity q̇(t) [rad/s]');
legend('True q̇(t)', 'Estimated q̇̂(t)');
title('Comparison of Angular Velocity q̇(t)');
grid on;

% Plot of estimation errors and input
figure;

subplot(3,1,1);
plot(t, q - q_samples, 'r', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Error e_q(t)');
title('Estimation Error in Angle: e_q(t) = q(t) − q̂(t)');
grid on;

subplot(3,1,2);
plot(t, qdot - qdot_samples, 'm', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Error e_{q̇}(t)');
title('Estimation Error in Angular Velocity: e_{q̇}(t) = q̇(t) − q̇̂(t)');
grid on;

subplot(3,1,3);
plot(t, u_func(t), 'k', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('u(t) [Nm]');
title('Control Input u(t)');
grid on;

% UITable
param_names = {'Length L [m]'; 'Mass m [kg]'; 'Damping c [Nm/s]'};
real_values = [L; m; c];
estimated_values = [L_est; m_est; c_est];

tableData = [param_names, num2cell(real_values), num2cell(estimated_values)];
figure('Name', 'Parameter Estimation Table', 'NumberTitle', 'off', ...
       'Position', [500 300 500 120]);

uitable('Data', tableData, ...
        'ColumnName', {'Parameter', 'True Value', 'Estimated Value'}, ...
        'ColumnWidth', {150, 100, 120}, ...
        'FontSize', 12, ...
        'Position', [20 10 460 90]);
