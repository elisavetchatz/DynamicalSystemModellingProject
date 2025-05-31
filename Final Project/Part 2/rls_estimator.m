function [theta_hist, y_hat, error] = rls_estimator(x, u, y, model_id)
% Εκτίμηση παραμέτρων σε πραγματικό χρόνο με RLS
% Είσοδοι:
% - x: [N x 1] μετρήσεις εξόδου
% - u: [N x 1] μετρήσεις εισόδου
% - y: [N x 1] "στόχος" (π.χ. xdot)
% - model_id: ακέραιος 1 έως 5 για επιλογή μοντέλου

% Έξοδοι:
% - theta_hist: [n x N] ιστορικό παραμέτρων
% - y_hat: [N x 1] εκτιμώμενη έξοδος
% - error: [N x 1] σφάλμα εκτίμησης

N = length(x);              % πλήθος δειγμάτων
phi0 = base_func(x(1), u(1), model_id);  % αρχικό διάνυσμα βάσεων
n = length(phi0);           % μέγεθος διανύσματος βάσεων (δηλ. # παραμέτρων)

theta = zeros(n,1);         % αρχική τιμή παραμέτρων
P = 1000 * eye(n);          % αρχικό covariance matrix (μεγάλο για αβεβαιότητα)

theta_hist = zeros(n,N);    % για αποθήκευση ιστορικού θ
y_hat = zeros(N,1);         % προβλεπόμενες τιμές
error = zeros(N,1);         % σφάλματα

for k = 1:N
    phi = base_func(x(k), u(k), model_id);   % τρέχον διάνυσμα βάσεων
    y_k = y(k);                               % "παρατηρημένη" τιμή (π.χ. xdot)
    
    % RLS υπολογισμός
    K = (P * phi) / (1 + phi' * P * phi);
    theta = theta + K * (y_k - phi' * theta);
    P = P - (K * phi') * P;

    % Αποθήκευση
    theta_hist(:,k) = theta;
    y_hat(k) = phi' * theta;
    error(k) = y_k - y_hat(k);
end

end
