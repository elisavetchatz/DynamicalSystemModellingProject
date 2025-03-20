clc; clear; close all;

%% Ορισμός παραμέτρων του συστήματος
m = 0.75; 
L = 1.25; 
c = 0.15; 
g = 9.81;
A0 = 4; 
omega = 2;
T_sim = 20;  % Συνολικός χρόνος προσομοίωσης
Ts = 0.1;    % Περίοδος δειγματοληψίας

%% Διαφορικές εξισώσεις του συστήματος
A = [0 1; -g/L -c/(m*L^2)];
B = [0; 1/(m*L^2)];
x0 = [0; 0];  % Αρχικές συνθήκες

%% Προσομοίωση με ODE45
tspan = 0:Ts:T_sim;
[t, x] = ode45(@(t, x) pendulumODE(t, x, A, B, A0, omega), tspan, x0);

%% Εκτίμηση παραμέτρων με Least Squares
q = x(:,1);  % Γωνία q(t)
dq = x(:,2); % Ταχύτητα q'(t)
ddq = gradient(dq, Ts);  % Προσεγγιστική δεύτερη παράγωγος

% Διαμόρφωση του συστήματος y = Φθ
Phi = [-dq, -q, ones(size(q))]; 
y = ddq;

% Εφαρμογή Least Squares
theta = Phi \ y;

% Ανάκτηση παραμέτρων από τις εκτιμήσεις
c_hat = -theta(1);
gL_hat = -theta(2);
mL2_hat_inv = theta(3);
L_hat = g / gL_hat;
m_hat = 1 / (mL2_hat_inv * L_hat^2);

%% Σύγκριση πραγματικών και εκτιμώμενων παραμέτρων
fprintf('Πραγματικές και εκτιμώμενες παράμετροι:\n');
fprintf('m (Πραγματικό: %.2f, Εκτιμώμενο: %.2f)\n', m, m_hat);
fprintf('L (Πραγματικό: %.2f, Εκτιμώμενο: %.2f)\n', L, L_hat);
fprintf('c (Πραγματικό: %.2f, Εκτιμώμενο: %.2f)\n', c, c_hat);

%% Γραφικές παραστάσεις
figure;
subplot(2,1,1);
plot(t, q, 'b', 'LineWidth', 1.5);
hold on;
plot(t, dq, 'r', 'LineWidth', 1.5);
legend('\theta(t)', '\theta''(t)');
xlabel('Χρόνος [sec]');
ylabel('Γωνία και γωνιακή ταχύτητα');
title('Απόκριση του συστήματος');
grid on;

subplot(2,1,2);
plot(t, ddq, 'g', 'LineWidth', 1.5);
xlabel('Χρόνος [sec]');
ylabel('\theta''''(t)');
title('Δεύτερη παράγωγος');
grid on;

%% Συνάρτηση δυναμικής του εκκρεμούς
function dxdt = pendulumODE(t, x, A, B, A0, omega)
    u = A0 * sin(omega * t);
    dxdt = A * x + B * u;
end
