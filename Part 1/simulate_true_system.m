function [t, q, qdot, u] = simulate_true_system(m, L, c, g, A0, omega, x0, t_sim)

    % input function
    u_func = @(t) A0 * sin(omega * t);

    % System dynamics function
    system_fun = @(t, x) system_dynamics(t, x, m, L, c, g, u_func);

    [t, X] = ode45(system_fun, t_sim, x0);

    q = X(:, 1);
    qdot = X(:, 2);
    u = u_func(t_sim);
end
