% --- Base Function Generator with Product Form ---
function phi = base_func(phi_vec, model_id, centers, spreads)
    % phi_vec: d x 1 regression vector (e.g. [x(t-1); x(t-2); u(t-1); ...])
    % centers: d x n matrix with centers (one column per basis function)
    % spreads: d x n matrix with spreads ("beta")
    % model_id: type of basis unit function
    % phi: n x 1 vector of basis function evaluations

    [d, n_bases] = size(centers);
    phi = zeros(n_bases, 1);

    for k = 1:n_bases
        g_k = 1;
        for i = 1:d
            mu = unit_function(phi_vec(i), centers(i, k), spreads(i, k), model_id);
            g_k = g_k * mu;
        end
        phi(k) = g_k;
    end
end


% --- Unit basis function per dimension ---
function mu = unit_function(xi, alpha, beta, model_id)
    switch model_id
        case 1  % Polynomial unit: (xi)^alpha (alpha = degree)
            mu = xi.^alpha;

        case 2  % Gaussian RBF
            mu = exp(-( (xi - alpha)^2 ) / (2 * beta^2));

        case 3  % Tanh
            mu = tanh(beta * (xi - alpha));

        case 4  % Rational
            mu = 1 / (1 + beta * (xi - alpha)^2);

        case 5  % Sinusoidal
            mu = sin(beta * (xi - alpha));

        otherwise
            error('Unsupported model_id');
    end
end
