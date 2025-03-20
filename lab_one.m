clc; clear; close all;

% Δεδομένα του προβλήματος
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;

% Ορισμός του συστήματος εξισώσεων
A = [0 1; -g/L -c/(m*L^2)];
B = [0; 1/(m*L^2)];
x0 = [0; 0]; % Αρχικές συνθήκες

% Χρονική προσομοίωση
dt = 1e-3;
tspan = 0:dt:20;

% Συνάρτηση εισόδου
u = @(t) A0 * sin(omega * t);

% Συνάρτηση για τον ODE Solver
dxdt = @(t, x) A*x + B*u(t);

% Επίλυση με ODE45
[t, X] = ode45(dxdt, tspan, x0);

% Διαγράμματα
figure;
subplot(2,1,1);
plot(t, X(:,1), 'b', 'LineWidth', 1.5);
xlabel('Χρόνος [sec]'); ylabel('q(t) [rad]');
title('Γωνία εκτροπής q(t)');
grid on;

subplot(2,1,2);
plot(t, X(:,2), 'r', 'LineWidth', 1.5);
xlabel('Χρόνος [sec]'); ylabel('dq/dt [rad/sec]');
title('Γωνιακή ταχύτητα dq/dt');
grid on;
