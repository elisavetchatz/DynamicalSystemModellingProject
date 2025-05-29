function omega = disturbance_pulse(t, T, duration, amplitude)

    % Αν το υπολοιπο του t ως προς Τ είναι μικρότερο από duration → ενεργός παλμός
    if mod(t, T) < duration
        omega = amplitude;
    else
        omega = [0; 0];
    end
end
