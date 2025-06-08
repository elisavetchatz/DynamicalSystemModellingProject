close all;

Tsim = 20;
Tsampl = 0.001;
tspan  = 0:Tsampl:Tsim;
x0 = 0; % initial condition

u = @(t) sin(t); % input function

%% Simulate the system using ode45 for comparison
[t, x] = ode45(@(t, x) true_func(t, x, u), tspan, x0);

u_vec = u(t); 
xdot = -x.^3 + tanh(x) + 1 ./ (1 + x.^2) + u_vec;

% Plot system response, input
figure;
subplot(3,1,1);
plot(t, x, 'b', "Linewidth", 1.5); ylabel('x(t)'); title('System Response'); grid on;
subplot(3,1,3);
plot(t, u_vec, 'r', "Linewidth", 1.5); ylabel('u(t)'); title('Sinusoidal Input u(t)'); grid on;
subplot(3,1,2);
plot(t, xdot, 'g', "Linewidth", 1.5); ylabel('xdot'); xlabel('Time [s]'); title('True Derivative'); grid on;

% Plot x vs xdot
figure;
scatter(x, xdot, 20, 'filled');
xlabel('x(t)'); ylabel('xdot(t)'); title('State vs Derivative');
grid on;

%% Build Phi vector and evaluate models
% Parameters
nx = 2; nu = 1;     % regression order
K = 5;              % folds
lambda = 0.01;      % regularization
dt = Tsampl;  
model_count = 15;

MSE_val_mean = zeros(model_count, 1);
MSE_val_std  = zeros(model_count, 1);
J_scores     = zeros(model_count, 1);
AIC_scores   = zeros(model_count, 1);
BIC_scores   = zeros(model_count, 1);
n_thetas     = zeros(model_count, 1);

N = length(t);  % συνολικός αριθμός δειγμάτων

% loop through each model
for model_id = 1:model_count
    fprintf('Evaluating model %d...\n', model_id);
    
    mse_vals = zeros(K, 1);
    J_vals   = zeros(K, 1);
    aic_vals = zeros(K, 1);
    bic_vals = zeros(K, 1);
    theta_lengths = zeros(K, 1);
    indices = kfold_indices(N, K, 1);   % Χώρισε το dataset σε K folds

    for k = 1:K
        % Shuffle and split
        idx = randperm(N);
        split = round(0.8 * N);
        train_idx = idx(1:split);
        val_idx   = idx(split+1:end);

        % Create phi vectors for training and validation sets
        [Phi_train, Y_train] = build_phi_vector(x(train_idx), u_vec(train_idx), nx, nu, model_id);
        [Phi_val, Y_val] = build_phi_vector(x(val_idx), u_vec(val_idx), nx, nu, model_id);

        % least-squares
        [theta_hist, ~] = rls_estimator(Phi_train, Y_train);
        theta_hat = theta_hist(:, end);   % τελικό theta
        theta_lengths(k) = length(theta_hat);  

        Y_val_hat = Phi_val * theta_hat;  % πρόβλεψη στο validation 

        %
        e = Y_val - Y_val_hat;
        mse_vals(k) = mean(e.^2);

        % J criterion
        E = sum(e.^2) * dt;
        J_vals(k) = E + lambda * length(theta_hat);

        % AIC & BIC
        N_val = length(Y_val);
        aic_vals(k) = N_val * log(mse_vals(k)) + 2 * length(theta_hat);
        bic_vals(k) = N_val * log(mse_vals(k)) + log(N_val) * length(theta_hat);
    end

    % 
    MSE_val_mean(model_id) = mean(mse_vals);
    MSE_val_std(model_id)  = std(mse_vals);
    J_scores(model_id)     = mean(J_vals);
    AIC_scores(model_id)   = mean(aic_vals);
    BIC_scores(model_id)   = mean(bic_vals);
    n_thetas(model_id)     = round(mean(theta_lengths));
end


model_labels = {'2nd Order Poly', '3rd Order Poly', '4th Order Poly', ...
                '5th Order Poly', 'GRBFs (-2, 0, 2)', ...
                'GRBFs (-1, 0, 1)', 'NL(tanh + poly)', ...
                'NL(tanh + poly 2nd order)', ...
                'NL(tanh + poly 3rd order)', ...
                'NE(tanh + rational + poly)', ...
                'NE(tanh + rational + poly 2nd order)', ...
                'NE(tanh + rational + poly 3rd order)', ...
                'NC(tanh, rational)', 'Sinusoidal Model', ...
                'Exponential Model'};

%% Display results
results_table = table((1:model_count)', model_labels', ...
    MSE_val_mean, MSE_val_std, n_thetas, J_scores, AIC_scores, BIC_scores, ...
    'VariableNames', {'ModelID', 'Label', 'MSE_Mean', 'MSE_Std', ...
                      'NumParams', 'J', 'AIC', 'BIC'});

disp(results_table);

%% Plot Bias-Variance Tradeoff
bias_sq = MSE_val_mean;
variance = MSE_val_std.^2;
cmap = turbo(length(model_labels)); 
figure;
hold on;
% Σχεδίαση σημείων και προσθήκη σε legend
for i = 1:length(model_labels)
    scatter(bias_sq(i), variance(i), 80, cmap(i, :), 'filled');
end
legend(model_labels, 'Location', 'northeastoutside');
xlabel('Bias² (MSE)');
ylabel('Variance');
title('Bias–Variance Tradeoff ανά Μοντέλο');
grid on;

%% Plot Mean Squared Error with Error Bars
figure;
bar(MSE_val_mean, 'FaceColor', [0.3 0.6 0.8]);
hold on;
errorbar(1:model_count, MSE_val_mean, MSE_val_std, '.k', 'LineWidth', 1.5);
xticks(1:model_count);
xticklabels(model_labels);
xtickangle(45);
ylabel('Validation MSE');
title('5-Fold Shuffle CV: Mean ± Std');
grid on;

%% Heatmap of Model Performance
% Normalization of metrics
metrics = [MSE_val_mean'; MSE_val_std'; J_scores'; AIC_scores'; BIC_scores'];
metrics_norm = (metrics - min(metrics, [], 2)) ./ (max(metrics, [], 2) - min(metrics, [], 2));
% Inversion of AIC and BIC for better visualization
metrics_norm(4:5, :) = 1 - metrics_norm(4:5, :);
% Heatmap of normalized metrics
figure;
imagesc(metrics_norm);
colormap("parula"); 
colorbar;
% axis properties
xticks(1:10);
xticklabels(model_labels);
xtickangle(45);
yticks(1:5);
yticklabels({'MSE', 'Std', 'J', 'AIC', 'BIC'});
xlabel('Model');
ylabel('Metric');
title('Model Performance Heatmap (Normalized Metrics)', 'FontWeight', 'bold');
set(gca, 'FontSize', 12);