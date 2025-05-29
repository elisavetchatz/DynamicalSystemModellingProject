%% THEMA 1

% Time parameters
Tsim = 50;
Tsampl = 0.01;
N = Tsim/Tsampl;
tvec  = 0:Tsampl:Tsim;

% System parameters
A = [-2.15 0.25; -0.75 -2];
B = [0; 1.5];

% Chosen Input 
u = @(t) sin(t) + 0.5*cos(3*t);

% Initial conditions
x0 = [0; 0];  % Initial state

%% Design Estimator
G = [74, 28, 38, 23, 1, 4]; % a22 check, a12 almost perfect, a11 needs a little mof=dification, a21 αρκετα μακρια
Thetam = diag([10, 15]);
z0 = zeros(10, 1);
z0(1) = x0(1);  % x1 initial condition
z0(2) = x0(2); % x2 initial condition
z0(5) = -2;  % a11 in [-3, -1]
z0(10) = 2; % b2 ≥ 1

[t, z] = ode45(@(t, z) mtopo_proj_estimator(t, z, u, A, B, G, Thetam), tvec, z0);

x1 = z(:,1);  x2 = z(:,2);
xhat1 = z(:,3);  xhat2 = z(:,4);
a11 = z(:,5); a12 = z(:,6);
a21 = z(:,7); a22 = z(:,8);
b1 = z(:,9);  b2 = z(:,10);

e1 = x1 - xhat1;
e2 = x2 - xhat2;

%% plotting
figure;
subplot(2,1,1);
plot(t, x1, 'b', t, xhat1, 'r--');
legend('x_1','\hat{x}_1'); ylabel('x_1'); title('Κατάσταση 1');
grid on;

subplot(2,1,2);
plot(t, x2, 'b', t, xhat2, 'r--');
legend('x_2','\hat{x}_2'); ylabel('x_2'); xlabel('t [s]'); title('Κατάσταση 2');
grid on;

% Σφάλματα
figure;
plot(t, e1, t, e2);
legend('e_1','e_2');
title('Σφάλμα Κατάστασης'); xlabel('t [s]');
grid on;

% Εκτιμήσεις A
figure;
plot(t, a11, 'r', t, a12, 'g', t, a21, 'b', t, a22, 'm'); hold on;
yline(-2.15, '--r');
yline(0.25, '--g');
yline(-0.75, '--b');
yline(-2.00, '--m');
legend('a_{11}','a_{12}','a_{21}','a_{22}', 'Location', 'best');
title('Εκτιμήσεις A vs Πραγματικές Τιμές');
xlabel('t [s]'); grid on;

% Εκτιμήσεις B
figure;
plot(t, b1, 'b', t, b2, 'r'); hold on;
yline(0, '--b', 'b_{1}^{true}');
yline(1.5, '--r', 'b_{2}^{true}');
legend('b_{1}', 'b_{2}', 'Location', 'best');
title('Εκτιμήσεις B vs Πραγματικές Τιμές');
xlabel('t [s]'); grid on;

ea11 = a11 - A(1,1);
ea12 = a12 - A(1,2);
ea21 = a21 - A(2,1);
ea22 = a22 - A(2, 2);

eb1 = b1 - B(1);
eb2 = b2 - B(2);

figure;
plot(t, ea11, 'r', t, ea12, 'g', t, ea21, 'b', t, ea22, 'm');
legend('e_{a11}', 'e_{a12}', 'e_{a21}', 'e_{a22}', 'Location', 'best');
title('Σφάλματα Εκτίμησης Παραμέτρων A');
xlabel('t [s]'); ylabel('Σφάλμα'); grid on;

figure;
plot(t, eb1, 'b', t, eb2, 'r');
legend('e_{b1}', 'e_{b2}', 'Location', 'best');
title('Σφάλματα Εκτίμησης Παραμέτρων B');
xlabel('t [s]'); ylabel('Σφάλμα'); grid on;

