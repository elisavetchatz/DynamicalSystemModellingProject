function [Phi, Y] = build_phi_vector(x, u_vec, nx, nu, model_id)
    % Δημιουργεί τον πίνακα Phi και το διάνυσμα στόχων Y
    % για μοντέλο τύπου x(t + d) = f(x(t), ..., u(t), ...)
    
    N = length(x);
    d = max(nx, nu);     % καθυστέρηση πρόβλεψης
    M = N - d;           % αριθμός διαθέσιμων στιγμών
    Phi = [];
    Y = zeros(M, 1);

    for i = 1:M
        % Λήψη καθυστερημένων τιμών για x και u
        x_reg = x(i + (nx - 1):-1:i);
        u_reg = u_vec(i + (nu - 1):-1:i);

        % Δημιουργία διανύσματος παλινδρόμησης
        phi_vec = [x_reg(:); u_reg(:)];

        % Εφαρμογή βάσεων
        phi_features = base_func(phi_vec, model_id);

        % Αποθήκευση
        Phi = [Phi; phi_features'];
        Y(i) = x(i + d);   % επόμενη τιμή εξόδου (στόχος)
    end
end
