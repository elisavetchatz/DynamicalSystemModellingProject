clear;
clc;
close all;

%% Global Parameters
global a1 a2 a3 b rd_func phi_func rho k1 k2

% System constants
a1 = 1.315;
a2 = 0.725;
a3 = 0.225;
b  = 1.175;

% Parameters for phi(t)
phi0 = 1;       % Initial phi
phi_inf = 0.01; % Final phi
lambda_phi = 1; % Decay rate

% Function for phi(t)
phi_func = @(t) (phi0 - phi_inf)*exp(-lambda_phi*t) + phi_inf;

% rho parameter (must be > initial velocity error)
rho = 1;  % constant, can be tuned

% Reference trajectory
rd_func = @(t) (pi/10)*sin(pi*t/20);   % From 0 to pi/10 and back smoothly

% Simulation Settings
time = 0:0.001:20;      
initial_cond = [0 0];  

%% --- Tuning Section ---

% Candidate gains
k1_values = linspace(0.1, 50, 20);
k2_values = linspace(0.1, 50, 20);

best_error = inf;
best_k1 = 0;
best_k2 = 0;

disp('Starting Auto-Tuning...');

%best_k1 = 50;
%best_k2 = 50;
for k1_try = k1_values
    for k2_try = k2_values

        % Set current gains
        k1 = k1_try;
        k2 = k2_try;

        % Run simulation
        [t_out, var_out] = ode45(@(t,var) system_dynamics(t,var), time, initial_cond);

        r = var_out(:,1);       
        rd = arrayfun(rd_func, t_out);
        e_r = r - rd;

        % Calculate Total RMSE
        RMSE = sqrt(mean(e_r.^2));

        % Update best
        if RMSE < best_error
            best_error = RMSE;
            best_k1 = k1_try;
            best_k2 = k2_try;
        end
    end
end

disp('========= Best Gains Found =========');
disp(['Best k1 = ', num2str(best_k1)]);
disp(['Best k2 = ', num2str(best_k2)]);
disp(['Best RMSE = ', num2str(best_error)]);

%% --- Final Simulation with Best Gains ---

% Set the best gains
k1 = best_k1;
k2 = best_k2;

% Run final simulation
[t_out, var_out] = ode45(@(t,var) system_dynamics(t,var), time, initial_cond);

r = var_out(:,1);       
r_dot = var_out(:,2);   
rd = arrayfun(rd_func, t_out);
e_r = r - rd;

%% --- Plotting ---

% 1. Actual vs Desired Roll Angle
figure;
plot(t_out, r, 'b-', 'LineWidth', 1.5, 'DisplayName', '$r(t)$ (Actual)');
hold on;
plot(t_out, rd, 'r--', 'LineWidth', 1.5, 'DisplayName', '$r_d(t)$ (Desired)');
xlabel('Time [s]');
ylabel('Roll Angle [rad]');
title('Actual vs Desired Roll Angle','Interpreter','latex');
legend('Interpreter','latex','Location','best');
grid on;
sgtitle('Closed-Loop Roll Angle Control (Optimized)','Interpreter','latex','FontSize',18);

% 2. Tracking Error Plot
figure;
plot(t_out, e_r, 'k-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Tracking Error [rad]');
title('Tracking Error $e_r(t) = r(t) - r_d(t)$','Interpreter','latex');
grid on;
sgtitle('Roll Angle Tracking Error (Optimized)','Interpreter','latex','FontSize',18);
