clear;
clc;
close all;

% ----------------------------------
% Global Variables
% ----------------------------------
global m_real b_real k_real G am u

% System true parameters
m_real = 1.315;
b_real = 0.225;
k_real = 0.725;

% Simulation settings
time = 0:0.0001:20;             % Simulation time
u = @(t) 2.5*sin(t);           % System input

% Search ranges
g1_values = [50, 100, 150];    % Candidate g1 values
g2_values = [50, 100, 150];    % Candidate g2 values
g3_values = [50, 100, 150];    % Candidate g3 values
am_values = [1, 2, 3, 5];         % Candidate filter poles

% Initial conditions list
initial_conditions_list = { ...
    [0 0 0 0 0 0 0 0], ...
    [0.5 -0.5 0 0 0 0 0 0], ...
    [1 -1 0 0 0 0 0 0] ...
};

% Storage for results
results = [];
experiment_num = 1;

% ----------------------------------
% Grid search over parameter space
% ----------------------------------
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
                    final_theta1 = var_out(end,6); % Estimated m
                    final_theta2 = var_out(end,7); % Estimated b
                    final_theta3 = var_out(end,8); % Estimated k

                    % Compute absolute errors
                    AbsError_m = abs(m_real - final_theta1);
                    AbsError_b = abs(b_real - final_theta2);
                    AbsError_k = abs(k_real - final_theta3);

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

% ----------------------------------
% Find best parameters for each case
% ----------------------------------

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

% ----------------------------------
% Re-simulate using the best parameters
% ----------------------------------

% Option: which best to use (m, b, or k)
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
theta1_est = var_out(:,6); % Estimated m
theta2_est = var_out(:,7); % Estimated b
theta3_est = var_out(:,8); % Estimated k

% Estimated output
x2_est = theta1_est.*phi1 + theta2_est.*phi2 + theta3_est.*phi3;
error_x2 = x2 - x2_est;

% Reference lines for plots
m_vec = m_real * ones(size(t_out));
b_vec = b_real * ones(size(t_out));
k_vec = k_real * ones(size(t_out));

% ----------------------------------
% Plot results
% ----------------------------------

% 1. Actual vs Estimated x(t)
figure;
plot(t_out, x2, 'b-', 'LineWidth', 1.5, 'DisplayName', '$x(t)$ True');
hold on;
plot(t_out, x2_est, 'r--', 'LineWidth', 1.5, 'DisplayName', '$\hat{x}(t)$ Estimated');
xlabel('Time [s]');
ylabel('Output');
title('Actual vs Estimated Output $x(t)$','Interpreter','latex');
legend('Interpreter','latex','Location','best');
grid on;
sgtitle('Output Comparison','Interpreter','latex','FontSize',18);

% 2. Error e_x(t)
figure;
plot(t_out, error_x2, 'k-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Error');
title('Estimation Error $e_x(t)$','Interpreter','latex');
grid on;

% 3. Parameter Estimations
figure('Name','Parameter Estimations','NumberTitle','off');

subplot(3,1,1);
plot(t_out, theta1_est, 'r-', 'LineWidth', 1.5);
hold on;
yline(m_real, '--r', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{m}(t)$','Interpreter','latex');
title('Mass Estimation $\hat{m}(t)$','Interpreter','latex');
legend({'$\hat{m}$ estimated','$m$ true'},'Interpreter','latex');
grid on;

subplot(3,1,2);
plot(t_out, theta2_est, 'g-', 'LineWidth', 1.5);
hold on;
yline(b_real, '--g', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{b}(t)$','Interpreter','latex');
title('Damping Estimation $\hat{b}(t)$','Interpreter','latex');
legend({'$\hat{b}$ estimated','$b$ true'},'Interpreter','latex');
grid on;

subplot(3,1,3);
plot(t_out, theta3_est, 'b-', 'LineWidth', 1.5);
hold on;
yline(k_real, '--b', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('$\hat{k}(t)$','Interpreter','latex');
title('Spring Constant Estimation $\hat{k}(t)$','Interpreter','latex');
legend({'$\hat{k}$ estimated','$k$ true'},'Interpreter','latex');
grid on;

sgtitle('Parameter Estimation History','Interpreter','latex','FontSize',18);
