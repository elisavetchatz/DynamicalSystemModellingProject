function [m_hat, b_hat, k_hat, x_hat] = lyap_parallel_estimator(x, x_dot, x_ddot, u, dt)
    % Lyapunov-based Parallel Structure Estimator
    N = length(x);
    m_hat = zeros(1,N); m_hat(1) = 1;
    b_hat = zeros(1,N); b_hat(1) = 1;
    k_hat = zeros(1,N); k_hat(1) = 1;

    x_hat = zeros(1,N);
    v_hat = zeros(1,N);
    
    gamma = 5;

    for i = 2:N-1
        % simulate estimated system with current parameter estimates
        a_hat = (u(i) - b_hat(i-1)*v_hat(i) - k_hat(i-1)*x_hat(i)) / m_hat(i-1);
        v_hat(i+1) = v_hat(i) + a_hat*dt;
        x_hat(i+1) = x_hat(i) + v_hat(i)*dt;

        % tracking error
        e = x(i) - x_hat(i);

        % regression vector
        phi = [x_ddot(i); x_dot(i); x(i)];

        % parameter update law from Lyapunov function
        theta_dot = -gamma * phi * e;

        m_hat(i) = m_hat(i-1) + theta_dot(1)*dt;
        b_hat(i) = b_hat(i-1) + theta_dot(2)*dt;
        k_hat(i) = k_hat(i-1) + theta_dot(3)*dt;
    end
end
