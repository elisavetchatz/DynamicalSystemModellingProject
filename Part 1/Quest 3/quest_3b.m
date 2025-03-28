%% Task 3b: Effect of Sampling Period Ts on Estimation Accuracy

Ts_values = 0.01:0.02:0.5;  % Sampling periods to test
true_params = [L, m, c];

errors_L = zeros(size(Ts_values));
errors_m = zeros(size(Ts_values));
errors_c = zeros(size(Ts_values));

for i = 1:length(Ts_values)
    Ts = Ts_values(i);
    t_local = 0:Ts:20;

    % Simulate system at current Ts
    [~, X_local] = ode45(@(t, x) system_dynamics(t, x, m, L, c, g, u_func), t_local, x0);
    q_l = X_local(:,1);
    qdot_l = X_local(:,2);
    X_input = [q_l, qdot_l];

    % Estimate parameters
    est = ls_estimation(X_input, t_local, qdot_measurable);
    
    % Store absolute errors
    errors_L(i) = abs(est(1) - L);
    errors_m(i) = abs(est(2) - m);
    errors_c(i) = abs(est(3) - c);
end

% --- Plotting Errors vs Ts ---
figure;
plot(Ts_values, errors_L, '-o', 'LineWidth', 2); hold on;
plot(Ts_values, errors_m, '-s', 'LineWidth', 2);
plot(Ts_values, errors_c, '-^', 'LineWidth', 2);
xlabel('Sampling Period Ts [sec]');
ylabel('Estimation Error');
legend('Error in L', 'Error in m', 'Error in c');
title('Parameter Estimation Error vs Sampling Period Ts');
grid on;
