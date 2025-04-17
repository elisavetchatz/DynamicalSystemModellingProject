clc; clear; close all;

% Time and input
dt = 0.001;
t = 0:dt:20;
t = t(:);
u = 2.5 * sin(t);

% True parameters
m = 1.315; b = 0.225; k = 0.725;

% Simulate real system
x0 = [0; 0];
sys_fun = @(t, x) [x(2); (1/m)*(2.5*sin(t) - b*x(2) - k*x(1))];
[~, X] = ode45(sys_fun, t, x0);
x_true = X(:,1);
xdot_true = X(:,2);

% --- Parallel Structure ---
theta0 = [0.5; 0.1; 0.1];
gamma = 20;
[x_hat_p, theta_hist_p, ex_p] = lyap_estimation_parallel(t, u, x_true, theta0, gamma);

% --- Mixed Structure ---
lambda = 10;
[theta_hist_m, x_hat_m, ex_m] = lyap_estimation_mixed(t, u, x_true, xdot_true, lambda, gamma, theta0);

% --- Plotting ---
figure('Name','x(t) vs x̂(t) - Parallel vs Mixed');
subplot(2,1,1);
plot(t, x_true, 'k', t, x_hat_p, '--r');
title('Parallel: True vs Estimated'); legend('x(t)', '\xhat(t)'); grid on;

subplot(2,1,2);
plot(t, x_true, 'k', t, x_hat_m, '--b');
title('Mixed: True vs Estimated'); legend('x(t)', '\xhat(t)'); grid on;

figure('Name','Estimation Error e_x(t)');
plot(t, ex_p, 'r', t, ex_m, 'b');
title('Estimation Error e_x(t)');
legend('Parallel', 'Mixed'); grid on;

figure('Name','Parameter Estimates');
subplot(3,1,1);
plot(t, theta_hist_p(:,1), 'r', t, theta_hist_m(:,1), 'b'); yline(m, '--k');
title('m̂(t)'); legend('Parallel','Mixed','True'); grid on;

subplot(3,1,2);
plot(t, theta_hist_p(:,2), 'r', t, theta_hist_m(:,2), 'b'); yline(b, '--k');
title('b̂(t)'); legend('Parallel','Mixed','True'); grid on;

subplot(3,1,3);
plot(t, theta_hist_p(:,3), 'r', t, theta_hist_m(:,3), 'b'); yline(k, '--k');
title('k̂(t)'); legend('Parallel','Mixed','True'); grid on;