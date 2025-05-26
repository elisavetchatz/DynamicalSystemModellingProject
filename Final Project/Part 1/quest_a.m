clc; clear; close all;

% ΧTime Setup
Ts = 0.01;           
Tf = 20;        
t = 0:Ts:Tf;    
N = length(t);

% Real System Parameters
A = [-2.15, 0.25; -0.75, -2];
B = [0; 1.5];

% Input Signal
ufun = @(t) sin(0.5*t) + sin(2*t);
u = ufun(t);

% Initial Conditions
x0 = [0; -0];    

% System Function
system = @(t, x) A*x + B*ufun(t);

% Simulation with ode45
[t, x] = ode45(system, t, x0);

% Plotting Results
figure;
plot(t, x(:,1), 'g', 'DisplayName', 'x_1(t)', 'LineWidth', 1.2); hold on;
plot(t, x(:,2), 'b', 'DisplayName', 'x_2(t)', 'LineWidth', 1.2);
plot(t, u, 'k--', 'DisplayName', 'u(t)', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('States and Input');
title('System Response');
grid on; legend show;
