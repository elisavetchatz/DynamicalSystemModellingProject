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
true_params = [L, m, c];

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

estimations = ls_estimation(Q, t_sim, qdot_measurable); 
L_est = estimations(1);
m_est = estimations(2);
c_est = estimations(3);

% Simulate with Estimated Parameters
[t_cont, X_sample] = ode45(@(t, x) system_dynamics(t, x, m_est, L_est, c_est, g, u_func), t_sim, x0);
q_samples = X_sample(:, 1);
qdot_samples = X_sample(:, 2);
u_samples = u_func(t_sim);

%% Task 3c: Effect of Input Amplitude A0 on Estimation Accuracy
A0_values = 0.5:0.5:10;

errors_L_A0 = zeros(size(A0_values));
errors_m_A0 = zeros(size(A0_values));
errors_c_A0 = zeros(size(A0_values));

L_estimates = zeros(size(A0_values));
m_estimates = zeros(size(A0_values));
c_estimates = zeros(size(A0_values));

for i = 1:length(A0_values)
    A0_test = A0_values(i);
    
    % Redefine input function with current A0
    u_func_temp = @(t) A0_test * sin(omega * t);
    
    % Simulate system
    [~, X_temp] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func_temp), t_sim, x0);
    q_t = X_temp(:,1);
    qdot_t = X_temp(:,2);
    X_input = [q_t, qdot_t];
    
    % Estimate parameters
    est = ls_estimation(X_input, t_sim, qdot_measurable);
    
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
title('Parameter Estimation Error vs Input Amplitude A0');
grid on;
ylim([-1, max([errors_L_A0, errors_m_A0, errors_c_A0])*1.1]);

% Plot estimated parameters vs A0
figure;
subplot(3,1,1);
plot(A0_values, L_estimates, '-+', 'LineWidth', 1.5, 'Color', color_L); hold on;
yline(L, '--', 'True L', 'LineWidth', 1.5, 'Color', 'k');
ylabel('Estimated L');
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
sgtitle('Estimated Parameters vs Input Amplitude A_0');
