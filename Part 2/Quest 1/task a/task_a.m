clear;
clc;
close all;

global m_real b_real k_real G am u

% System true parameters
m_real = 1.315;
b_real = 0.225;
k_real = 0.725;

% Simulation settings
time = 0:0.001:20; 
u_type = 'u(t) = 2.5';     %'u(t) = 2.5sin(t)'
u = @(t) 2.5;          
%u = @(t) 2.5*sin(t);

%Estimation settings
g1 = 20;
g2 = 100;
g3 = 60;
G = diag([g1, g2, g3]);
am = 1; 
initial_cond = [0; 0; 0; 0; 0; 0; 0; 0]; 

%% Simulate the system

[t_out, var_out] = ode45(@(t, var) gradient_estimation(t, var), time, initial_cond);
% Extract system states and parameter estimates
x1 = var_out(:,1);        % Position
x2 = var_out(:,2);        % Velocity
phi1 = var_out(:,3);
phi2 = var_out(:,4);
phi3 = var_out(:,5);
theta1_est = var_out(:,6); 
theta2_est = var_out(:,7); 
theta3_est = var_out(:,8); 

% Estimated output
x2dot_est = theta1_est.*phi1 + theta2_est.*phi2 + theta3_est.*phi3;
error_x2 = x2 - x2dot_est;

m_est = 1/theta3_est; 
b_est = -theta2_est*m_est; 
k_est = -theta1_est*m_est; 

%% Plotting results
% Reference lines for plots
m_vec = m_real * ones(size(t_out));
b_vec = b_real * ones(size(t_out));
k_vec = k_real * ones(size(t_out));


% 1. Actual vs Estimated x(t)
figure;
plot(t_out, x2, 'b-', 'LineWidth', 1.5, 'DisplayName', '$x(t)$ True');
hold on;
plot(t_out, x2dot_est, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\hat{x}(t)$ Estimated');
xlabel('Time [s]');
ylabel('Output');
title('Actual vs Estimated Output $x(t)$','Interpreter','latex');
legend('Interpreter','latex','Location','best');
grid on;
sgtitle(['Output Comparison – ' u_type ],'Interpreter','latex','FontSize',18);

% 2. Error e_x(t)
figure;
plot(t_out, error_x2, 'k-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Error');
title(['Estimation Error $e_x(t)$ – ' u_type ],'Interpreter','latex');
grid on;

% 3. Parameter Estimations
figure('Name','Parameter Estimations','NumberTitle','off');

subplot(3,1,1);
plot(t_out, m_est, 'r-', 'LineWidth', 1.5);
hold on;
yline(m_real, '--r', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{m}(t)$','Interpreter','latex');
title('Mass Estimation $\hat{m}(t)$','Interpreter','latex');
legend({'$\hat{m}$ estimated','$m$ true'},'Interpreter','latex');
grid on;

subplot(3,1,2);
plot(t_out, b_est, 'g-', 'LineWidth', 1.5);
hold on;
yline(b_real, '--g', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{b}(t)$','Interpreter','latex');
title('Damping Estimation $\hat{b}(t)$','Interpreter','latex');
legend({'$\hat{b}$ estimated','$b$ true'},'Interpreter','latex');
grid on;

subplot(3,1,3);
plot(t_out, k_est, 'b-', 'LineWidth', 1.5);
hold on;
yline(k_real, '--b', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{k}(t)$','Interpreter','latex');
title('Spring Constant Estimation $\hat{k}(t)$','Interpreter','latex');
legend({'$\hat{k}$ estimated','$k$ true'},'Interpreter','latex');
grid on;

sgtitle(['Parameter Estimation History – ' u_type ],'Interpreter','latex','FontSize',18);
