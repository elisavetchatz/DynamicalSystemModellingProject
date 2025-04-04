clc; clear; close all;
addpath('C:\Users\30690\DynamicalSystemModellingandSimulation-Projects\Part 1')
addpath('../Part 1')

qdot_measurable = true; % true -> 2a, false -> 2b
rng(40);  

% System Parameters
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;
x0 = [0; 0]; 
true_params = [L, m, c];

% Time Setup
T_sample = 0.1; 
t_sim = 0:T_sample:20;

% Simulate System
[t, q, qdot, u] = simulate_system(m, L, c, g, A0, omega, x0, t_sim);
Q = [q, qdot];

estimations = ls_estimation(Q, t_sim, qdot_measurable, A0); 
L_est = estimations(1);
m_est = estimations(2);
c_est = estimations(3);

% Simulate with Estimated Parameters
% [t_cont, q_samples, qdot_samples, u_samples] = simulate_system(m_est, L_est, c_est, g, A0, omega, x0, t_sim);

%% Task 3c: Effect of Input Amplitude A0 on Estimation Accuracy
A0_values = 0.5:0.5:10;

errors_L_A0 = zeros(size(A0_values));
errors_m_A0 = zeros(size(A0_values));
errors_c_A0 = zeros(size(A0_values));

L_estimates = zeros(size(A0_values));
m_estimates = zeros(size(A0_values));
c_estimates = zeros(size(A0_values));

condition_numbers = zeros(size(A0_values));

for i = 1:length(A0_values)
    A0_test = A0_values(i);
    
    % Simulate system
    [t_temp, q_t, qdot_t, u_t] = simulate_system(m, L, c, g, A0_test, omega, x0, t_sim);
    X_input = [q_t, qdot_t];
    
    % Estimate parameters
    est = ls_estimation(X_input, t_temp, qdot_measurable, A0_test);
    
    % Store absolute errors
    errors_L_A0(i) = abs(est(1) - L);
    errors_m_A0(i) = abs(est(2) - m);
    errors_c_A0(i) = abs(est(3) - c);

    L_estimates(i) = est(1);
    m_estimates(i) = est(2);
    c_estimates(i) = est(3);
end

%% Plotting Results
color_L = [0, 0, 1];
color_m = [0, 1, 0];
color_c = [1, 0, 0];

% Errors vs A0 
figure;
plot(A0_values, errors_L_A0, '-+', 'LineWidth', 2, 'Color', color_L); hold on;
plot(A0_values, errors_m_A0, '-x', 'LineWidth', 2, 'Color', color_m);
plot(A0_values, errors_c_A0, '-*', 'LineWidth', 2, 'Color', color_c);
yline(0, '--k', 'LineWidth', 1.5);
xlabel('Input Amplitude A0');
ylabel('Estimation Error');
legend('Error in L', 'Error in m', 'Error in c');
title(sprintf('Parameter Estimation Error vs Input Amplitude A0, qdot\\_measurable = %d', qdot_measurable'));
grid on;
ylim([-1, max([errors_L_A0, errors_m_A0, errors_c_A0])*1.1]);

% Plot estimated parameters vs A0
figure;
subplot(3,1,1);
plot(A0_values, L_estimates, '-+', 'LineWidth', 1.5, 'Color', color_L); hold on;
yline(L, '--', 'True L', 'LineWidth', 1.5, 'Color', 'k');
ylabel('Estimated L');
title(sprintf('Estimated Parameters vs Input Amplitude A0, qdot\\_measurable = %d', qdot_measurable'));
grid on;
subplot(3,1,2);
plot(A0_values, m_estimates, '-x', 'LineWidth', 1.5, 'Color', color_m); hold on;
yline(m, '--', 'True m', 'LineWidth', 1.5, 'Color', 'k');
ylabel('Estimated m');
grid on;
subplot(3,1,3);
plot(A0_values, c_estimates, '-*', 'LineWidth', 1.5, 'Color', color_c); hold on;
yline(c, '--', 'True c', 'LineWidth', 1.5, 'Color', 'k');
xlabel('A_0'); ylabel('Estimated c');
grid on;
