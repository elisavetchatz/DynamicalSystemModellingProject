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

% System Simulation
dt = 1e-5;
tspan = 0:dt:20;
u = @(t) A0 * sin(omega * t);
xdot = @(t, x) A*x + B*u(t);
[t, X] = ode45(xdot, tspan, x0);
q = X(:,1);
qdot = X(:,2);

%% m, L, c Parameter Estimation - x(t) and u(t) measurable

% Sampling
T_sample = 0.1; 
t_sim = 0:T_sample:20;
[t_cont, X_sample] = ode45(xdot, t_sim, x0);
q_samples = X_sample(:,1);
qdot_samples = X_sample(:,2);
u_samples = u(t_sim);

% Least Squares Estimation
y = q_samples;
[estimations, model] = least_squares_estimation(y, t_sim);
L_est = estimations(1);
m_est = estimations(2);
c_est = estimations(3); 
y_est = model(:,1);
error_est = model(:,2);

% Simulation with Estimated Parameters
A_est = [0 1; -g/L_est -c_est/(m_est*L_est^2)];
B_est = [0; 1/(m_est*L_est^2)];
xdot_est = @(t, x) A_est*x + B_est*u(t);
[t_est, X_est] = ode45(xdot_est, tspan, x0);
q_est = X_est(:,1);
qdot_est = X_est(:,2);

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
