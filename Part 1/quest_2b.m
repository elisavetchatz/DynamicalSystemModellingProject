
% % ========================
% % Estimation with only q(t) and u(t)
% % ========================
% Phi2 = [q_samples(2:end-1)' q_samples(1:end-2)' u_samples(2:end-1)'];
% y2 = q_samples(3:end)';

% theta2 = (Phi2' * Phi2) \ (Phi2' * y2);

% fprintf('\nEstimation with only q(t) and u(t):\n');
% fprintf('L_est2 = %.4f m\n', g/theta2(1));


