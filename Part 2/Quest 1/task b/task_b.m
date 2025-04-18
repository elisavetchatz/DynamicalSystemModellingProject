clc; clear; close all;

% PARAMETERS
structure_type = "parallel";  % Options: "parallel" or "mixed"
dt = 0.0001;
t = 0:dt:20;
% t = t(:);
u_func = @(t) 2.5 * sin(t);
u = u_func(t);

m = 1.315; 
b = 0.225;
k = 0.725;
x0 = [0; 0];

% Simulate real system
system_fun = @(t, x) system_dynamics(t, x, m, k, b, u_func);
[~, X] = ode45(system_fun, t, x0);
x1 = X(:,1);
x2 = X(:,2);

%% Estimation
theta0 = [1; 0; 0];
gamma = 100;
lambda = 1;  % only used for mixed structure

switch structure_type
    case "parallel"
        [x_hat, theta_hist, ex] = lyap_estimation_parallel(t, u, x1, theta0, gamma, x0);
    case "mixed"
        [x_hat, theta_hist, ex] = lyap_estimation_mixed(t, u, x1, theta0, gamma, lambda);
    otherwise
        error('Unknown structure type. Choose "parallel" or "mixed".');
end

%% Plot results
% Plot x1 and x2 (True vs Estimated)
figure;
subplot(2,1,1);
plot(t, x1, 'b', 'DisplayName', 'x1 (True)', 'LineWidth', 1.5);
hold on;
plot(t, x_hat, 'g--', 'DisplayName', 'x1 (Estimated)', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('x1 (Position)');
title('x1: True vs Estimated');
legend; grid on;
% subplot(2,1,2);
% plot(t, x2, 'g', 'DisplayName', 'x2 (True)', 'LineWidth', 1.5);
% hold on;
% plot(t, x2_est, 'g--', 'DisplayName', 'x2 (Estimated)', 'LineWidth', 1.5);
% xlabel('Time [s]');
% ylabel('x2 (Velocity)');
% title('x2: True vs Estimated');
% legend; grid on;
sgtitle(['State Variables - ', structure_type]);

% Plot estimation error and control input
figure;
subplot(3,1,1);
plot(t, x1 - x_hat, 'r', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('e_x(t)');
title('Estimation Error: Position');
grid on;
% subplot(3,1,2);
% plot(t, x2 - x2_est, 'm', 'LineWidth', 1.5);
% xlabel('Time [s]'); ylabel('e_{\dot{x}}(t)');
% title('Estimation Error: Velocity');
% grid on;
subplot(3,1,3);
plot(t, u, 'k', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('u(t)');
title('Control Input u(t)');
grid on;

% Plot parameter estimates
figure('Name','Parameter Estimation History','NumberTitle','off');
subplot(3,1,1);
plot(t, theta_hist(:,1), 'r', 'LineWidth', 1.5);
hold on; yline(m, '--r', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('\hat{m}(t)');
title('Estimation of Mass Parameter');
legend({'Estimated m', 'True m'}); grid on;
subplot(3,1,2);
plot(t, theta_hist(:,2), 'g', 'LineWidth', 1.5);
hold on; yline(b, '--g', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('\hat{b}(t)');
title('Estimation of Damping Parameter');
legend({'Estimated b', 'True b'}); grid on;
subplot(3,1,3);
plot(t, theta_hist(:,3), 'b', 'LineWidth', 1.5);
hold on; yline(k, '--b', 'LineWidth', 1.5);
xlabel('Time [s]'); ylabel('\hat{k}(t)');
title('Estimation of Stiffness Parameter');
legend({'Estimated k', 'True k'}); grid on;

% %% Animated plot setup
% figure('Name','Real-Time Estimation Animation','Color','w');
% title('Real-time Parameter Estimation');
% xlabel('Time [s]'); ylabel('Value');
% grid on;
% h1 = animatedline('Color','k','DisplayName','x(t)','LineWidth',1.5);
% h2 = animatedline('Color','r','LineStyle','--','DisplayName','\hat{x}(t)','LineWidth',1.5);
% h3 = animatedline('Color','m','LineStyle','-.','DisplayName','e_x(t)','LineWidth',1);
% legend;

% for i = 1:5:length(t)
%     addpoints(h1, t(i), x1(i));
%     addpoints(h2, t(i), x_hat(i));
%     addpoints(h3, t(i), ex(i));
%     drawnow limitrate;
% end