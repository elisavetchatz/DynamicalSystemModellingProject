clear;
clc;
close all;

estimation_mode = "parallel";   % Ή" "mixed" ή "parallel"

% True system parameters
m_real = 1.315;
b_real = 0.225;
k_real = 0.725;

h0 = 0.25;
f0 = 20;

% Simulation settings
time = 0:0.01:20;            

% System input
u = @(t) 2.5*sin(t);          

% disturbance
h = @(t) h0*sin(2*pi*f0*t); 
mode = 0; % 0: no disturbance, 1: disturbance

% estimation settings
Thetam = diag([5, 10]);
initial_cond = [0; 0; 0; 0; 0; 0; 0; 0]; 
g1 = 100;
g2 = 20;
g3 = 40;
G = diag([g1, g2, g3]);

% Run simulation
switch estimation_mode
    case "parallel"
        ode_func = @(t, var) lyap_estimation_parallel(t, var, mode);
    case "mixed"
        ode_func = @(t, var) lyap_estimation_mixed(t, var, mode);
    otherwise
        error('Unknown estimation mode selected!');
end

[t_out, var_out] = ode45(ode_func, time, initial_cond);

x1 = var_out(:,1);        
x2 = var_out(:,2);  

theta1_est = var_out(:, 3);
theta2_est = var_out(:, 4);
theta3_est = var_out(:, 5);

x1_est = var_out(:,6);    
x2_est = var_out(:,7); 

m_est = 1/theta1_est;
b_est = theta2_est*m_est;
k_est = theta3_est*m_est;

% Absolute errors
error_m = abs(m_real - m_est);
error_b = abs(b_real - b_est);
error_k = abs(k_real - k_est);

% Total absolute error
total_error = error_m + error_b + error_k;

error_x1 = x1 - x1_est;
error_x2 = x2 - x2_est;

%% Plotting
m_vec = m_real * ones(size(t_out));
b_vec = b_real * ones(size(t_out));
k_vec = k_real * ones(size(t_out));

% 1. True vs Estimated Position
figure;
plot(t_out, x1, 'b-', 'LineWidth', 1.5, 'DisplayName', '$x_1(t)$ True');
hold on;
plot(t_out, x1_est, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\hat{x}_1(t)$ Estimated');
xlabel('Time [s]');
ylabel('Position [m]');
title('True vs Estimated Position','Interpreter','latex');
legend('Interpreter','latex','Location','best');
grid on;
sgtitle('Best Case - Position Estimation','Interpreter','latex','FontSize',18);

% 2. True vs Estimated Velocity
figure;
plot(t_out, x2, 'b-', 'LineWidth', 1.5, 'DisplayName', '$x_2(t)$ True');
hold on;
plot(t_out, x2_est, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\hat{x}_2(t)$ Estimated');
xlabel('Time [s]');
ylabel('Velocity [m/s]');
title('True vs Estimated Velocity','Interpreter','latex');
legend('Interpreter','latex','Location','best');
grid on;
sgtitle('Best Case - Velocity Estimation','Interpreter','latex','FontSize',18);

% 3. Errors
figure;
subplot(2,1,1);
plot(t_out, error_x1, 'k-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Position Error [m]');
title('Position Error $e_{x1}(t)$','Interpreter','latex');
grid on;

subplot(2,1,2);
plot(t_out, error_x2, 'k-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Velocity Error [m/s]');
title('Velocity Error $e_{x2}(t)$','Interpreter','latex');
grid on;

sgtitle('Best Case - State Estimation Errors','Interpreter','latex','FontSize',18);

% 4. Parameter Estimations
figure('Name','Best Parameter Estimations','NumberTitle','off');

subplot(3,1,1);
plot(t_out, m_est, 'r-', 'LineWidth', 1.5);
hold on;
yline(m_real, '--r', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{m}(t)$','Interpreter','latex');
title('Mass Estimation $\hat{m}(t)$','Interpreter','latex');
legend({'$\hat{m}$ Estimated','$m$ True'},'Interpreter','latex');
grid on;

subplot(3,1,2);
plot(t_out, b_est, 'g-', 'LineWidth', 1.5);
hold on;
yline(b_real, '--g', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{b}(t)$','Interpreter','latex');
title('Damping Estimation $\hat{b}(t)$','Interpreter','latex');
legend({'$\hat{b}$ Estimated','$b$ True'},'Interpreter','latex');
grid on;

subplot(3,1,3);
plot(t_out, k_est, 'b-', 'LineWidth', 1.5);
hold on;
yline(k_real, '--b', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{k}(t)$','Interpreter','latex');
title('Spring Constant Estimation $\hat{k}(t)$','Interpreter','latex');
legend({'$\hat{k}$ Estimated','$k$ True'},'Interpreter','latex');
grid on;

sgtitle('Best Case - Parameter Estimations','Interpreter','latex','FontSize',18);




