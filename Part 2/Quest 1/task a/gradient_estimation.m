function [x_hat, xdot_hat, theta_hist, e_hist] = gradient_estimation(X, t, u, lambda, gamma, theta0)
    % gradient_estimation - Real-time parameter estimation using Gradient Descent with filtering
    %
    % Inputs:
    %   X        : [N x 2] matrix with system states [x(t), xdot(t)]
    %   t        : [N x 1] time vector
    %   u        : [N x 1] input signal u(t)
    %   lambda   : filter constant 
    %   gamma    : learning rate for gradient descent 
    %
    % Outputs:
    %   theta_hist : [N x 3] parameter estimates history [m, b, k]
    %   e_hist     : [N x 1] prediction error history
    
        x = X(:, 1);         
        xdot = X(:, 2);      
        dt = t(2) - t(1);
        N = length(t);
    
        theta_hist = zeros(N, 3);        % history of estimates
        e_hist = zeros(N, 1);            % history of errors

        % initial parameter estimates [m, b, k]
        if nargin < 6
            theta_hat = [1, 0, 0];  % default: start at [0; 0; 0]
        else
            theta_hat = theta0(:);   % user-defined initial estimate
        end
    
        % Define Lambda(s) = (s + lambda)^2
        syms s
        Lambda = sym2poly((s + lambda)^2);
    
        % Define filtering transfer functions:
        % D1 = s^2 / Lambda(s)
        % D2 = s   / Lambda(s)
        % D3 = 1   / Lambda(s)
        D1 = tf([1 0 0], Lambda);
        D2 = tf([0 1 0], Lambda);
        D3 = tf([0 0 1], Lambda);
    
        % Apply filters to signals
        phi1 = lsim(D1, x, t);  % filtered acceleration (q̈)
        %phi2 = lsim(D3, xdot, t);  % filtered q̇(t)
        phi2 = lsim(D2, x, t);     % estimate q̇(t) from q(t)
        phi3 = lsim(D3, x, t);         % filtered position q(t)
        yf = lsim(D3, u, t);           % filtered input u(t)
    
        % Gradient-based estimation loop
        for i = 1:N
            phi = [phi1(i); phi2(i); phi3(i)];
            y_hat = phi' * theta_hat;             % prediction % ŷ = φ^T * θ̂
            error = yf(i) - y_hat;                % prediction error % e(t) = y - ŷ
    
            theta_hat = theta_hat + gamma * phi * error * dt;  % update
    
            % Store results
            theta_hist(i, :) = theta_hat';
            e_hist(i) = error;
        end
    
        % Reconstruct x_hat from the estimated parameters
        % using the actual input u(t)
        x_hat(1) = x(1);
        xdot_hat(1) = xdot(1);  % or 0 if no measurement

    for i = 2:N
        m_hat = theta_hist(i-1,1);
        b_hat = theta_hist(i-1,2);
        k_hat = theta_hist(i-1,3);

        if abs(m_hat) < 1e-4
            m_hat = sign(m_hat) * 1e-4;
        end

        xddot_hat = (1 / m_hat) * (u(i-1) - b_hat * xdot_hat(i-1) - k_hat * x_hat(i-1));
        xdot_hat(i) = xdot_hat(i-1) + dt * xddot_hat;
        x_hat(i) = x_hat(i-1) + dt * xdot_hat(i-1);
    end

    % Final printout (optional)
    fprintf('Final Parameter Estimates:\n');
    fprintf('m̂ = %.4f kg\n', theta_hat(1));
    fprintf('b̂ = %.4f Ns/m\n', theta_hat(2));
    fprintf('k̂ = %.4f N/m\n', theta_hat(3));

end