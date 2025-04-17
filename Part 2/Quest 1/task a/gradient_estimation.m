function _ = gradient_estimation(t, X, Phi, Theta, vars, u_func, Gamma, am)
    %Theta = [1/m, -b/m, -k/m]
    % xddot = theta1*u + theta2*xdot + theta3*x
    % X = [x, xdot, xddot_est]
    % Phi = [u, xdot, x]
    % vars = [m, b, k]


    x = X(:, 1);
    xdot = X(:, 2);
    yf = X(:, 3); % filtered xddot
    
    phi1 = Phi(:, 1); %u
    phi2 = Phi(:, 2); %xdot
    phi3 = Phi(:, 3); %x

    theta1 = Theta(:, 1); % 1/m
    theta2 = Theta(:, 2); % -b/m
    theta3 = Theta(:, 3); % -k/m
    
    m_est = vars(1);
    b_est = vars(2);
    k_est = vars(3);
    
    u = u_func(t);

    yfdot = -am * yf; %%%%%%%5
    phi1dot  = -am * phi1  + u;
    phi2dot  = -am * phi2  - xdot;
    phi3dot  = -am * phi3  - x;
    
    % Εκτιμώμενη έξοδος
    yhat = theta * Phi;

    % Σφάλμα
    e = yf - yhat;

    % Gradient update
    thetadot = Gamma * Phi * e;
end


