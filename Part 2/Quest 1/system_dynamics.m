function [t, x, x_dot, x_ddot, u] = system_dynamics(use_sine, T, dt, m, b, k)
    % Simulates the mass-spring-damper system
    % use_sine: true for sinusoidal input, false for constant
    % T: total time
    % dt: time step
    % m, b, k: system parameters

    t = 0:dt:T;
    N = length(t);

    if use_sine
        u = 2.5 * sin(t);
    else
        u = 2.5 * ones(size(t));
    end

    x = zeros(1,N);
    v = zeros(1,N);
    a = zeros(1,N);

    for i = 1:N-1
        a(i) = (u(i) - b*v(i) - k*x(i)) / m;
        v(i+1) = v(i) + a(i)*dt;
        x(i+1) = x(i) + v(i)*dt;
    end

    x_dot = gradient(x, dt);
    x_ddot = gradient(x_dot, dt);
end
