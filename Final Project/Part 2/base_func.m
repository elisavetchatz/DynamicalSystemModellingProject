function phi = base_func(x, u, model_id)

    switch model_id

        case 1 % Polynomial
            phi = [x; x^2; x^3; u];

        case 2 % Gaussian RBF
            sigma = 1;
            c = [-2, 0, 2];
            gaussians = exp(-(x - c).^2 / (2*sigma^2));
            phi = [gaussians'; u];

        case 3 % Lightweight
            phi = [x; tanh(x); u];

        case 4 % Hybrid: Polynomial + tanh
            phi = [x; x^2; tanh(x); u];

        case 5  % Sigmoid-based
            phi = [1 / (1 + exp(-x)); x / (1 + x^2); u];
            
        otherwise
            error('Invalid model_id');
    end

end 