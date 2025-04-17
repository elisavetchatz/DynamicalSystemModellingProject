function xdot = system_dynamics(t, x, m, k, b, u_func)
    x1 = x(1); 
    x2 = x(2);
    u = u_func(t); 

    x1dot = x2;
    x2dot = -k/m*x1 - b/m*x2 + 1/m*u;

    xdot = [x1dot; x2dot];
end