function [Phi, Y] = build_phi_vector(x, u_vec, xdot, nx, nu, model_id)
    % Initialize the output matrices
    N = length(x);
    M = N - max(nx, nu); % number of samples for regression
    Phi = []; % +1 for the constant term
    Y = zeros(M, 1);
    
    % Loop through each time step to build the phi vector
    for i = 1:M
        % Extract the state and control inputs for the current time step
        x_reg = x(i + (nx-1):-1:i);
        u_reg = u_vec(i + (nu-1):-1:i);
        
        % Build the phi vector
        phi_vec = [x_reg(:); u_reg(:)];
        
        % Generate features based on the model_id
        phi_features = base_func(phi_vec, model_id);
        
        Phi = [Phi; phi_features'];
        Y(i) = xdot(i + (nx-1));
    end
end