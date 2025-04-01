function [estimations, cond_number] = ls_estimation(X, time, qdot_measurable)

    x = X(:, 1);  % q(t)
    xdot = X(:, 2);  % q̇(t)

    g = 9.81;
    A0 = 4;
    omega = 2;
    u = A0 * sin(omega * time)';

    % Λ(s) = (s+1)^2
    syms s
    lamda = sym2poly((s+1)^2);

    % Create transfer functions for:
    % - D1 = s^2 / Λ(s)
    % - D2 = s / Λ(s)
    % - D3 = 1 / Λ(s)
    D1 = tf([1 0 0], lamda);  
    D2 = tf([0 1 0], lamda);  
    D3 = tf([0 0 1], lamda);

    % Define Phi matrix through filtered signals
    phi1 = lsim(D1, x, time);  % filtered ddot(q)
    if qdot_measurable == true 
        phi2 = lsim(D3, xdot, time);  
        disp('Using q̇(t) for estimation\n');
    else
        phi2 = lsim(D2, x, time);  
        disp('Using q(t) for estimation\n');
    end 
    phi3 = lsim(D3, x, time);  % filtered q
    yf = lsim(D3, u, time); % filtered u(t)
    Phi = [phi1, phi2, phi3];

    cond_number = cond(Phi' * Phi);
    fprintf('Condition Number of Phi: %.4f\n', cond_number);

    % Least Squares Estimation
    theta = (Phi' * Phi) \ (Phi' * yf); 

    theta1 = theta(1);  % mL^2
    theta2 = theta(2);  % c
    theta3 = theta(3);  % mgL

    % Recover physical parameters
    L = (theta1 * g) / theta3;
    m = theta1 / L^2;
    c = theta2;

    fprintf('Parameter Estimation:\n');
    fprintf('L_est = %.4f m\n', L);
    fprintf('m_est = %.4f kg\n', m);    
    fprintf('c_est = %.4f Nm/sec\n', c); 

    estimations = [L, m, c];
end