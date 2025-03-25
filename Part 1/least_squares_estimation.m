function [estimations, model] = least_squares_estimation(y, time)

    g = 9.81;
    % Λ(s) = (s+1)^2
    syms s
    lamda = sym2poly((s+1)^2);

    D1 = tf([-1 0], lamda);
    D2 = tf([0 -1], lamda);  
    D3 = tf([0 1], lamda);

    % Regression Matrix
    phi1 = lsim(D1, y, time);
    phi2 = lsim(D2, y, time);
    phi3 = lsim(D3, u_syms(time), time);
    Phi = [phi1 phi2 phi3];

    theta = (Phi' * Phi) \ (Phi' * y);

    % Parameter Estimation
    L = g / theta(1);
    mL2 = 1 / theta(3);
    c = theta(2) * mL2;
    m = mL2 / (L^2);

    fprintf('Parameter Estimation:\n');
    fprintf('L_est = %.4f m\n', L);
    fprintf('m_est = %.4f kg\n', m);    
    fprintf('c_est = %.4f Nm/sec\n', c);

    ymodel = Phi * theta';
    error = y - ymodel;

    estimations = [L, m, c];
    model = [ymodel, error];
end