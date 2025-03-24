clc; clear; close all;

m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;

A = [0 1; -g/L -c/(m*L^2)];
B = [0; 1/(m*L^2)];

Ts = 0.1;
t_sim = 0:Ts:20;
dt = 1e-4;
t_cont = 0:dt:20;

u = @(t) A0 * sin(omega * t);
xdot = @(t, x) A*x + B*u(t);
[t_cont, X] = ode45(xdot, t_cont, [0; 0]);

q = X(:,1);
qdot = X(:,2);

% add custom function
q_samples = interp1(t_cont, q, t_sim);
qdot_samples = interp1(t_cont, qdot, t_sim);
qddot_samples = gradient(qdot_samples, Ts);
u_samples = u(t_sim);

Phi = [-q_samples', -qdot_samples', u_samples']; % Regression matrix
y = qddot_samples'; % Observed acceleration

% Parameter estimation
theta = (Phi' * Phi) \ (Phi' * y);

L_est = g / theta(1);
mL2_est = 1 / theta(3);
c_est = theta(2) * mL2_est;
m_est = mL2_est / (L_est^2);

fprintf('Parameter Estimation:\n');
fprintf('L_est = %.4f m\n', L_est);
fprintf('m_est = %.4f kg\n', m_est);
fprintf('c_est = %.4f Nm/sec\n', c_est);

A_est = [0 1; -g/L_est -c_est/(m_est*L_est^2)];
B_est = [0; 1/(m_est*L_est^2)];
dxdt_est = @(t, x) A_est*x + B_est*u(t);
[t_cont, X_est] = ode45(dxdt_est, t_cont, [0; 0]);

q_est = X_est(:,1);
qdot_est = X_est(:,2);

error_est = q - q_est;

figure;
plot(t_cont, q, 'b', 'LineWidth', 2); hold on;
plot(t_cont, q_est, 'g--', 'LineWidth', 2);
xlabel('Time [sec]'); ylabel('q(t) [rad]');
legend('Real', 'Estimated');
title('Deflection Angle Comparison');
grid on;

figure;
plot(t_cont, qdot, 'b', 'LineWidth', 2); hold on;
plot(t_cont, qdot_est, 'g--', 'LineWidth', 2);
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


% ========================
% Estimation with only q(t) and u(t)
% ========================
Phi2 = [q_samples(2:end-1)' q_samples(1:end-2)' u_samples(2:end-1)'];
y2 = q_samples(3:end)';

theta2 = (Phi2' * Phi2) \ (Phi2' * y2);

fprintf('\nEstimation with only q(t) and u(t):\n');
fprintf('L_est2 = %.4f m\n', g/theta2(1));


