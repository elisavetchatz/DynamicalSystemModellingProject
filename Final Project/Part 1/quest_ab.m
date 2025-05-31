%% THEMA 1
questb = true;
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
%Quest A parameters
G = [240, 40, 108, 25, 1, 3.5]; % everything fine tuned
Thetam = diag([10, 15]);

% Quest B parameters 
Gb = [1, 35, 20, 18, 0.5, 50];
S = [-0.001; 0.05; 0.01; -0.005; 0; -0.01];
%%generate omega pulse
T_pulse = 2;
amplitude = 0.01; % Disturbance amplitude
omega = @(t) disturbance_pulse(t, T_pulse, amplitude);

%%initial conditions for the state and parameters
z0 = zeros(10, 1);
z0(1) = x0(1);      % x1 initial condition
z0(2) = x0(2);      % x2 initial condition
z0(5) = -2;         % a11 in [-3, -1]
z0(10) = 2;         % b2 ≥ 1

%% Run the ODE solver
[t, z] = ode45(@(t, z) mtopo_proj_estimator(t, z, u, A, B, G, Gb, Thetam, S, omega, questb), tvec, z0);

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