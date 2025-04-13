%% Quest 1, Task a: Gradient-Steepest Descent Estimation
clear;
close all;
clc;

gamma = 100;
am = 5;

% Χρονικό διάστημα
tspan = 0:0.001:20;
    
% Αρχικές συνθήκες: [x; dx; φ1; φ2; φ3; θ̂1; θ̂2; θ̂3]
x0 = zeros(8,1);

% Λύση
[t, X] = ode45(@system_dynamics, tspan, x0);

% Ανάκτηση σημάτων
x = X(:,1);
dx = X(:,2);
phi1 = X(:,3);
phi2 = X(:,4);
phi3 = X(:,5);
th1_hat = X(:,6);
th2_hat = X(:,7);
th3_hat = X(:,8);

x_hat = th1_hat .* phi1 + th2_hat .* phi2 + th3_hat .* phi3;
e = x - x_hat;

% Πραγματικές τιμές:
m = 1.315;
b = 0.225;
k = 0.725;

theta1_true = -b/m;
theta2_true = -k/m;
theta3_true = 1/m;

% Plot θέσης
figure;
plot(t, x, 'b', t, x_hat, 'r--');
legend('x(t)', 'x̂(t)');
xlabel('Time [s]');
ylabel('Displacement');
title('x(t) vs x̂(t)');

% Plot σφάλματος
figure;
plot(t, e);
xlabel('Time [s]');
ylabel('Estimation Error');
title('Error e(t) = x(t) - x̂(t)');

% Εκτιμήσεις
figure;
plot(t, th1_hat, 'r', t, th2_hat, 'g', t, th3_hat, 'b');
hold on;
yline(theta1_true, '--r', 'θ₁ true');
yline(theta2_true, '--g', 'θ₂ true');
yline(theta3_true, '--b', 'θ₃ true');
xlabel('Time [s]');
ylabel('Parameter Estimates');
legend('θ̂₁', 'θ̂₂', 'θ̂₃');
title('Parameter Estimation');
