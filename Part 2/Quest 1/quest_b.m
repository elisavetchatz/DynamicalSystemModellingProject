
% === Main Script for Lyapunov Estimation (Parallel Structure) ===

clear; clc;

%% Parameters
T = 20;
dt = 0.001;
m_true = 1.315;
b_true = 0.225;
k_true = 0.725;
use_sine = true;

% Get system simulation data
[t, x, x_dot, x_ddot, u] = system_dynamics(use_sine, T, dt, m_true, b_true, k_true);

% Run Lyapunov Parallel Estimator
[m_hat, b_hat, k_hat, x_hat] = lyap_parallel_estimator(x, x_dot, x_ddot, u, dt);

% Compute tracking error
ex = x - x_hat;

%% Plot results

figure;
plot(t, x, 'b', t, x_hat, 'r--');
legend('x(t)', 'x̂(t)');
title('Actual vs Estimated x(t) - Lyapunov Parallel');
xlabel('Time [s]');
ylabel('Displacement');
grid on;

figure;
plot(t, ex);
title('Tracking Error e_x(t) - Lyapunov Parallel');
xlabel('Time [s]');
ylabel('Error');
grid on;

figure;
plot(t, m_hat, 'r', t, b_hat, 'g', t, k_hat, 'b'); hold on;
yline(m_true, 'r--', 'm true');
yline(b_true, 'g--', 'b true');
yline(k_true, 'b--', 'k true');
legend('m̂(t)', 'b̂(t)', 'k̂(t)', 'm true', 'b true', 'k true');
title('Parameter Estimates - Lyapunov Parallel');
xlabel('Time [s]');
ylabel('Estimated Parameters');
grid on;
