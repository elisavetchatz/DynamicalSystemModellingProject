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
u = @(t) 2.5;          
%u = @(t) 2.5*sin(t);   
u_type = 'u(t) = 2.5';      %'u(t) = 2.5sin(t)'
chosen_label = 'best_m_params';  % ή 'best_b_params' / 'best_k_params'

%% Initialize Grid search parameters
g1_values = 1:1:150;
g2_values = 1:1:150;
g3_values = 1:1:150;  
am_values = 1:0.5:30; % filter poles

%initial_conditions
N = 20; % number of initial conditions
ranges = [
    -2, 2;    % για x1
    -2, 2;    % για x2
    -0.5, 0.5; % για x3
    -0.5, 0.5; % για x4
    -0.5, 0.5; % για x5
    0, 2; %m
    -1, 1; %b
    -1, 1; %k
];
initial_conditions_list = cell(1, N);
initial_conditions_list{1} = zeros(1, 8);
% interpolate initial conditions
for i = 1:N
    ic = zeros(1, 8);
    for j = 1:8
        ic(j) = ranges(j,1) + (ranges(j,2) - ranges(j,1)) * (i-1)/(N-1);
    end
    initial_conditions_list{i} = ic;
end

results = [];
experiment_num = 1;

%% Loop through all combinations of parameters
for g1_idx = 1:length(g1_values)
    for g2_idx = 1:length(g2_values)
        for g3_idx = 1:length(g3_values)
            for am_idx = 1:length(am_values)
                for ic_idx = 1:length(initial_conditions_list)

                    % Set parameter values
                    G = diag([g1_values(g1_idx), g2_values(g2_idx), g3_values(g3_idx)]);
                    am = am_values(am_idx);
                    initial_cond = initial_conditions_list{ic_idx};

                    % Simulate system
                    [t_out, var_out] = ode45(@(t, var) gradient_estimation(t, var), time, initial_cond);

                    % Extract final parameter estimates
                    final_theta1 = var_out(end,6); 
                    final_theta2 = var_out(end,7);
                    final_theta3 = var_out(end,8); 

                    m_hat = 1 / final_theta3;
                    b_hat = -final_theta2 * m_hat;
                    k_hat = -final_theta1 * m_hat;

                    % Compute absolute errors
                    AbsError_m = abs(m_real - m_hat);
                    AbsError_b = abs(b_real - b_hat);
                    AbsError_k = abs(k_real - k_hat);

                    % Store experiment results
                    results = [results; experiment_num, ...
                        g1_values(g1_idx), g2_values(g2_idx), g3_values(g3_idx), am, ic_idx, ...
                        AbsError_m, AbsError_b, AbsError_k];

                    experiment_num = experiment_num + 1;
                end
            end
        end
    end
end

% Create results table
results_table = array2table(results, ...
    'VariableNames', {'Experiment', 'g1', 'g2', 'g3', 'am', 'IC_Index', 'AbsError_m', 'AbsError_b', 'AbsError_k'});
disp(results_table);

%% Best parameters for each case
[~, idx_best_m] = min(results_table.AbsError_m);
[~, idx_best_b] = min(results_table.AbsError_b);
[~, idx_best_k] = min(results_table.AbsError_k);

best_m_params = results_table(idx_best_m, :);
best_b_params = results_table(idx_best_b, :);
best_k_params = results_table(idx_best_k, :);

disp('========== Best parameters for mass m ==========');
disp(best_m_params);
disp('========== Best parameters for damping b ==========');
disp(best_b_params);
disp('========== Best parameters for spring constant k ==========');
disp(best_k_params);

% Combine all best results
best_overall_table = [best_m_params; best_b_params; best_k_params];
disp('========== Summary of best results ==========');
disp(best_overall_table);

%% Resimulate with best parameters
% Option: which best to use 
chosen_best = best_m_params;   % Change to best_b_params or best_k_params if needed
% Extract best values
g1_best = chosen_best.g1;
g2_best = chosen_best.g2;
g3_best = chosen_best.g3;
am_best = chosen_best.am;
ic_idx_best = chosen_best.IC_Index;

% Set globals
G = diag([g1_best, g2_best, g3_best]);
am = am_best;
initial_cond = initial_conditions_list{ic_idx_best};

% Simulate again
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

% Reference lines for plots
m_vec = m_real * ones(size(t_out));
b_vec = b_real * ones(size(t_out));
k_vec = k_real * ones(size(t_out));

%% Plotting results

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
sgtitle(['Output Comparison – ' u_type ', ' chosen_label],'Interpreter','latex','FontSize',18);

% 2. Error e_x(t)
figure;
plot(t_out, error_x2, 'k-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Error');
title(['Estimation Error $e_x(t)$ – ' u_type ', ' chosen_label],'Interpreter','latex');
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

sgtitle(['Parameter Estimation History – ' u_type ', ' chosen_label],'Interpreter','latex','FontSize',18);
