clear
clc
close all

% Χρονική διάταξη
time = 0:0.0001:20;   % λεπτότερο βήμα για μεγαλύτερη ακρίβεια

% Ορισμός global μεταβλητών
global m_real b_real k_real g am u

% Πραγματικές τιμές συστήματος
m_real = 1.315;
b_real = 0.225;
k_real = 0.725;

% Ορισμός εισόδου
u = @(t) 2.5;           % Σταθερή είσοδος
%u = @(t) 2.5*sin(t);    % Ημιτονοειδής είσοδος

% Παράμετροι εκτιμητή
g = 100;              % ρυθμός προσαρμογής (learning rate)
am = 3;               % πόλος φίλτρου

% Αρχικές συνθήκες
% [x1, x2, phi1, phi2, phi3, theta1_est, theta2_est, theta3_est]
initial_cond = [0 0 0 0 0 0 0 0];

% Λύση συστήματος με ODE45
[t_out, var_out] = ode45(@(t, var) gradient_estimation(t, var), time, initial_cond);

% Ανάθεση μεταβλητών
x1 = var_out(:,1);          % Θέση
x2 = var_out(:,2);          % Ταχύτητα
phi1 = var_out(:,3);        % Φίλτρο του x
phi2 = var_out(:,4);        % Φίλτρο του x'
phi3 = var_out(:,5);        % Φίλτρο του u
theta1_est = var_out(:,6);  % Εκτίμηση m
theta2_est = var_out(:,7);  % Εκτίμηση b
theta3_est = var_out(:,8);  % Εκτίμηση k

% Υπολογισμός εκτίμησης εξόδου
x2_est = theta1_est.*phi1 + theta2_est.*phi2 + theta3_est.*phi3;

% Πραγματικές σταθερές
m_vec = m_real * ones(size(t_out));
b_vec = b_real * ones(size(t_out));
k_vec = k_real * ones(size(t_out));

%% PLOTS

figure
plot(t_out, x2, 'b-', 'LineWidth', 1.5, 'DisplayName', '$x_2(t)$ True');
hold on;
plot(t_out, x2_est, 'g--', 'LineWidth', 1.5, 'DisplayName', '$\hat{x}_2(t)$ Estimated');
xlabel('Time [s]');
ylabel('$x_2(t)$','Interpreter','latex');
title('Actual vs Estimated Output $x_2(t)$','Interpreter','latex');
legend('Interpreter','latex','Location','best');
grid on
sgtitle('Actual vs Estimated Output','Interpreter','latex','FontSize',18);


figure
plot(t_out, x2 - x2_est, 'r', 'LineWidth', 1.5);
xlabel('Time [s]')
ylabel('Error $e_x(t)$','Interpreter','latex')
title('Error between Actual and Estimated Output','Interpreter','latex')
grid on

figure
subplot(3,1,1)
plot(t_out, m_vec, 'r','LineWidth', 1.5)
hold on
plot(t_out, theta1_est, 'r--','LineWidth', 1.5)
xlabel('Time [s]')
ylabel('Mass [kg]')
legend('$m$','$\hat{m}$','Interpreter','latex')
grid on
title('Mass estimation','Interpreter','latex')

subplot(3,1,2)
plot(t_out, b_vec, 'g','LineWidth', 1.5)
hold on
plot(t_out, theta2_est, 'g--','LineWidth', 1.5)
xlabel('Time [s]')
ylabel('Damping [Ns/m]')
legend('$b$','$\hat{b}$','Interpreter','latex')
grid on
title('Damping estimation','Interpreter','latex')

subplot(3,1,3)
plot(t_out, k_vec, 'b','LineWidth', 1.5)
hold on
plot(t_out, theta3_est, 'b--','LineWidth', 1.5)
xlabel('Time [s]')
ylabel('Spring constant [N/m]')
legend('$k$','$\hat{k}$','Interpreter','latex')
grid on
title('Spring constant estimation','Interpreter','latex')

sgtitle('Real vs Estimated Parameters','Interpreter','latex','FontSize',18)
