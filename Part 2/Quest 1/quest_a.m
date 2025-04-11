
% === Main Script for Real-Time Estimation Visualization ===

clear; clc;

%% Simulation Parameters
T = 20;
dt = 0.001;
m_true = 1.315;
b_true = 0.225;
k_true = 0.725;
use_sine = true;

% Run System Simulation
[t, x, x_dot, x_ddot, u] = system_dynamics(use_sine, T, dt, m_true, b_true, k_true);

% Run Gradient Estimator
[m_hat, b_hat, k_hat, x_hat] = gr_estimation(x, x_dot, x_ddot, u, dt);

% Plot Results
ex = x - x_hat;

figure;
plot(t, x, 'b', t, x_hat, 'r--');
legend('x(t)', 'x̂(t)'); title('Actual vs Estimated x(t)'); grid on;

figure;
plot(t, ex);
title('Estimation Error e_x(t)'); ylabel('e_x(t)'); xlabel('Time [s]'); grid on;


figure;
plot(t, m_hat, 'r', t, b_hat, 'g', t, k_hat, 'b'); hold on;
yline(1.315, 'r--', 'm true'); 
yline(0.225, 'g--', 'b true'); 
yline(0.725, 'b--', 'k true'); 
legend('m̂(t)', 'b̂(t)', 'k̂(t)', 'm true', 'b true', 'k true');
title('Parameter Estimates with True Values');
xlabel('Time [s]');
ylabel('Estimated Parameters');
grid on;

