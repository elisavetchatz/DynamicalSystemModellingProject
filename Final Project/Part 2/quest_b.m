%% Τελική Αξιολόγηση Επιλεγμένου Μοντέλου με Νέα Είσοδο

% --- Ρυθμίσεις προσομοίωσης ---
Tsim = 20;
Tsampl = 0.001;
tspan = 0:Tsampl:Tsim;
x0 = 0;
dt = Tsampl;

% --- Επιλεγμένο μοντέλο ---
model_id = 8;   % π.χ. Exponential
nx = 2; nu = 1; % τάξη παλινδρόμησης

% --- Νέα είσοδος ---
%u_test = @(t) sin(2*t);  % Είσοδος διαφορετικής συχνότητας
u_test = @(t) make_rbfs(t, 10, 1);  % Νέα είσοδος με διαφορετική συχνότητα

% --- Προσομοίωση του συστήματος ---
[t_test, x_test] = ode45(@(t, x) true_func(t, x, u_test), tspan, x0);
u_test_vec = u_test(t_test);

% --- Πραγματική παράγωγος του συστήματος ---
xdot_true = -x_test.^3 + tanh(x_test) + 1 ./ (1 + x_test.^2) + u_test_vec;

% --- Χτίσιμο διανύσματος παλινδρόμησης & εκτίμηση ---
[Phi_test, ~] = build_phi_vector(x_test, u_test_vec, nx, nu, model_id);

% Μείωση xdot_true ώστε να ταιριάζει σε μέγεθος με το Phi_test
valid_idx = max(nx, nu) + 1 : length(t_test);
xdot_true_valid = xdot_true(valid_idx);

% RLS εκτίμηση
[theta_hist, ~, ~] = rls_estimator(Phi_test, xdot_true_valid);
theta_hat = theta_hist(:, end);
xdot_est = Phi_test * theta_hat;

% --- Αξιολόγηση ---
error_test = xdot_true_valid - xdot_est;
mse_test = mean(error_test.^2);
rmse_test = sqrt(mse_test);
t_valid = t_test(valid_idx);
x_valid = x_test(valid_idx);

fprintf('MSE στο νέο dataset: %.6f\n', mse_test);
fprintf('RMSE στο νέο dataset: %.6f\n', rmse_test);

% --- Σχεδίαση Εκτίμησης vs Πραγματικής Τιμής ---
figure;
plot(t_valid, xdot_true_valid, 'b', 'LineWidth', 1.5); hold on;
plot(t_valid, xdot_est, 'r--', 'LineWidth', 1.5);
xlabel('Χρόνος [s]'); ylabel('\dot{x}(t)');
legend('Πραγματική', 'Εκτίμηση');
title('Εκτίμηση παραγώγου με νέο σήμα εισόδου');
grid on;

% --- Σχεδίαση Σφάλματος ---
figure;
plot(t_valid, error_test, 'k', 'LineWidth', 1.2);
xlabel('Χρόνος [s]'); ylabel('Σφάλμα');
title('Σφάλμα Εκτίμησης \dot{x}(t) σε νέο dataset');
grid on;

