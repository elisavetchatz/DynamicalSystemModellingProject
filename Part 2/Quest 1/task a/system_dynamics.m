function xddot= system_dynamics(t, X, use_sine)
    % Defines the physical behavior of the system.

    m = 1.315;
    b = 0.225;
    k = 0.725;

    x = X(1);
    xdot = X(2);

    if use_sine
        u = 2.5 * sin(t);
    else
        u = 2.5;
    end
    
    xddot = (-b/m)*xdot - (k/m)*x + (1/m)*u;

end
    