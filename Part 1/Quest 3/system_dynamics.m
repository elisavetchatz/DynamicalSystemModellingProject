function xdot = system_dynamics(t, x, m, L, c, g, u_func)
    q = x(1);
    q_dot = x(2);
    u = u_func(t);
    q_ddot = (1 / (m * L^2)) * (u - c * q_dot - m * g * L * q);
    xdot = [q_dot; q_ddot];
end