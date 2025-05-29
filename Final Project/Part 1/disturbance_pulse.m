function omega = disturbance_pulse(t, T, duration, amplitude)
    % Τετραγωνικός παλμός: 1 για t ∈ [0,1), [2,3), [4,5), ...
    if mod(floor(t), 2) == 0
        omega = [100; 101];  % Ή [1; 0], [1; -1] ανάλογα τι θέλεις
    else
        omega = [0; 0];
    end
end