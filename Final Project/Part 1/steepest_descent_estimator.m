function zdot = steepest_descent_estimator(t, z, A, b, Gamma, am, u)

    u = u(t);
    % omega = omega(t);
    
    x = z(1:2);           % [x1; x2]
    xhat = z(3:4);        % [xhat1; xhat2]
    a11 = z(5); 
    a12 = z(6);
    a21 = z(7); 
    a22 = z(8);
    b1  = z(9); 
    b2  = z(10);

    % System dynamics
    dx = A * x + b * u;  % No disturbance term in this case

    % Estimator dynamics
    Ahat = [a11 a12; a21 a22];
    Bhat = [b1; b2];
    dxhat = Ahat * x + Bhat * u;  % No disturbance term in this case

    % Error dynamics
    ex = x - xhat;

    %
    a11_dot = -Gamma(1) * x(1) * ex(1);
    a12_dot = Gamma(2) * x(2) * ex(1);
    a21_dot = Gamma(3) * x(1) * ex(2);
    a22_dot = Gamma(4) * x(2) * ex(2);
    b1_dot  = Gamma(5) * u * ex(1);
    b2_dot  = Gamma(6) * u * ex(2);

    zdot = zeros(10,1);
    zdot(1:2) = dx;          % x
    zdot(3:4) = dxhat;       % x hat
    zdot(5) = a11_dot;
    zdot(6) = a12_dot;
    zdot(7) = a21_dot;
    zdot(8) = a22_dot;
    zdot(9) = b1_dot;
    zdot(10) = b2_dot;

end