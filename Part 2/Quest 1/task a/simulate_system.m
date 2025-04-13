function xdot = simulate_system(t, x_all)
    % x_all = [x; dx; z; phi1; phi2; phi3; θ̂1; θ̂2; θ̂3]
    
    x = x_all(1);
    dx_val = x_all(2);
    phi = x_all(4:6);
    z = x_all(3);
    theta = x_all(7:9);
    
    % υπολογισμός επιτάχυνσης
    ddx = system_dynamics(t, x, dx_val);

    X = [x, dx_val, ddx]';
    
    % gradient εκτιμητής
    [dzt, dphit, dthet] = estimation_gradient(t, X, [phi; z], theta);
    
    % παράγωγοι x και dx
    dx1 = dx_val;
    dx2 = ddx;
    
    % τελική στοίβαξη
    xdot = [dx1; dx2; dzt; dphit; dthet];
end
    