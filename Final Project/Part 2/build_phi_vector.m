function [Phi, Y] = build_phi_vector(x, u_vec, nx, nu, model_id)
    % x: state vector (N x 1)
    % u_vec: input vector (N x 1)
    % nx: number of state variables
    % nu: number of input variables
    % model_id: selects the basis structure
    
    N = length(x);
    d = max(nx, nu);    
    M = N - d;        % number of regression samples  
    Phi = [];
    Y = zeros(M, 1);

    for i = 1:M
        % Get delayed values for x and u
        x_reg = x(i + (nx - 1):-1:i);
        u_reg = u_vec(i + (nu - 1):-1:i);

        % Create the regression vector
        phi_vec = [x_reg(:); u_reg(:)];

        % Integrate the base function to get the features
        phi_features = base_func(phi_vec, model_id);

        Phi = [Phi; phi_features'];
        Y(i) = x(i + d);   % target is the state at the next time step
    end
end
