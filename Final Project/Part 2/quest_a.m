clc; clear;  close all;

tspan = [0 20]; % time span
x0 = 0; % initial condition

u = @(t) sin(t) + 0.5*cos(3*t);

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
plot(t, xdot, 'k'); ylabel('dx/dt'); xlabel('Time [s]'); title('True Derivative'); grid on;

%% Design Estimation


%% Cross-validation for Model Selection
N = length(t);
train_ratio = 0.8;
N_train = round(train_ratio * N);

% train and test sets
x_train = x(1:N_train);
u_train = u_vec(1:N_train);
y_train = xdot(1:N_train);

x_val = x(N_train+1:end);
u_val = u_vec(N_train+1:end);
y_val = xdot(N_train+1:end);

% Initialize results storage
model_count = 10;
MSE_val = zeros(model_count, 1);

% Loop through models
for model_id = 1:model_count
    fprintf('Evaluating model %d...\n', model_id);

    % RLS in training set
    [theta_hist, ~, ~] = rls_estimator(x_train, u_train, y_train, model_id);
    theta_final = theta_hist(:, end);

    % Estimating on validation set
    N_val = length(x_val);
    y_val_hat = zeros(N_val, 1);

    for k = 1:N_val
        phi = base_func(x_val(k), u_val(k), model_id);
        y_val_hat(k) = theta_final' * phi;
    end

    % MSE
    error_val = y_val - y_val_hat;
    MSE_val(model_id) = mean(error_val.^2);
end

%% Results
model_labels = {'Poly', 'RBF', 'Light', 'Hybrid', 'Sigmoid', ...
                '2 RBFs', 'Enriched Light', 'Nonlinear', ...
                '2nd Order Poly', '5th Order Poly'};

%Table
fprintf('\nModel Evaluation Results (Validation MSE):\n');
for i = 1:model_count
    fprintf('Model %d (%s): MSE = %.5f\n', i, model_labels{i}, MSE_val(i));
end

% Plot
figure;
bar(MSE_val);
set(gca, 'XTickLabel', model_labels, 'FontSize', 12);
ylabel('Validation MSE'); title('Model Comparison via Cross-Validation');
grid on;

% Plot estimated vs true derivative for all models
figure;
hold on;
plot(t, xdot, 'k', 'LineWidth', 3); % True derivative

colors = lines(model_count); 

for model_id = 1:model_count
    [theta_hist, ~, ~] = rls_estimator(x, u_vec, xdot, model_id);
    theta_final = theta_hist(:, end);

    y_hat_all = zeros(N,1);
    for k = 1:N
        phi = base_func(x(k), u_vec(k), model_id);
        y_hat_all(k) = theta_final' * phi;
    end

    plot(t, y_hat_all, '--', 'Color', colors(model_id,:), 'LineWidth', 1.3);
end

legend_labels = [{'True \dot{x}'} model_labels];
legend(legend_labels, 'Location', 'BestOutside');
xlabel('Time [s]'); ylabel('\dot{x}(t)');
title('Estimated vs True \dot{x}(t) for All Models');
grid on;


%
figure;
colors = lines(model_count);  % σταθερά χρώματα

rows = 5; cols = 2;

for model_id = 1:model_count
    [theta_hist, ~, ~] = rls_estimator(x, u_vec, xdot, model_id);
    theta_final = theta_hist(:, end);

    y_hat = zeros(N,1);
    for k = 1:N
        phi = base_func(x(k), u_vec(k), model_id);
        y_hat(k) = theta_final' * phi;
    end

    error = abs(xdot - y_hat);

    subplot(rows, cols, model_id);
    plot(t, error, 'Color', colors(model_id,:), 'LineWidth', 1.2);
    title(model_labels{model_id});
    xlabel('Time [s]');
    ylabel('|e(t)|');
    grid on;
end

sgtitle('Absolute Estimation Error per Model (|e(t)|)');






lambda = 0.01;  % ρυθμίζεις τη βαρύτητα
dt = t(2) - t(1);

J_scores = zeros(model_count, 1);      % Συνολικά κόστη
n_thetas = zeros(model_count, 1);      % Πλήθος παραμέτρων
E_scores = zeros(model_count, 1);      % Ενεργειακό σφάλμα

for model_id = 1:model_count
    [theta_hist, ~, ~] = rls_estimator(x, u_vec, xdot, model_id);
    theta_final = theta_hist(:, end);
    n_theta = length(theta_final);

    y_hat = zeros(N, 1);
    for k = 1:N
        phi = base_func(x(k), u_vec(k), model_id);
        y_hat(k) = theta_final' * phi;
    end

    e = xdot - y_hat;
    E = sum(e.^2) * dt;

    J = E + lambda * n_theta;

    % Store
    J_scores(model_id) = J;
    n_thetas(model_id) = n_theta;
    E_scores(model_id) = E;
end


figure;
bar(J_scores);
set(gca, 'XTickLabel', model_labels, 'FontSize', 12);
ylabel('J = ∫e²dt + λ·n_θ');
title(sprintf('Total Modeling Cost (λ = %.3f)', lambda));
grid on;


fprintf('Model Summary (λ = %.3f):\n', lambda);
fprintf('ID | Model     | E_total      | n_θ | J_total\n');
fprintf('----------------------------------------------\n');
for i = 1:model_count
    fprintf('%2d | %-10s | %.6f | %2d  | %.6f\n', ...
        i, model_labels{i}, E_scores(i), n_thetas(i), J_scores(i));
end
