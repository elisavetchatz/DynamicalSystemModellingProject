function zdot = mtopo_proj_estimator(t, z, u, A, B, G)

    u = u(t);
    
    x = z(1:2);           % [x1; x2]
    xhat = z(3:4);        % [xhat1; xhat2]
    a11 = z(5); 
    a12 = z(6);
    a21 = z(7); 
    a22 = z(8);
    b1  = z(9); 
    b2  = z(10);

    % System dynamics 
    dx = A*x + B*u;
    
    % Estimator dynamics
    Ahat = [a11 a12; a21 a22];
    Bhat = [b1; b2];
    dxhat = Ahat*xhat + Bhat*u;

    % Error dynamics
    ex = x - xhat;

    g1 = G(1);
    g2 = G(2);
    g3 = G(3);
    g4 = G(4);
    g5 = G(5);
    g6 = G(6);

    % Projection for a11
    if (a11 <= -3 && x(1)*ex(1) < 0) || (a11 >= -1 && x(1)*ex(1) > 0)
        a11_dot = 0;
    else
        a11_dot = -g1 * x(1) * ex(1);
    end

    % Projection for b2
     if b2 <= 1 && u*ex(2) < 0
        b2_dot = 0;
    else
        b2_dot = g6 * u * ex(2);
    end

    % Rest of estimation parameters without projection
    a12_dot = g2 * x(2) * ex(1);
    a21_dot = g3 * x(1) * ex(2);
    a22_dot = g4 * x(2) * ex(2);
    b1_dot  = g5 * u * ex(1);

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
    




