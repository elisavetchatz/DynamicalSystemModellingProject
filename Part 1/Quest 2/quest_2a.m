clc; clear; close all;

% System Parameters
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;

% System Dynamics
A = [0 1; -g/L -c/(m*L^2)];
B = [0; 1/(m*L^2)];
x0 = [0; 0];

% Control Input
u_func = @(t) A0 * sin(omega * t);

% Time Setup
dt = 1e-5;
tspan = 0:dt:20;

% System Simulation
xdot = @(t, x) A*x + B*u(t);
[t, X] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func), tspan, x0);
q = X(:,1);
qdot = X(:,2);

%% m, L, c Parameter Estimation - x(t) and u(t) measurable
% Sampling
T_sample = 0.1; 
t_sim = 0:T_sample:20;

% Least Squares Estimation
[estimations, model] = least_squares_estimation(q, t_sim);
L_est = estimations(1);
m_est = estimations(2);
c_est = estimations(3); 

% System Simulation with Estimated Parameters
[t_cont, X_sample] = ode45(@(t, x) system_dynamics(t, x, m_est, L_est, c_est, g, u_func), t_sim, x0);
q_samples = X_sample(:,1);
qdot_samples = X_sample(:,2);
error_est = q - q_samples;
u_samples = u(t_sim);


%% Plotting
figure;
plot(tspan, q, 'b', 'LineWidth', 2); hold on;
plot(tspan, q_est, 'g--', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('q(t) [rad]');
legend('Real', 'Estimated');
title('Deflection Angle Comparison');
grid on;

figure;
plot(tspan, qdot, 'b', 'LineWidth', 2); hold on;
plot(tspan, qdot_est, 'g--', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('qdot(t) [rad/sec]');
legend('Real', 'Estimated');
title('Angular Velocity Comparison');
grid on;

figure;
subplot(2,1,1);
plot(tspan, error_est, 'r', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Error e_q(t)');
title('Estimation Error q(t)');
grid on;

subplot(2,1,2);
plot(tspan, u(tspan), 'm', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('u(t) [Nm]');
title('Control Input u(t)');
grid on;
