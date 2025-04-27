clear;
clc;
close all;

estimation_mode = "mixed";   % Ή "mixed"

global m_real b_real k_real G u h Thetam 

% True system parameters
m_real = 1.315;
b_real = 0.225;
k_real = 0.725;

h0 = 0.25;
f0 = 20;

Thetam = diag([5, 10]);   % π.χ. 5 για position error, 10 για velocity error

% Simulation settings
time = 0:0.01:20;            

% System input
u = @(t) 2.5*sin(t);          

% No disturbance
h = @(t) h0*sin(2*pi*f0*t);                    

% Define candidate initial conditions
initial_conditions_list = {
    [0 0 2 0.5 1 0 0], ...
    [0 0 1 0.2 1 0 0], ...
    [0 0 5 1 2 0 0], ...
    [0 0 1.5 0.1 0.5 0 0], ...
    [0 0 3 1 1 0 0]
};

% Define candidate G matrices
% Define gamma values using linspace
gamma_m_values = linspace(20, 100, 5);   % [20, 40, 60, 80, 100]
gamma_b_values = linspace(20, 100, 5);   
gamma_k_values = linspace(20, 100, 5);   

% Generate all combinations
G_candidates = {};

for gm = gamma_m_values
    for gb = gamma_b_values
        for gk = gamma_k_values
            G_candidates{end+1} = diag([gm, gb, gk]);
        end
    end
end

% Display how many G matrices were created
disp(['Total G candidates generated: ', num2str(length(G_candidates))]);


% Mode (0 = no disturbance)
mode = 1;

% Storage
results = [];

experiment_num = 1;

for g_idx = 1:length(G_candidates)
    for ic_idx = 1:length(initial_conditions_list)

        % Set G and initial condition
        G = G_candidates{g_idx};
        initial_cond = initial_conditions_list{ic_idx};

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
        
        % Extract final estimated parameters
        final_m_est = var_out(end,3);
        final_b_est = var_out(end,4);
        final_k_est = var_out(end,5);

        % Absolute errors
        error_m = abs(m_real - final_m_est);
        error_b = abs(b_real - final_b_est);
        error_k = abs(k_real - final_k_est);

        % Total absolute error
        total_error = error_m + error_b + error_k;

        % Save results
        results = [results; experiment_num, g_idx, ic_idx, total_error, error_m, error_b, error_k];
        experiment_num = experiment_num + 1;
    end
end

% Create results table
results_table = array2table(results, ...
    'VariableNames', {'Experiment', 'G_Index', 'IC_Index', 'TotalError', 'Error_m', 'Error_b', 'Error_k'});

disp('========= All Results =========');
disp(results_table);

% Find best experiment
[~, best_experiment_idx] = min(results_table.TotalError);
best_result = results_table(best_experiment_idx, :);

disp('========= Best Configuration Found =========');
disp(best_result);

% Extract best settings
best_G_idx = best_result.G_Index;
best_IC_idx = best_result.IC_Index;

G = G_candidates{best_G_idx};
initial_cond = initial_conditions_list{best_IC_idx};

disp('Best G:');
disp(G);
disp('Best Initial Condition:');
disp(initial_cond);

% ----------------------------------
% Re-run simulation with best settings
% ----------------------------------

switch estimation_mode
    case "parallel"
        ode_func = @(t, var) lyap_estimation_parallel(t, var, mode);
    case "mixed"
        ode_func = @(t, var) lyap_estimation_mixed(t, var, mode);
    otherwise
        error('Unknown estimation mode selected!');
end

[t_out, var_out] = ode45(ode_func, time, initial_cond);


% Extract data
x1 = var_out(:,1);        
x2 = var_out(:,2);        
m_est = var_out(:,3);     
b_est = var_out(:,4);     
k_est = var_out(:,5);     
x1_est = var_out(:,6);    
x2_est = var_out(:,7);    

m_vec = m_real * ones(size(t_out));
b_vec = b_real * ones(size(t_out));
k_vec = k_real * ones(size(t_out));

error_x1 = x1 - x1_est;
error_x2 = x2 - x2_est;

% ----------------------------------
% Plotting best case
% ----------------------------------

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

