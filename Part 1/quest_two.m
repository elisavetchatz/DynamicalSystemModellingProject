clc; clear; close all;

% System Parameters
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;
x0 = [0; 0];

% System Dynamics
A = [0 1; -g/L -c/(m*L^2)];
B = [0; 1/(m*L^2)];

T_sample = 0.1; 
t_sim = 0:T_sample:20;
dt = 1e-4;
t_cont = 0:dt:20;

u = @(t) A0 * sin(omega * t);
xdot = @(t, x) A*x + B*u(t);
[t_cont, X] = ode45(xdot, t_cont, x0);
q = X(:,1);
qdot = X(:,2);

q_samples = interp1(t_cont, q, t_sim);
qdot_samples = interp1(t_cont, qdot, t_sim);
qddot_samples = gradient(qdot_samples, T_sample);
u_samples = u(t_sim);

Q = [q_samples', qdot_samples', u_samples'];
estimations = least_squares_estimation(Q);

figure;
plot(t_cont, q, 'b', 'LineWidth', 2); hold on;
plot(t_cont, estimations(6), 'g--', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('q(t) [rad]');
legend('Real', 'Estimated');
title('Deflection Angle Comparison');
grid on;

figure;
plot(t_cont, qdot, 'b', 'LineWidth', 2); hold on;
plot(t_cont, estimations(7), 'g--', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('qdot(t) [rad/sec]');
legend('Real', 'Estimated');
title('Angular Velocity Comparison');
grid on;

figure;
subplot(2,1,1);
plot(t_cont, error_est, 'r', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('Error e_q(t)');
title('Estimation Error q(t)');
grid on;

subplot(2,1,2);
plot(t_cont, u(t_cont), 'm', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('u(t) [Nm]');
title('Control Input u(t)');
grid on;


% % ========================
% % Estimation with only q(t) and u(t)
% % ========================
% Phi2 = [q_samples(2:end-1)' q_samples(1:end-2)' u_samples(2:end-1)'];
% y2 = q_samples(3:end)';

% theta2 = (Phi2' * Phi2) \ (Phi2' * y2);

% fprintf('\nEstimation with only q(t) and u(t):\n');
% fprintf('L_est2 = %.4f m\n', g/theta2(1));


