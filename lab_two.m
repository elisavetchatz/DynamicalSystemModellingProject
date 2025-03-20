clc; clear; close all;

% Δεδομένα
m_real = 0.75;
L_real = 1.25;
c_real = 0.15;
g = 9.81;
A0 = 4;
omega = 2;

% Ορισμός του συστήματος
A = [0 1; -g/L_real -c_real/(m_real*L_real^2)];
B = [0; 1/(m_real*L_real^2)];

% Δειγματοληψία
Ts = 0.1;
t_sim = 0:Ts:20;
dt = 1e-3;
t_cont = 0:dt:20;

% Συνάρτηση εισόδου
u = @(t) A0 * sin(omega * t);

% Επίλυση με ODE45 για συνεχές σύστημα
dxdt = @(t, x) A*x + B*u(t);
[t_cont, X] = ode45(dxdt, t_cont, [0; 0]);

% Δειγματοληψία των τιμών
q_samples = interp1(t_cont, X(:,1), t_sim);
dq_samples = interp1(t_cont, X(:,2), t_sim);
ddq_samples = gradient(dq_samples, Ts);
u_samples = u(t_sim);

% Πίνακας Least Squares
Phi = [-q_samples', -dq_samples', u_samples'];
y = ddq_samples';

% Εκτίμηση των παραμέτρων
theta = (Phi' * Phi) \ (Phi' * y);

L_est = g / theta(1);
mL2_est = 1 / theta(3);
c_est = theta(2) * mL2_est;
m_est = mL2_est / (L_est^2);

fprintf('Εκτιμήσεις Παραμέτρων:\n');
fprintf('L_est = %.4f m\n', L_est);
fprintf('m_est = %.4f kg\n', m_est);
fprintf('c_est = %.4f Nm/sec\n', c_est);

% Νέα προσομοίωση με τις εκτιμημένες παραμέτρους
A_est = [0 1; -g/L_est -c_est/(m_est*L_est^2)];
B_est = [0; 1/(m_est*L_est^2)];
dxdt_est = @(t, x) A_est*x + B_est*u(t);
[t_cont, X_est] = ode45(dxdt_est, t_cont, [0; 0]);

% Γραφικές παραστάσεις
figure;
subplot(3,1,1);
plot(t_cont, X(:,1), 'b', 'LineWidth', 1.5); hold on;
plot(t_cont, X_est(:,1), 'r--', 'LineWidth', 1.5);
xlabel('Χρόνος [sec]'); ylabel('q(t) [rad]');
legend('Αληθινό', 'Εκτιμημένο');
title('Σύγκριση γωνιακής εκτροπής');
grid on;

subplot(3,1,2);
plot(t_cont, X(:,1) - X_est(:,1), 'k', 'LineWidth', 1.5);
xlabel('Χρόνος [sec]'); ylabel('Σφάλμα e_q(t)');
title('Σφάλμα εκτίμησης q(t)');
grid on;

subplot(3,1,3);
plot(t_cont, u(t_cont), 'm', 'LineWidth', 1.5);
xlabel('Χρόνος [sec]'); ylabel('u(t) [Nm]');
title('Είσοδος ελέγχου');
grid on;

% ========================
% Μέθοδος με μόνο q(t) και u(t)
% ========================
Phi2 = [q_samples(2:end-1)' q_samples(1:end-2)' u_samples(2:end-1)'];
y2 = q_samples(3:end)';

theta2 = (Phi2' * Phi2) \ (Phi2' * y2);

fprintf('\nΕκτιμήσεις από μόνο q(t) και u(t):\n');
fprintf('L_est2 = %.4f m\n', g/theta2(1));
