clc; clear; close all;

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

%% Task 3c: Effect of Input Amplitude A0 on Estimation Accuracy
Ts_fixed = 0.1;
t_fixed = 0:Ts_fixed:20;
A0_values = 0.5:0.5:10;
true_params = [L, m, c];

errors_L_A0 = zeros(size(A0_values));
errors_m_A0 = zeros(size(A0_values));
errors_c_A0 = zeros(size(A0_values));

for i = 1:length(A0_values)
    A0_test = A0_values(i);
    
    % Redefine input function with current A0
    u_func_temp = @(t) A0_test * sin(omega * t);
    
    % Simulate system
    [~, X_temp] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func_temp), t_fixed, x0);
    q_t = X_temp(:,1);
    qdot_t = X_temp(:,2);
    X_input = [q_t, qdot_t];
    
    % Estimate parameters
    est = ls_estimation(X_input, t_fixed, qdot_measurable);
    
    % Store absolute errors
    errors_L_A0(i) = abs(est(1) - L);
    errors_m_A0(i) = abs(est(2) - m);
    errors_c_A0(i) = abs(est(3) - c);
end

% --- Plotting Errors vs A0 ---
figure;
plot(A0_values, errors_L_A0, '-+', 'LineWidth', 2); hold on;
plot(A0_values, errors_m_A0, '-x', 'LineWidth', 2);
plot(A0_values, errors_c_A0, '-*', 'LineWidth', 2);
xlabel('Input Amplitude A0');
ylabel('Estimation Error');
legend('Error in L', 'Error in m', 'Error in c');
title('Parameter Estimation Error vs Input Amplitude A0');
grid on;
