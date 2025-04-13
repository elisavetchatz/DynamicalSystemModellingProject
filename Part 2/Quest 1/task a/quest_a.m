%% Quest 1, Task a: Gradient-Steepest Descent Estimation
clear;
close all;
clc;

global gamma am;
gamma = 100;
am = 5;

% Χρονικό διάστημα
tspan = 0:0.001:20;
    
% Αρχικές συνθήκες: [x; dx; φ1; φ2; φ3; θ̂1; θ̂2; θ̂3]
x0 = zeros(9, 1);

% Λύση
[t, X] = ode45(@simulate_system, tspan, x0);

% Ανάκτηση σημάτων
x = X(:,1);
dx = X(:,2);
z = X(:,3);
phi1 = X(:,4); phi2 = X(:,5); phi3 = X(:,6);
th1 = X(:,7); th2 = X(:,8); th3 = X(:,9);

x_hat = th1_hat .* phi1 + th2_hat .* phi2 + th3_hat .* phi3;
e = z - x_hat;
% Υπολογισμός τελικών εκτιμήσεων παραμέτρων
m_hat = 1 ./ th3;
b_hat = -th1 ./ th3;
k_hat = -th2 ./ th3;

% Πραγματικές τιμές
m_true = 1.315;
b_true = 0.225;
k_true = 0.725;

% Διαγράμματα συγκρίσεων
figure;
plot(t, m_hat, 'b'); hold on;
yline(m_true, '--b', 'm true');
title('m̂(t) vs m');
xlabel('Time [s]');
ylabel('Estimated Mass');

figure;
plot(t, b_hat, 'r'); hold on;
yline(b_true, '--r', 'b true');
title('b̂(t) vs b');
xlabel('Time [s]');
ylabel('Estimated Damping');

figure;
plot(t, k_hat, 'g'); hold on;
yline(k_true, '--g', 'k true');
title('k̂(t) vs k');
xlabel('Time [s]');
ylabel('Estimated Spring Const');
