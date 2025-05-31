function xdot = true_func(t, x, u)
    u = u(t);  
    xdot = -x^3 + tanh(x) + 1/(1 + x^2) + u;
end
