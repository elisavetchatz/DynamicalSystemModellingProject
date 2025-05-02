function sys_out = lyap_estimation_parallel(t, var, mode)

    global m_real b_real k_real G u h
    
    sys_out = zeros(length(var),1);
    
    % System true parameters
    % (if you want disturbance h(t))
    if mode == 0
        x1 = var(1);  % position
        x2 = var(2);  % velocity
    elseif mode == 1
        x1 = var(1) + h(t); 
        x2 = var(2) + h(t);
    end
    
    % Estimated parameters
    m_est = var(3);
    b_est = var(4);
    k_est = var(5);
    
    % Estimated states
    x1_est = var(6);
    x2_est = var(7);
    
    % True system dynamics
    x1_dot = x2;
    x2_dot = (1/m_real) * (-b_real * x2 - k_real * x1 + u(t));
    
    % Estimation error (based on velocity)
    e = x2 - x2_est;
    
    % Parameter adaptation laws (Lyapunov-based)
    theta1_hat_dot = G(1,1) * e * (1/m_est^2) * (b_est*x2_est + k_est*x1_est - u(t));
    theta2_hat_dot = -G(2,2) * e * (x2_est/m_est);
    theta3_hat_dot = -G(3,3) * e * (x1_est/m_est);
    
    % Estimated system dynamics
    x1_est_dot = x2_est;
    x2_est_dot = (1/m_est) * (-b_est*x2_est - k_est*x1_est + u(t));
    
    % Fill output derivatives
    sys_out(1) = x1_dot;
    sys_out(2) = x2_dot;
    sys_out(3) = theta1_hat_dot;
    sys_out(4) = theta2_hat_dot;
    sys_out(5) = theta3_hat_dot;
    sys_out(6) = x1_est_dot;
    sys_out(7) = x2_est_dot;
    
end
    