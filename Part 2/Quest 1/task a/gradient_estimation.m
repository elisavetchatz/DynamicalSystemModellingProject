function etsimations = gradient_estimation(t, var)

    global m_real b_real k_real G am u

    etsimations = zeros(8,1);
    
    x1 = var(1);
    x2 = var(2);
    phi1 = var(3);
    phi2 = var(4);
    phi3 = var(5);
    theta1_est = var(6);
    theta2_est = var(7);
    theta3_est = var(8);
    
    x1_dot = x2;
    x2_dot = (1/m_real) * (-b_real*x2 - k_real*x1 + u(t)); 
    
    phi1_dot = -am*phi1 + x1;
    phi2_dot = -am*phi2 + x2;
    phi3_dot = -am*phi3 + u(t);

    x2_hat = theta1_est*phi1 + theta2_est*phi2 + theta3_est*phi3;
    e = x2 - x2_hat;
    
    theta1_est_dot = G(1,1)*e*phi1;
    theta2_est_dot = G(2,2)*e*phi2;
    theta3_est_dot = G(3,3)*e*phi3;    
    
    etsimations(1) = x1_dot;
    etsimations(2) = x2_dot;
    etsimations(3) = phi1_dot;
    etsimations(4) = phi2_dot;
    etsimations(5) = phi3_dot;
    etsimations(6) = theta1_est_dot;
    etsimations(7) = theta2_est_dot;
    etsimations(8) = theta3_est_dot;
    
end   