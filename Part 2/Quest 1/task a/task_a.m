dt = 0.01; 
t_sim = 0:dt:20;

u_func = @(t) 2.5; 
%u_func = @(t) 2.5 * sin(t);

m = 1.315;
b = 0.225;
k = 0.725;

x0 = [0; 0];

system_fun = @(t, x) system_dynamics(t, x, m, k, b, u_func);

[t, X] = ode45(system_fun, t_sim, x0);

x1 = X(:, 1); 
x2 = X(:, 2); 
u = u_func(t_sim);

% disp(X);