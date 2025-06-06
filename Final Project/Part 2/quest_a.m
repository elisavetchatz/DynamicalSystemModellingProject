clc; clear;  close all;

tspan = [0 20]; % time span
x0 = 0; % initial condition

u = @(t) sin(t);

%% Simulate the system using ode45 for comparison
[t, x] = ode45(@(t, x) true_func(t, x, u), tspan, x0);

u_vec = u(t);
xdot = -x.^3 + tanh(x) + 1 ./ (1 + x.^2) + u_vec;

figure;
subplot(3,1,1);
plot(t, x, 'b'); ylabel('x(t)'); title('System Response'); grid on;
subplot(3,1,2);
plot(t, u_vec, 'r'); ylabel('u(t)'); title('Input u(t)'); grid on;
subplot(3,1,3);
plot(t, xdot, 'k'); ylabel('xdot'); xlabel('Time [s]'); title('True Derivative'); grid on;

% Plot x vs xdot
figure;
scatter(x, xdot, 20, 'filled');
xlabel('x(t)'); ylabel('xdot(t)'); title('State vs Derivative');
grid on;


%% Find Phi vector and the form of the model
nx = 2;
nu = 1;
N = length(t);
M = N - max(nx, nu); % number of samples for regression

Phi = zeros(M, 10); %10 polynomial features
Y = zeros(M, 1); % target variable

for i = 1:M
    % create regression vector
    x_reg = x(i + (nx-1):-1:i);
    u_reg = u_vec(i + (nu-1):-1:i);
    phi = [x_reg(:); u_reg(:)];

    % polynomial features
    poly_terms = [
        phi(1), phi(2), phi(3), ...
        phi(1)^2, phi(2)^2, phi(3)^2, ...
        phi(1)*phi(2), phi(1)*phi(3), phi(2)*phi(3), ...
        1 
    ];

    Phi(i, :) = poly_terms; 
    Y(i) = xdot(i + (nx-1)); % target variable
end


%% Cross-validation for Model Selection

% Cross-validation parameters
K = 5; 
model_count = 15;
N = length(t);
lambda = 0.01;
dt = t(2) - t(1); 

% Initialize arrays to store results
MSE_val_mean = zeros(model_count, 1);
MSE_val_std = zeros(model_count, 1);
J_scores = zeros(model_count, 1);
AIC_scores = zeros(model_count, 1);
BIC_scores = zeros(model_count, 1);
n_thetas = zeros(model_count, 1);

% Loop through models
for model_id = 1:model_count
    fprintf('Evaluating model %d...\n', model_id);
    mse_vals = zeros(K, 1);
    J_vals = zeros(K,1);
    aic_vals = zeros(K,1);
    bic_vals = zeros(K,1);
    theta_lengths = zeros(K,1);

    for k = 1:K
        % Random shuffle indices
        idx = randperm(N);
        split = round(0.8 * N);
        train_idx = idx(1:split);
        val_idx   = idx(split+1:end);

        % Train set
        x_train = x(train_idx);
        u_train = u_vec(train_idx);
        y_train = xdot(train_idx);

        % Validation set
        x_val = x(val_idx);
        u_val = u_vec(val_idx);
        y_val = xdot(val_idx);

        % RLS estimation
        [theta_hist, ~, ~] = rls_estimator(x_train, u_train, y_train, model_id);
        theta_final = theta_hist(:, end);
        n_theta = length(theta_final);
        theta_lengths(k) = n_theta;

        % Validation prediction
        y_val_hat = zeros(length(x_val), 1);
        for j = 1:length(x_val)
            phi = base_func(x_val(j), u_val(j), model_id);
            y_val_hat(j) = theta_final' * phi;
        end

        % Errors
        e = y_val - y_val_hat;
        mse_vals(k) = mean(e.^2);

        % J score
        E = sum(e.^2) * dt;  % Energy error
        J_vals(k) = E + lambda * n_theta;  % Total cost

        % AIC and BIC scores
        N_val = length(y_val);
        aic_vals(k) = N_val * log(mse_vals(k)) + 2 * n_theta;
        bic_vals(k) = N_val * log(mse_vals(k)) + log(N_val) * n_theta;

    end

    % mean values for the model
    MSE_val_mean(model_id) = mean(mse_vals);
    MSE_val_std(model_id) = std(mse_vals);
    J_scores(model_id) = mean(J_vals);
    AIC_scores(model_id) = mean(aic_vals);
    BIC_scores(model_id) = mean(bic_vals);
    n_thetas(model_id) = round(mean(theta_lengths));
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
MSE_val_mean = [0.10577, 0.0065057, 0.085163, 0.093295, 0.086362, ...
                0.04859, 0.0010955, 0.022357, 0.097763, 0.04757];
MSE_val_std = [0.042958, 0.0014375, 0.049912, 0.039324, 0.042178, ...
               0.021207, 0.00010858, 0.0031535, 0.038766, 0.012403];
n_thetas = [4, 4, 3, 4, 3, 4, 4, 4, 3, 6];
J_scores = [0.040202, 0.040012, 0.030163, 0.040178, 0.030165, ...
            0.040093, 0.040002, 0.040043, 0.030187, 0.060091];
AIC_scores = [-81.221, -184.12, -93.459, -87.074, -90.779, ...
              -110.16, -251.18, -136.72, -85.867, -104.96];
BIC_scores = [-74.671, -177.56, -88.546, -80.523, -85.866, ...
              -103.61, -244.63, -130.17, -80.955, -95.131];
metrics = [MSE_val_mean; MSE_val_std; J_scores; AIC_scores; BIC_scores];

% Normalization of metrics
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
