clc; clear; close all;
addpath('C:\Users\30690\DynamicalSystemModellingandSimulation-Projects\Part 1')
addpath('../Part 1')

% System Parameters
m = 0.75;
L = 1.25;
c = 0.15;
g = 9.81;
A0 = 4;
omega = 2;
x0 = [0; 0]; 

dt = 1e-5;
tspan = 0:dt:20;

% System Simulation
[t, q, qdot, u] = simulate_true_system(m, L, c, g, A0, omega, x0, tspan);

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
plot(t, u, 'g', 'LineWidth', 2); 
xlabel('Time [sec]');
ylabel('u(t)');
title('Input Signal');
grid on;

