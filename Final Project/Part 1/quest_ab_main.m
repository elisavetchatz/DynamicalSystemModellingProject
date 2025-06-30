%% THEMA 1
% Quest A and B Estimator
questb = false;

% Time parameters
Tsim = 20;
Tsampl = 0.001;
N = Tsim/Tsampl;
tvec  = 0:Tsampl:Tsim;

% System parameters
A = [-2.15 0.25; -0.75 -2];
B = [0; 1.5];

% Chosen Input 
u = @(t) sin(t) + 0.5*cos(3*t); 

% Initial conditions
x0 = [0; 0];  

%% Design Estimator
%%Quest A parameters
G = [240, 40, 108, 25, 1, 3.5]; 
Thetam = diag([10, 15]);

%%Quest B parameters 
Gb = [40, 30, 85, 32, 0.5, 12.5];
Thetamb = diag([40, 25]);
S = [0.001; 0.05; 0.01; 0.005; 0; -0.01];
%generate omega pulse
T_pulse = 2;
amplitude = 0.1; 
omega = @(t) disturbance_pulse(t, T_pulse, amplitude);

%%initial conditions for the state and parameters
z0 = zeros(10, 1);
z0(1) = x0(1);      % x1 initial condition
z0(2) = x0(2);      % x2 initial condition
z0(5) = -2;         % a11 in [-3, -1]
z0(10) = 2;         % b2 geq 1

%% Run the ODE solver
[t, z] = ode45(@(t, z) mtopo_proj_estimator(t, z, u, A, B, G, Gb, Thetam, Thetamb, S, omega, questb), tvec, z0);

x1 = z(:,1);  
x2 = z(:,2);
xhat1 = z(:,3);  
xhat2 = z(:,4);
a11 = z(:,5); 
a12 = z(:,6);
a21 = z(:,7); 
a22 = z(:,8);
b1 = z(:,9);  
b2 = z(:,10);

e1 = x1 - xhat1;
e2 = x2 - xhat2;

ea11 = a11 - A(1,1);
ea12 = a12 - A(1,2);
ea21 = a21 - A(2,1);
ea22 = a22 - A(2, 2);

eb1 = b1 - B(1);
eb2 = b2 - B(2);

%% Create plots
% State plots
figure;
subplot(2,1,1);
plot(t, x1, 'b', t, xhat1, 'r--', "LineWidth", 1.2);
legend('x_1','{x_1}^{hat}'); ylabel('x_1'); title('State 1');
grid on;
subplot(2,1,2);
plot(t, x2, 'b', t, xhat2, 'r--', "LineWidth", 1.2);
legend('x_2','{x_2}^{hat}'); ylabel('x_2'); xlabel('t [s]'); title('State 2');
grid on;

% Error plots
figure;
plot(t, e1, t, e2, "LineWidth", 1.2);
legend('e_{x1}','e_{x2}');
title('State Error'); xlabel('t [s]');
grid on;

% A estimates
figure;
plot(t, a11, 'r', t, a12, 'g', t, a21, 'b', t, a22, 'm', "Linewidth", 1.2); hold on;
yline(-2.15, '--r');
yline(0.25, '--g');
yline(-0.75, '--b');
yline(-2.00, '--m');
legend('a_{11}','a_{12}','a_{21}','a_{22}', 'Location', 'best');
title('Estimation A vs Real Values');
xlabel('t [s]'); grid on;

% B estimates
figure;
plot(t, b1, 'b', t, b2, 'r', "Linewidth", 1.2); hold on;
yline(0, '--b', 'b_{1}^{true}');
yline(1.5, '--r', 'b_{2}^{true}');
legend('b_{1}', 'b_{2}', 'Location', 'best');
title('Estimation B vs Real Values');
xlabel('t [s]'); grid on;

% Estimation errors
figure;
plot(t, ea11, 'r', t, ea12, 'g', t, ea21, 'b', t, ea22, 'm', "Linewidth", 1.2); hold on;
legend('e_{a11}', 'e_{a12}', 'e_{a21}', 'e_{a22}', 'Location', 'best');
title('Estimation Errors: parameter A');
xlabel('t [s]'); ylabel('Σφάλμα'); grid on;
figure;
plot(t, eb1, 'b', t, eb2, 'r', "Linewidth", 1.2); hold on;
legend('e_{b1}', 'e_{b2}', 'Location', 'best');
title('Estimation Errors: parameter B');
xlabel('t [s]'); ylabel('Σφάλμα'); grid on;

% Plot disturbance pulse
if questb
    omega_vals = zeros(2, length(tvec));

    for k = 1:length(tvec)
        omega_vals(:,k) = disturbance_pulse(tvec(k), T_pulse, amplitude);
    end
    figure;
    subplot(2,1,1)
    plot(tvec, omega_vals(1,:), 'r', 'LineWidth', 1.5);
    title('Disturbance \omega_1(t)');
    xlabel('t [s]');
    ylabel('\omega_1');
    grid on;

    subplot(2,1,2)
    plot(tvec, omega_vals(2,:), 'b', 'LineWidth', 1.5);
    title('Disturbance \omega_2(t)');
    xlabel('t [s]');
    ylabel('\omega_2');
    grid on;
end

%% how does disturbance affect estimation errors
amplitudes = linspace(0, 1, 10); 
state_errors = zeros(size(amplitudes));
param_errors = zeros(size(amplitudes));

for i = 1:length(amplitudes)
    amplitude = amplitudes(i);
    omega = @(t) disturbance_pulse(t, T_pulse, amplitude); 

    z0 = zeros(10, 1);
    z0(1) = x0(1); 
    z0(2) = x0(2);
    z0(5) = -2;    
    z0(10) = 2;

    [t, z] = ode45(@(t, z) mtopo_proj_estimator(t, z, u, A, B, G, Gb, Thetam, Thetamb, S, omega, questb), tvec, z0);

    x1 = z(:,1); 
    x2 = z(:,2);
    xhat1 = z(:,3); 
    xhat2 = z(:,4);

    % Absolute error in state estimation
    e1 = abs(x1 - xhat1);
    e2 = abs(x2 - xhat2);
    mae_state = mean(e1 + e2);  % Mean Absolute Error (MAE)
    state_errors(i) = mae_state;

    % Absolute error in parameter estimation
    a11 = z(:,5);  
    a12 = z(:,6);
    a21 = z(:,7);  
    a22 = z(:,8);
    b1  = z(:,9);  
    b2  = z(:,10);

    ea11 = abs(a11 - A(1,1)); 
    ea12 = abs(a12 - A(1,2));
    ea21 = abs(a21 - A(2,1));
    ea22 = abs(a22 - A(2,2));
    eb1  = abs(b1  - B(1));   
    eb2  = abs(b2  - B(2));

    mae_param = mean(ea11 + ea12 + ea21 + ea22 + eb1 + eb2);
    param_errors(i) = mae_param;
end

% Plotting the effect of disturbance amplitude on estimation errors
figure;
plot(amplitudes, state_errors, '-o', 'LineWidth', 1.5);
hold on;
plot(amplitudes, param_errors, '-s', 'LineWidth', 1.5);
xlabel('Omega Amplitude');
ylabel('Mean Absolute Error');
title('Effect of Disturbance Amplitude on Estimation Errors');
legend({'States', 'Parameters'}, 'Location', 'northwest');
grid on;

%% 
amplitudes = linspace(0, 1, 10); 
n = length(amplitudes);

% Initialize error storage
e_x1 = zeros(1, n);
e_x2 = zeros(1, n);
e_a11 = zeros(1, n);
e_a12 = zeros(1, n);
e_a21 = zeros(1, n);
e_a22 = zeros(1, n);
e_b1  = zeros(1, n);
e_b2  = zeros(1, n);

for i = 1:n
    amplitude = amplitudes(i);
    omega = @(t) disturbance_pulse(t, T_pulse, amplitude); 

    % Initial conditions
    z0 = zeros(10, 1);
    z0(1) = x0(1); 
    z0(2) = x0(2);
    z0(5) = -2;    
    z0(10) = 2;

    % Run simulation
    [t, z] = ode45(@(t, z) mtopo_proj_estimator(t, z, u, A, B, G, Gb, Thetam, Thetamb, S, omega, questb), tvec, z0);

    % Extract true and estimated states
    x1 = z(:,1); x2 = z(:,2);
    xhat1 = z(:,3); xhat2 = z(:,4);
    e_x1(i) = mean(abs(x1 - xhat1));
    e_x2(i) = mean(abs(x2 - xhat2));

    % Extract estimated parameters
    a11 = z(:,5); a12 = z(:,6);
    a21 = z(:,7); a22 = z(:,8);
    b1  = z(:,9); b2  = z(:,10);

    % Compute mean absolute errors
    e_a11(i) = mean(abs(a11 - A(1,1)));
    e_a12(i) = mean(abs(a12 - A(1,2)));
    e_a21(i) = mean(abs(a21 - A(2,1)));
    e_a22(i) = mean(abs(a22 - A(2,2)));
    e_b1(i)  = mean(abs(b1 - B(1)));
    e_b2(i)  = mean(abs(b2 - B(2)));
end

% Plotting
figure;
% state estimation errors
subplot(2,1,1);
plot(amplitudes, e_x1, '-o', 'DisplayName', 'x_1 error', 'LineWidth', 1.2); hold on;
plot(amplitudes, e_x2, '-o', 'DisplayName', 'x_2 error', 'LineWidth', 1.2);
title('Estimation Error of States vs Disturbance Amplitude');
xlabel('Omega Amplitude');
ylabel('Mean Absolute Error');
legend('Location', 'northwest');
grid on;
% parameter estimation errors
subplot(2,1,2);
plot(amplitudes, e_a11, '-sr', 'DisplayName', 'a_{11}', 'LineWidth', 1.2); hold on;
plot(amplitudes, e_a12, '-sg', 'DisplayName', 'a_{12}', 'LineWidth', 1.2);
plot(amplitudes, e_a21, '-sb', 'DisplayName', 'a_{21}', 'LineWidth', 1.2);
plot(amplitudes, e_a22, '-sm', 'DisplayName', 'a_{22}', 'LineWidth', 1.2);
plot(amplitudes, e_b1,  '-sb', 'DisplayName', 'b_1',  'LineWidth', 1.2);
plot(amplitudes, e_b2,  '-sr', 'DisplayName', 'b_2',  'LineWidth', 1.2);
title('Estimation Error of Parameters vs Disturbance Amplitude');
xlabel('Omega Amplitude');
ylabel('Mean Absolute Error');
legend('Location', 'northwest');
grid on;
