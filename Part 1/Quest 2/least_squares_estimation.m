function [estimations, model] = least_squares_estimation(x, time)

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

    fprintf('Size of x: [%d, %d]\n', size(x));
    fprintf('Size of u: [%d, %d]\n', size(u));
    fprintf('Size of time: [%d, %d]\n', size(time));

    % Apply filters to q(t) and u(t)
    phi1 = lsim(D1, x, time);  % filtered ddot(q)
    phi2 = lsim(D2, x, time);  % filtered dot(q)
    phi3 = lsim(D3, x, time);  % filtered q
    yf = lsim(D3, u, time); % filtered u(t)

    Phi = [phi1, phi2, phi3];

    % Least Squares Estimation
    theta = (Phi' * Phi) \ (Phi' * yf); % theta1, 2, 3 = mL^2, c, mgL

    % Parameter Estimation
    L = g / theta(1);
    mL2 = 1 / theta(3);
    c = theta(2) * mL2;
    m = mL2 / (L^2);

    fprintf('Parameter Estimation:\n');
    fprintf('L_est = %.4f m\n', L);
    fprintf('m_est = %.4f kg\n', m);    
    fprintf('c_est = %.4f Nm/sec\n', c);

    % ymodel = Phi * theta';
    % error = x - ymodel;

    estimations = [L, m, c];
    % model = [ymodel, error];
end