%% Quest 1, Task a: Gradient-Steepest Descent Estimation

clear; clc; close all;

% Input Parameters
use_sine = true; % false for constant input (i), true for sinusoidal input (ii)

% Simulation Parameters
T = 20;
dt = 0.001;
t = 0:dt:T;
m = 1.315;
b = 0.225;
k = 0.725;

% System Simulation
X = system_dynamics(t, x, m, b, k, use_sine);


% Gradient Estimator
[m_hat, b_hat, k_hat, x_hat] = gr_estimation(X, u, dt);
ex = x - x_hat;

figure;
plot(t, x, 'b', t, x_hat, 'b--');
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

