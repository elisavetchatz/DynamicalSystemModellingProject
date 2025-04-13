function xdot = system_dynamics(t, x, m, b, k, use_sine)

    if use_sine
        u = 2.5 * sin(t);
    else
        u = 2.5 * ones(size(t));
    end

    x1 = x(1);
    x2 = x(2);

    x2_dot = (1/m) * (u - b*x2 - k*x1);
    x1_dot = x2;
    xdot = [x1_dot; x2_dot];
end
