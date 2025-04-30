function sys_out = estimation_func(t, var, mode)

    global G u
    
    sys_out = zeros(length(var),1);
    
    % Extract states
    r = var(1);
    r_dot = var(2);
    
    % Estimated parameters
    theta1_hat = var(3);
    theta2_hat = var(4);
    theta3_hat = var(5);
    theta4_hat = var(6);
    
    % Regressor φ(t)
    phi = [r_dot; sin(r); r_dot^2*sin(2*r); u(t)];
    
    % Estimated output
    r_ddot_est = [theta1_hat; theta2_hat; theta3_hat; theta4_hat]' * phi;
    
    % True output (no disturbance)
    r_ddot_true = system_dynamics(t, [r; r_dot], 0);
    
    % Estimation error
    e = r_ddot_true - r_ddot_est;
    
    % Dynamics
    sys_out(1) = r_dot;        % r_dot
    sys_out(2) = r_ddot_true;  % r_ddot (real)
    
    % Parameter estimation laws
    theta_dot = G * phi * e;
    
    sys_out(3:6) = theta_dot;
    
end
    