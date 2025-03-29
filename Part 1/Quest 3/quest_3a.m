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

%% Estimation with White Gaussian Noise
% Add ~5% noise
noise_level_q = noise_percenatge * std(q);
noise_level_qdot = noise_percenatge * std(qdot);

q_noisy = q + noise_level_q * randn(size(q));
qdot_noisy = qdot + noise_level_qdot * randn(size(qdot));
X_noisy = [q_noisy, qdot_noisy];

% Estimation with noise
estimations_noisy = ls_estimation(X_noisy, t_sim, qdot_measurable);
L_est_n = estimations_noisy(1);
m_est_n = estimations_noisy(2);
c_est_n = estimations_noisy(3);

[t_noisy, X_noisy_est] = ode45(@(t, x) system_dynamics(t, x, m_est_n, L_est_n, c_est_n, g, u_func), t_sim, x0);
q_est_noisy = X_noisy_est(:, 1);
qdot_est_noisy = X_noisy_est(:, 2);

fprintf('\n--- Parameter Comparison: Without vs With Noise ---\n');
fprintf('%-20s %-15s %-15s\n', 'Parameter', 'Noiseless', 'Noisy');
fprintf('%-20s %-15.4f %-15.4f\n', 'L [m]', L_est, L_est_n);
fprintf('%-20s %-15.4f %-15.4f\n', 'm [kg]', m_est, m_est_n);
fprintf('%-20s %-15.4f %-15.4f\n', 'c [Nm/s]', c_est, c_est_n);

data = [L_est,     L_est_n,     L;
        m_est,     m_est_n,     m;
        c_est,     c_est_n,     c];

% Bar chart
figure;
bar(data);
set(gca, 'xticklabel', {'L','m','c'});
legend('Noiseless', 'Noisy', 'True', 'Location', 'northwest');
title(sprintf('Comparison of Estimated Parameters, qdot\\_measurable = %d', qdot_measurable));
xlabel('Parameters');
ylabel('Estimated Value');
grid on;

% Position 
figure;
plot(t_sim, q, 'k', 'LineWidth', 2); hold on;
plot(t_cont, q_samples, '--b', 'LineWidth', 1.5);
plot(t_noisy, q_est_noisy, ':r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Position q(t)');
legend('True', 'Estimation (Clean)', 'Estimation (Noisy)');
title(sprintf('Comparison of q, qdot\\_measurable = %d', qdot_measurable));
grid on;

% Velocity 
figure;
plot(t_sim, qdot, 'k', 'LineWidth', 2); hold on;
plot(t_cont, qdot_samples, '--b', 'LineWidth', 1.5);
plot(t_noisy, qdot_est_noisy, ':r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Velocity q̇(t)');
legend('True', 'Estimation (Clean)', 'Estimation (Noisy)');
title(sprintf('Comparison of qdot, qdot\\_measurable = %d', qdot_measurable));
grid on;