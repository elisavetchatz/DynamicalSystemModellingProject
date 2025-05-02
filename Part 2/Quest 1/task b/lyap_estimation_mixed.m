function sys_out = lyap_estimation_mixed(t, var, mode)

    global m_real b_real k_real G Thetam u h
    
    sys_out = zeros(length(var),1);  % Δημιουργεί διάνυσμα 7x1
    
    % Διαβάζουμε τις πραγματικές καταστάσεις
    if mode == 0
        x1 = var(1);  
        x2 = var(2);  
    elseif mode == 1
        x1 = var(1) + h(t);
        x2 = var(2) + h(t);
    end
    
    % Εκτιμήσεις παραμέτρων
    theta1_est = var(3);
    theta2_est = var(4);
    theta3_est = var(5);
    
    % Εκτιμημένες καταστάσεις
    x1_est = var(6);
    x2_est = var(7);
    
    % Πραγματικό σύστημα
    x1_dot = x2;
    x2_dot = (1/m_real) * (-b_real * x2 - k_real * x1 + u(t));
    
    % Σφάλματα (και στα δύο states)
    e1 = x1 - x1_est;   % position error
    e2 = x2 - x2_est;   % velocity error
    
    % Κανόνες προσαρμογής
    theta1_dot = -G(1,1) * e2 * x1;  
    theta2_dot = -G(2,2) * e2 * x2;
    theta3_dot = G(3,3) * e2 * u(t);
    
    % Correction Term for x2_est dynamics
    correction_term =Thetam(2,2)*e2; % Thetam(1,1)*e1 + 
    
    % Μεικτή τοπολογία για εκτίμηση
    x1_est_dot = x2_est;
    x2_est_dot = -theta1_est*x1 - theta2_est*x2 + theta3_est*u(t) + correction_term;
    
    % Εξαγωγή παραγώγων
    sys_out(1) = x1_dot;
    sys_out(2) = x2_dot;
    sys_out(3) = theta1_dot;
    sys_out(4) = theta2_dot;
    sys_out(5) = theta3_dot;
    sys_out(6) = x1_est_dot;
    sys_out(7) = x2_est_dot;
    
end
    
    
    