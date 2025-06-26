function phi = base_func(phi_vec, model_id)
    % General nonlinear basis function generator
    % phi_vec: regression vector [x(t), x(t-1), ..., u(t), ...]
    % model_id: selects the basis structure

    switch model_id

        case 1 % 2nd order polynomial
            phi = [phi_vec; phi_vec.^2];  
        
        case 2 % 3rd order polynomial
            phi = [phi_vec; phi_vec.^2; phi_vec.^3];
        
        case 3 % 4th order polynomial
            phi = [phi_vec; phi_vec.^2; phi_vec.^3; phi_vec.^4];

        case 4 % 5th order polynomial
            phi = [phi_vec; phi_vec.^2; phi_vec.^3; phi_vec.^4; phi_vec.^5];

        case 5 % Gaussian RBFs (centered at -2, 0, 2)
            phi = [phi_vec; make_rbfs(phi_vec, -2:2, 1)];
            % sigma = 1;
            % c = [-2, 0, 2];
            % gaussians = exp(-(x1 - c).^2 / (2*sigma^2));
            % phi = [gaussians'; phi_vec];
        
        case 6 % Gaussian RBFs (centered at -1, 0, 1)
            phi = [phi_vec; make_rbfs(phi_vec, -1:0.5:1, 0.5)];
            % sigma = 0.5;
            % c = [-1, 0, 1]; 
            % gaussians = exp(-(x1 - c).^2 / (2*sigma^2));
            % phi = [gaussians'; phi_vec];

        case 7 % sinusoidal model
            phi = [sin(phi_vec); cos(phi_vec); phi_vec];

        case 8 % exponential model
            phi = [exp(phi_vec); exp(-phi_vec); phi_vec];

        otherwise
            error('Invalid model_id');

    end
end
