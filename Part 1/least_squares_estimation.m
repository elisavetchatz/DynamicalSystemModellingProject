function estimations = least_squares_estimation(X)
    %X = [q, qdot, u]

    g = 9.81;

    % Parameter estimation
    Phi = [X(2:end-1,1) X(1:end-2,1) X(2:end-1,2)];
    y = X(3:end,1);
    theta = (Phi' * Phi) \ (Phi' * y);

    L_est = g / theta(1);
    mL2_est = 1 / theta(3);
    c_est = theta(2) * mL2_est;
    m_est = mL2_est / (L_est^2);

    A_est = [0 1; -g/L_est -c_est/(m_est*L_est^2)];
    B_est = [0; 1/(m_est*L_est^2)];
    dxdt_est = @(t, x) A_est*x + B_est*X(t,2);
    [t_cont, X_est] = ode45(dxdt_est, 0:1e-5:20, [0; 0]);

    q_est = X_est(:,1);
    qdot_est = X_est(:,2);

    error_est = y - q_est;

    fprintf('Parameter Estimation:\n');
    fprintf('L_est = %.4f m\n', L_est);
    fprintf('m_est = %.4f kg\n', m_est);    
    fprintf('c_est = %.4f Nm/sec\n', c_est);

    estimations = {L_est, m_est, c_est, A_est, B_est, t_cont, q_est, qdot_est, error_est};
end