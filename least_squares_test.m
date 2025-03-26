clc; clear; close all;

%% True system parameters
m_true = 0.75;
L_true = 1.25;
c_true = 0.15;
g = 9.81;

A = 4;
omega = 2;
u_func = @(t) A * sin(omega * t);

% Time setup
T_s = 0.1;
t = 0:T_s:20;
N = length(t);

%% Simulate system to get q(t)
x0 = [0; 0];
[~, X] = ode45(@(t,x) real_system(t,x,m_true,L_true,c_true,g,u_func), t, x0);
q = X(:,1);
u = A * sin(omega * t)';

%% Define filter: Λ(s) = (s + 1)^2
lamda = [1 2 1];  % Polynomial of (s + 1)^2

% Create transfer functions for:
% - D1 = s^2 / Λ(s)
% - D2 = s / Λ(s)
% - D3 = 1 / Λ(s)
D1 = tf([1 0 0], lamda);  % filtered ddot(q)
D2 = tf([0 1 0], lamda);  % filtered dot(q)
D3 = tf([0 0 1], lamda);  % filtered q

%% Apply filters to q(t) and u(t)
phi1 = lsim(D1, q, t);  % filtered ddot(q)
phi2 = lsim(D2, q, t);  % filtered dot(q)
phi3 = lsim(D3, q, t);  % filtered q
yf    = lsim(D3, u, t); % filtered u(t)

Phi = [phi1, phi2, phi3];

%% Least Squares Estimation
theta_hat = (Phi' * Phi) \ (Phi' * yf);

theta1 = theta_hat(1);  % mL^2
theta2 = theta_hat(2);  % c
theta3 = theta_hat(3);  % mgL

% Recover physical parameters
L_est = (theta1 * g) / theta3;
m_est = theta1 / L_est^2;
c_est = theta2;

%% Display results
fprintf("Estimated parameters (2b filtered LS):\n");
fprintf("  L = %.4f (true: %.4f)\n", L_est, L_true);
fprintf("  m = %.4f (true: %.4f)\n", m_est, m_true);
fprintf("  c = %.4f (true: %.4f)\n", c_est, c_true);

%% Simulate system using estimated parameters to get q̂(t)
[~, X_est] = ode45(@(t,x) real_system(t,x,m_est,L_est,c_est,g,u_func), t, x0);
q_est = X_est(:,1);
e = q - q_est;

%% Plot comparison
figure;

subplot(3,1,1);
plot(t, q, 'b', 'LineWidth', 1.5); hold on;
plot(t, q_est, 'r--', 'LineWidth', 1.5);
legend('True q(t)', 'Estimated \hat{q}(t)');
ylabel('q(t)');
title('True vs Estimated q(t) – Filtered LS (2b)');
grid on;

subplot(3,1,2);
plot(t, e, 'k', 'LineWidth', 1.5);
ylabel('Error e(t)');
title('Estimation Error: e(t) = q(t) - \hat{q}(t)');
grid on;

subplot(3,1,3);
plot(t, u, 'g', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('u(t)');
title('Input Signal u(t)');
grid on;

%% System dynamics
function dxdt = real_system(t, x, m, L, c, g, u_func)
    q = x(1);
    q_dot = x(2);
    u = u_func(t);
    q_ddot = (1 / (m * L^2)) * (u - c * q_dot - m * g * L * q);
    dxdt = [q_dot; q_ddot];
end