function omega = disturbance_pulse(t, T, amplitude)
    if mod(floor(t), T) == 0
        omega = [amplitude; amplitude];  
    else
        omega = [0; 0];
    end
end