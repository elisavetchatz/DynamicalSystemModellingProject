clc; clear; close all;

m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;

A = [0 1; -g/L -c/(m*L^2)];
B = [0; 1/(m*L^2)];
x0 = [0; 0]; 

dt = 1e-4;
tspan = 0:dt:20;

u = @(t) A0 * sin(omega * t);

xdot = @(t, x) A*x + B*u(t);
[t, X] = ode45(xdot, tspan, x0);

figure;
subplot(2,1,1);
plot(t, X(:,1), 'b', 'LineWidth', 2);
xlabel('Time [sec]'); 
ylabel('q(t) [rad]');
title('Deflection Angle q(t)');
grid on;

subplot(2,1,2);
plot(t, X(:,2), 'r', 'LineWidth', 2);
xlabel('Time [sec]'); 
ylabel('$\dot{q}$ [rad/sec]', 'Interpreter', 'latex');
title('Angular Velocity $\dot{q}(t)$', 'Interpreter', 'latex');
grid on;

