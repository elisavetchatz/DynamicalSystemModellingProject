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
        
        case 6 % Two Gaussian RBFs
            sigma = 1;
            c = [-1, 1]; 
            gaussians = exp(-(x - c).^2 / (2*sigma^2));
            phi = [gaussians'; u];

        case 7 %Enriched Light Model
            phi = [x; tanh(x); 1/(1+x^2); u];
        
        case 8 %Pure Nonlinear
            phi = [tanh(x); 1/(1+x^2); sin(x); u];
        
        case 9 %2nd Order Polynomial
            phi = [x; x^2; u];  

        case 10
            phi = [x; x^2; x^3; x^4; x^5; u];  
             
        otherwise
            error('Invalid model_id');
    end

end 