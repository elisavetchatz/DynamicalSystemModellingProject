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

% Time Setup
T_sample = 0.1; 
t_sim = 0:T_sample:20;

% Simulate System
[t, q, qdot, u] = simulate_true_system(m, L, c, g, A0, omega, x0, t_sim);
Q = [q, qdot];

% Parameter Estimation (Clean Signals)
estimations = ls_estimation(Q, t_sim, qdot_measurable); 
L_est = estimations(1);
m_est = estimations(2);
c_est = estimations(3);

% Simulate with Estimated Parameters
[t_cont, q_samples, qdot_samples, u_samples] = simulate_true_system(m_est, L_est, c_est, g, A0, omega, x0, t_sim);

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

fprintf('\n--- Parameter Comparison: Without vs With Noise ---\n');
fprintf('%-20s %-15s %-15s\n', 'Parameter', 'Noiseless', 'Noisy');
fprintf('%-20s %-15.4f %-15.4f\n', 'L [m]', L_est, L_est_n);
fprintf('%-20s %-15.4f %-15.4f\n', 'm [kg]', m_est, m_est_n);
fprintf('%-20s %-15.4f %-15.4f\n', 'c [Nm/s]', c_est, c_est_n);

[t_noisy, q_est_noisy, qdot_est_noisy, u_noisy] = simulate_true_system(m_est_n, L_est_n, c_est_n, g, A0, omega, x0, t_sim);

% Position 
figure;
plot(t_sim, q, 'b', 'LineWidth', 2); hold on;
plot(t_cont, q_samples, '--g', 'LineWidth', 2);
plot(t_noisy, q_est_noisy, '--r', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Position q(t)');
legend('True', 'Estimation (Clean)', 'Estimation (Noisy)');
title(sprintf('Comparison of q, qdot\\_measurable = %d', qdot_measurable));
grid on;

% Velocity 
figure;
plot(t_sim, qdot, 'b', 'LineWidth', 2); hold on;
plot(t_cont, qdot_samples, '--g', 'LineWidth', 2);
plot(t_noisy, qdot_est_noisy, '--r', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Velocity q̇(t)');
legend('True', 'Estimation (Clean)', 'Estimation (Noisy)');
title(sprintf('Comparison of qdot, qdot\\_measurable = %d', qdot_measurable));
grid on;

data = [L_est,     L_est_n,     L;
        m_est,     m_est_n,     m;
        c_est,     c_est_n,     c];
colors = [ 
        0, 255, 0 % Green
        255, 0, 0; % Red
        0, 0, 255; % Blue
] / 255;
figure;
b = bar(data); 
for k = 1:length(b)
    b(k).FaceColor = colors(k, :);
end
set(gca, 'xticklabel', {'L','m','c'});
legend('Noiseless', 'Noisy', 'True', 'Location', 'northwest');
title(sprintf('Comparison of Estimated Parameters, qdot\\_measurable = %d', qdot_measurable));
xlabel('Parameters');
ylabel('Estimated Value');
grid on;
