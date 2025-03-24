clc; clear; close all;

% System Parameters
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;

% Systems Dynamics
A = [0 1; -g/L -c/(m*L^2)];
B = [0; 1/(m*L^2)];
x0 = [0; 0]; 

dt = 1e-5;
tspan = 0:dt:20;

% Input
u = @(t) A0 * sin(omega * t);

xdot = @(t, x) A*x + B*u(t);
[t, X] = ode45(xdot, tspan, x0);

q = X(:,1);
qdot = X(:,2);

figure;
subplot(2,1,1);
plot(t, q, 'b', 'LineWidth', 2);
xlabel('Time [sec]'); 
ylabel('$q(t)$ [rad]', 'Interpreter', 'latex');
title('Deflection Angle');
grid on;

subplot(2,1,2);
plot(t, qdot, 'r', 'LineWidth', 2);
xlabel('Time [sec]'); 
ylabel('$\dot{q}(t)$ [rad/sec]', 'Interpreter', 'latex');
title('Angular Velocity');
grid on;

figure;
plot(q, qdot, 'm', 'LineWidth', 2);
xlabel('$q(t)$ [rad]', 'Interpreter', 'latex');   
ylabel('$\dot{q}(t)$ [rad/sec]', 'Interpreter', 'latex');
title('Phase Portrait');
grid on;

figure;
plot(t, u(t), 'g', 'LineWidth', 2); 
xlabel('Time [sec]');
ylabel('u(t)');
title('Input Signal');
grid on;

