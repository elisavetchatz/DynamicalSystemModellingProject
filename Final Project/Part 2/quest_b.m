%% Final Model Evaluation on 4 Different Input Signals

% --- Simulation settings ---
Tsim = 20;
Tsampl = 0.001;
tspan = 0:Tsampl:Tsim;
x0 = 0;
dt = Tsampl;

% --- Selected model and regression parameters ---
model_id = 8;  % Exponential model
nx = 2; nu = 1;  % Regression order

% --- Input signals: from simple to complex ---
input_signals = {
    @(t) sin(t), @(t) sin(2*t), @(t) make_rbfs(t, 10, 1), @(t) 0.7*sin(t) + 0.3*cos(3*t)
};

input_labels = {
    'Input 1: sin(t)', 'Input 2: sin(2t)', 'Input 3: Gaussian RBF pulse', 'Input 4: 0.7sin(t) + 0.3cos(3t)'
};

for i = 1:length(input_signals)
    fprintf('\n--- Testing on %s ---\n', input_labels{i});
    
    % Define current input
    u_test = input_signals{i};

    % Simulate system
    [t_test, x_test] = ode45(@(t, x) true_func(t, x, u_test), tspan, x0);
    u_test_vec = u_test(t_test);

    % Compute ground truth derivative
    xdot_true = -x_test.^3 + tanh(x_test) + 1 ./ (1 + x_test.^2) + u_test_vec;

    % Build regression vector
    [Phi_test, ~] = build_phi_vector(x_test, u_test_vec, nx, nu, model_id);

    % Align dimensions due to regression delay
    valid_idx = max(nx, nu) + 1 : length(t_test);
    xdot_true_valid = xdot_true(valid_idx);
    t_valid = t_test(valid_idx);
    x_valid = x_test(valid_idx);

    % Estimate parameters using RLS
    [theta_hist, ~, ~] = rls_estimator(Phi_test, xdot_true_valid);
    theta_hat = theta_hist(:, end);

    % Compute estimated derivative
    xdot_est = Phi_test * theta_hat;

    % Compute error metrics
    error = xdot_true_valid - xdot_est;
    mse = mean(error.^2);
    rmse = sqrt(mse);

    % Print results
    fprintf('MSE: %.6f\n', mse);
    fprintf('RMSE: %.6f\n', rmse);

    % --- Plot true vs estimated derivative ---
    figure;
    plot(t_valid, xdot_true_valid, 'b', 'LineWidth', 1.5); hold on;
    plot(t_valid, xdot_est, 'r--', 'LineWidth', 1.5);
    xlabel('Time [s]'); ylabel('\dot{x}(t)');
    legend('True', 'Estimated');
    title(['Estimated Derivative - ', input_labels{i}]);
    grid on;

    % --- Plot estimation error ---
    figure;
    plot(t_valid, error, 'k', 'LineWidth', 1.2);
    xlabel('Time [s]'); ylabel('Estimation Error');
    title(['Estimation Error - ', input_labels{i}]);
    grid on;
end
