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

q_clean = x(:,1);  % Γωνία q(t) χωρίς θόρυβο
dq_clean = x(:,2); % Γωνιακή ταχύτητα χωρίς θόρυβο
ddq_clean = gradient(dq_clean, Ts);  % Δεύτερη παράγωγος

%% Προσθήκη λευκού γκαουσιανού θορύβου
noise_level = 0.02; % Επίπεδο θορύβου
q_noisy = q_clean + noise_level * randn(size(q_clean));
dq_noisy = dq_clean + noise_level * randn(size(dq_clean));

% Προσέγγιση δεύτερης παραγώγου με βάση το θορυβώδες dq
ddq_noisy = gradient(dq_noisy, Ts);

%% Εκτίμηση παραμέτρων με Least Squares (Με και Χωρίς Θόρυβο)
Phi_clean = [-dq_clean, -q_clean, ones(size(q_clean))]; 
y_clean = ddq_clean;
theta_clean = Phi_clean \ y_clean;

Phi_noisy = [-dq_noisy, -q_noisy, ones(size(q_noisy))]; 
y_noisy = ddq_noisy;
theta_noisy = Phi_noisy \ y_noisy;

%% Ανάκτηση των εκτιμημένων παραμέτρων
c_hat_clean = -theta_clean(1);
gL_hat_clean = -theta_clean(2);
mL2_hat_inv_clean = theta_clean(3);
L_hat_clean = g / gL_hat_clean;
m_hat_clean = 1 / (mL2_hat_inv_clean * L_hat_clean^2);

c_hat_noisy = -theta_noisy(1);
gL_hat_noisy = -theta_noisy(2);
mL2_hat_inv_noisy = theta_noisy(3);
L_hat_noisy = g / gL_hat_noisy;
m_hat_noisy = 1 / (mL2_hat_inv_noisy * L_hat_noisy^2);

%% Σύγκριση πραγματικών και εκτιμώμενων παραμέτρων
fprintf('--- Πραγματικές και Εκτιμώμενες Παράμετροι ---\n');
fprintf('Παράμετρος\tΠραγματική\tΚαθαρή Εκτίμηση\tΕκτίμηση με Θόρυβο\n');
fprintf('m\t\t%.3f\t\t%.3f\t\t%.3f\n', m, m_hat_clean, m_hat_noisy);
fprintf('L\t\t%.3f\t\t%.3f\t\t%.3f\n', L, L_hat_clean, L_hat_noisy);
fprintf('c\t\t%.3f\t\t%.3f\t\t%.3f\n', c, c_hat_clean, c_hat_noisy);

%% Γραφικές Παραστάσεις
figure;
subplot(3,1,1);
plot(t, q_clean, 'b', 'LineWidth', 1.5);
hold on;
plot(t, q_noisy, 'r');
legend('q(t) χωρίς θόρυβο', 'q(t) με θόρυβο');
xlabel('Χρόνος [sec]'); ylabel('Γωνία q(t)');
title('Γωνία με και χωρίς θόρυβο');
grid on;

subplot(3,1,2);
plot(t, dq_clean, 'b', 'LineWidth', 1.5);
hold on;
plot(t, dq_noisy, 'r');
legend('dq(t) χωρίς θόρυβο', 'dq(t) με θόρυβο');
xlabel('Χρόνος [sec]'); ylabel('Γωνιακή Ταχύτητα');
title('Γωνιακή Ταχύτητα με και χωρίς θόρυβο');
grid on;

subplot(3,1,3);
bar([abs(m_hat_clean - m), abs(m_hat_noisy - m); 
     abs(L_hat_clean - L), abs(L_hat_noisy - L);
     abs(c_hat_clean - c), abs(c_hat_noisy - c)]);
set(gca, 'XTickLabel', {'m', 'L', 'c'});
legend('Χωρίς Θόρυβο', 'Με Θόρυβο');
ylabel('Σφάλμα Εκτίμησης');
title('Σφάλμα εκτίμησης των παραμέτρων');
grid on;

%% Συνάρτηση δυναμικής του εκκρεμούς
function dxdt = pendulumODE(t, x, A, B, A0, omega)
    u = A0 * sin(omega * t);
    dxdt = A * x + B * u;
end
