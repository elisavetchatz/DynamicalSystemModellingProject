clc; clear; close all;
addpath('C:\Users\30690\DynamicalSystemModellingandSimulation-Projects\Part 1')
addpath('../Part 1')

qdot_measurable = true; % true -> 2a, false -> 2b
noise_percenatge = 0.05; 

rng(40);  
% System Parameters
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;
x0 = [0; 0]; 

% Control Input
u_func = @(t) A0 * sin(omega * t);

% Time Setup
T_sample = 0.1; 
t_sim = 0:T_sample:20;

% Simulate System
[t, X] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func), t_sim, x0);
q = X(:,1);
qdot = X(:,2);
Q = [q, qdot];

% Parameter Estimation (Clean Signals)
estimations = ls_estimation(Q, t_sim, qdot_measurable); 
L_est = estimations(1);
m_est = estimations(2);
c_est = estimations(3);

% Simulate with Estimated Parameters
[t_cont, X_sample] = ode45(@(t, x) system_dynamics(t, x, m_est, L_est, c_est, g, u_func), t_sim, x0);
q_samples = X_sample(:, 1);
qdot_samples = X_sample(:, 2);
u_samples = u_func(t_sim);

%% Task 3b: Effect of Sampling Period Ts on Estimation Accuracy

Ts_values = 0.01:0.02:0.5;  % Sampling periods to test
true_params = [L, m, c];

errors_L = zeros(size(Ts_values));
errors_m = zeros(size(Ts_values));
errors_c = zeros(size(Ts_values));

for i = 1:length(Ts_values)
    Ts = Ts_values(i);
    t_local = 0:Ts:20;

    % Simulate system at current Ts
    [~, X_local] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func), t_local, x0);
    q_l = X_local(:,1);
    qdot_l = X_local(:,2);
    X_input = [q_l, qdot_l];

    % Estimate parameters
    est = ls_estimation(X_input, t_local, qdot_measurable);
    
    % Store absolute errors
    errors_L(i) = abs(est(1) - L);
    errors_m(i) = abs(est(2) - m);
    errors_c(i) = abs(est(3) - c);
end

L_estimates_Ts = zeros(size(Ts_values));
m_estimates_Ts = zeros(size(Ts_values));
c_estimates_Ts = zeros(size(Ts_values));

for i = 1:length(Ts_values)
    Ts = Ts_values(i);
    t_local = 0:Ts:20;
    [~, X_local] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func), t_local, x0);
    est = ls_estimation([X_local(:,1), X_local(:,2)], t_local, qdot_measurable);
    
    L_estimates_Ts(i) = est(1);
    m_estimates_Ts(i) = est(2);
    c_estimates_Ts(i) = est(3);
end

%% Plotting Results
% Errors vs Ts 
color_L = [0, 0, 1];
color_m = [0, 1, 0];
color_c = [1, 0, 0];

figure;
plot(Ts_values, errors_L, '-+', 'LineWidth', 1.5, 'Color', color_L); hold on;
plot(Ts_values, errors_m, '-x', 'LineWidth', 1.5, 'Color', color_m);
plot(Ts_values, errors_c, '-*', 'LineWidth', 1.5, 'Color', color_c);
yline(0, '--', 'Zero Error', 'Color', 'k', 'LineWidth', 1.5);
xlabel('Sampling Period Ts [sec]');
ylabel('Estimation Error');
legend('Error in L', 'Error in m', 'Error in c');
title('Parameter Estimation Error vs Sampling Period Ts');
grid on;

% Estimated Parameters vs Ts
figure;
subplot(3,1,1);
plot(Ts_values, L_estimates_Ts, '-+', 'Color', color_L, 'LineWidth', 1.5); hold on;
yline(L, '--', 'True L', ...
    'Color', 'k', ...
    'LineWidth', 1.5, ...
    'LabelHorizontalAlignment', 'right', ...
    'LabelVerticalAlignment', 'bottom');
ylabel('Estimated L');
grid on;

subplot(3,1,2);
plot(Ts_values, m_estimates_Ts, '-x', 'Color', color_m, 'LineWidth', 1.5); hold on;
yline(m, '--', 'True m', 'Color', 'k', 'LineWidth', 1.5);
ylabel('Estimated m');
grid on;

subplot(3,1,3);
plot(Ts_values, c_estimates_Ts, '-*', 'Color', color_c, 'LineWidth', 1.5); hold on;
yline(L, '--', 'True c', ...
    'Color', 'k', ...
    'LineWidth', 1.5, ...
    'LabelHorizontalAlignment', 'right', ...
    'LabelVerticalAlignment', 'bottom');
xlabel('Sampling Period T_s [sec]');
ylabel('Estimated c');
grid on;
sgtitle('Estimated Parameters vs Sampling Period T_s');
