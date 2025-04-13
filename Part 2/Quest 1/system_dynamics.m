function dx = system_dynamics(t, x)

    % Καταστάσεις:
    % x(1) = x (θέση)
    % x(2) = dx (ταχύτητα)
    % x(3) = phi1 = dx (ταχύτητα)
    % x(4) = phi2 = x (θέση)
    % x(5) = phi3 = u(t)
    % x(6:8) = εκτιμήσεις θ1, θ2, θ3

    % Είσοδος
    function u = input_u(t)
        % Επέλεξε:
        % u = 2.5;                 % για i)
        u = 2.5 * sin(t);          % για ii)
    end
    
    % Γνωστές σταθερές
    % Removed global gamma; gamma is now passed as a function argument.
    gamma = 100; % Συντελεστής εκτίμησης
    am = 5;    % Συντελεστής φιλτραρίσματος
    
    % Διαχωρισμός μεταβλητών
    x1 = x(1);      % x(t)
    x2 = x(2);      % dx(t)
    phi1 = x(3);    % dx(t)
    phi2 = x(4);    % x(t)
    phi3 = x(5);    % u(t)
    th1_hat = x(6);
    th2_hat = x(7);
    th3_hat = x(8);
    
    % Είσοδος
    u = input_u(t);
    
    % Υπολογισμός εκτιμώμενης εξόδου
    x_hat = th1_hat * phi1 + th2_hat * phi2 + th3_hat * phi3;
    x_true = x1;
    e = x_true - x_hat;
    
    % Σύστημα δεύτερης τάξης
    dx1 = x2;                               % dx
    dx2 = -0.225/1.315*x2 - 0.725/1.315*x1 + 1/1.315*u;  % d2x
    
    % Φίλτρα κατάστασης (εδώ απλά αντιγράφουμε για το gradient estimator)
    dx3 = -am * phi1 + x2;   % φιλτράρισμα dx
    dx4 = -am * phi2 + x1;   % φιλτράρισμα x
    dx5 = -am * phi3 + u;    % φιλτράρισμα u
    
    % Ενημέρωση gradient εκτιμητών
    dth1 = gamma * e * phi1;
    dth2 = gamma * e * phi2;
    dth3 = gamma * e * phi3;
    
    % Ομαδοποίηση παραγώγων
    dx = [dx1; dx2; dx3; dx4; dx5; dth1; dth2; dth3];
    end
    