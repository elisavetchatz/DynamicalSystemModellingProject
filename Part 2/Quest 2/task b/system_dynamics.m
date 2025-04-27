function r_ddot = system_dynamics(t, var, mode)

    global a1 a2 a3 b u h
    
    r = var(1);
    r_dot = var(2);
    
    if mode == 0
        disturbance = 0;
    else
        disturbance = h(t);
    end
    
    r_ddot = -a1*r_dot - a2*sin(r) + a3*r_dot^2*sin(2*r) + b*u(t) + disturbance;
    
    end
    