function [m_hat, b_hat, k_hat, x_hat] = gr_estimation(X, u, dt)

    % X = [x, x_dot, x_ddot]
    x = X(1,:);
    x_dot = X(2,:);
    x_ddot = X(3,:);
    
    N = length(x);
    m_hat = zeros(1,N); m_hat(1) = 0;
    b_hat = zeros(1,N); b_hat(1) = 0;
    k_hat = zeros(1,N); k_hat(1) = 0;

    x_hat = zeros(1,N);
    v_hat = zeros(1,N);

    gamma = 5;

    for i = 2:N-1
        phi = [x_ddot(i); x_dot(i); x(i)];
        u_hat = m_hat(i-1)*x_ddot(i) + b_hat(i-1)*x_dot(i) + k_hat(i-1)*x(i);
        e = u(i) - u_hat;
        theta_dot = gamma * phi * e;

        m_hat(i) = m_hat(i-1) + theta_dot(1)*dt;
        b_hat(i) = b_hat(i-1) + theta_dot(2)*dt;
        k_hat(i) = k_hat(i-1) + theta_dot(3)*dt;

        a_hat = (u(i) - b_hat(i)*v_hat(i) - k_hat(i)*x_hat(i)) / m_hat(i);
        v_hat(i+1) = v_hat(i) + a_hat*dt;
        x_hat(i+1) = x_hat(i) + v_hat(i)*dt;
    end
end
