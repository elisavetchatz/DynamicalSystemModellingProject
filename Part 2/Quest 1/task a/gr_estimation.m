function [zdot, phidot, thetadot] = gr_estimation(t, X, phi, theta, am, gamma)

    x = X(1);
    xdot = X(2);
    xddot = X(3);

    u = 2.5;

    z = phi(4);

    % Update filtered inputs
    phidot1 = - am * phi1 + xdot;
    phidot2 = - am * phi2 + x;
    phidot3 = - am * phi3 + u;

    phidot = [phidot1; phidot2; phidot3];
    
    zdot = -am * phi4 + xddot;

    phivec = [phi1; phi2; phi3];

    % Estimate Output
    xhat = theta' * phivec;
    % Estimate Error
    e = z - xhat;
    % Update Parameters
    thetadot = gamma * e * phivec;
end
