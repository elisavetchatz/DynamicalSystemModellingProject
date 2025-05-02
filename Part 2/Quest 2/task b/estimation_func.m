function dx = adaptive_roll_estimator(t, x, theta, Gamma, obs_gain, ...
    phi_0, phi_inf, lambda, rho, ...
    k_alpha, k_beta, r_target)

% === State Decomposition ===
x1 = x(1);  % roll angle
x2 = x(2);  % roll rate
x1_hat = x(3);
x2_hat = x(4);
theta_hat = x(5:8);

% === Desired Trajectory ===
r_d = r_target * sin(pi*t/20);

% === Nonlinear Features ===
f1 = sin(x1);
f2 = x2^2 * sin(2*x1);

% === Tracking Control Law ===
phi = (phi_0 - phi_inf)*exp(-lambda*t) + phi_inf;
z1 = (x1 - r_d) / phi;
alpha = -k_alpha * log((1 + z1)/(1 - z1));

z2 = (x2 - alpha) / rho;
control_input = -k_beta * log((1 + z2)/(1 - z2));

% === True System Dynamics ===
dx1 = x2;
dx2 = theta(1)*x2 + theta(2)*f1 + theta(3)*f2 + theta(4)*control_input;

% === Estimation Errors ===
e1 = x1 - x1_hat;
e2 = x2 - x2_hat;

% === Observer Dynamics ===
dx1_hat = x2_hat;
dx2_hat = theta_hat(1)*x2 + theta_hat(2)*f1 + theta_hat(3)*f2 + ...
theta_hat(4)*control_input + obs_gain*(e1 + e2);

% === Parameter Adaptation Laws ===
dtheta = Gamma * (e2 * [x2; f1; f2; control_input]);

% === Output Derivative ===
dx = zeros(8,1);
dx(1:2) = [dx1; dx2];
dx(3:4) = [dx1_hat; dx2_hat];
dx(5:8) = dtheta;
end
    