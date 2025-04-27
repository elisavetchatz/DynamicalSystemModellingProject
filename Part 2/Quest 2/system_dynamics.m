function sys_out = system_dynamics(t, var)

    global a1 a2 a3 b rd_func phi_func rho k1 k2
    
    % States
    r = var(1);
    r_dot = var(2);
    
    % Desired trajectory
    rd = rd_func(t);
    
    % Calculate phi(t)
    phi = phi_func(t);
    
    % First-level error
    z1 = (r - rd)/phi;
    
    % T(z1)
    T_z1 = log((1+z1)/(1-z1));
    
    % Virtual control input alpha
    alpha = -k1 * T_z1;
    
    % Second-level error
    z2 = (r_dot - alpha)/rho;
    
    % T(z2)
    T_z2 = log((1+z2)/(1-z2));
    
    % Final control input
    u = -k2 * T_z2;
    
    % System dynamics (no disturbance d(t))
    r_dot_dot = -a1*r_dot - a2*sin(r) + a3*r_dot^2*sin(2*r) + b*u;
    
    % Output derivatives
    sys_out = zeros(2,1);
    sys_out(1) = r_dot;
    sys_out(2) = r_dot_dot;
    
    end
    