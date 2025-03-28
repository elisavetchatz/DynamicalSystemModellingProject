%% Task 3a: Estimation with White Gaussian Noise

qdot_measurable = true; % true -> 2a, false -> 2b

% System Parameters
m = 0.75;
L = 1.25;
c = 0.15; 

% Add white Gaussian noise (around 5% of signal std)
noise_level_q = 0.05 * std(q);
noise_level_qdot = 0.05 * std(qdot);
noise_level_u = 0.05 * std(u_samples);

q_noisy = q + noise_level_q * randn(size(q));
qdot_noisy = qdot + noise_level_qdot * randn(size(qdot));
u_noisy = u_samples + noise_level_u * randn(size(u_samples));

% Define noisy input as a function
u_func_noisy = @(t) interp1(t_sim, u_noisy, t, 'linear', 'extrap');

% Prepare noisy measurement matrix
X_noisy = [q_noisy, qdot_noisy];

% Perform estimation with noisy signals
estimations_noisy = ls_estimation(X_noisy, t_sim, qdot_measurable);
L_est_n = estimations_noisy(1);
m_est_n = estimations_noisy(2);
c_est_n = estimations_noisy(3);

% --- Display comparison ---
fprintf('\n--- Parameter Comparison: Without vs With Noise ---\n');
fprintf('%-20s %-15s %-15s\n', 'Parameter', 'Noiseless', 'Noisy');
fprintf('%-20s %-15.4f %-15.4f\n', 'L [m]', L_est, L_est_n);
fprintf('%-20s %-15.4f %-15.4f\n', 'm [kg]', m_est, m_est_n);
fprintf('%-20s %-15.4f %-15.4f\n', 'c [Nm/s]', c_est, c_est_n);

% --- Optional: Bar chart comparison ---
figure;
bar([L_est, L_est_n; m_est, m_est_n; c_est, c_est_n]);
set(gca, 'xticklabel', {'L','m','c'});
legend('Noiseless', 'Noisy');
title('Comparison of Estimated Parameters');
ylabel('Estimated Value');
grid on;
