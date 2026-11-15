% script to set model parameters
% Whenever you make changes in this file, rerun it *before* running your
% Simulink simulations.
clear;
close all;
clc;

% system parameters
    g = 9.8; %m/s^2
    m = 0.2; % kg
    M = 0.5; % kg
    l = 0.3; % m
    J = 0.006; % (moment of inertia)
    gamma = 0.005; % coefficient of friction for pendulum
    c = 0.1; % coefficient of friction for cart
    
    
% define matrices of the linearized system here:
A = inv([1 0 0 0; 0 1 0 0; 0 0 M+m m*l; 0 0 m*l J+m*l^2])*[0 0 1 0; 0 0 0 1; 0 0 -c 0; 0 -m*g*l 0 -gamma];
B = inv([1 0 0 0; 0 1 0 0; 0 0 M+m m*l; 0 0 m*l J+m*l^2])*[0; 0; 1; 0];
C = [1 0 0 0];
D = 0;

% define system initial condition here 
% states = [postion; angle; velocity; angular velocity];
xinit = [0;0;0;0]; 

% compute observability matrix and check for observability of linearised
% system (for prelab)
obsMatrix = obsv(A, C);
obsDet = det(obsMatrix);

fprintf('Observability matrix determinant is: %.4f\n', obsDet);
fprintf('So yes, it is observable.\n');

% If we wanted to measure the angular pos instead of the linear pos, we
% need to change C to change the output to be the angular pos
C_ang = [0 1 0 0];
angObsMatrix = obsv(A, C_ang);
angObsDet = det(angObsMatrix);

fprintf('New observability matrix determinant is: %.4f\n', angObsDet);

% set desired eigenvalues for estimator system and find estimator gains
% We learnt how to use place to find K, but we want to find L (can still
% use place by transposing)
eigvals = [-8-0.5*i -8+0.5*i -12-0.5*i -12+0.5*i];
L = place(A', C', eigvals)';

% Verify the eigenvalues
eig(A - L*C)

%% Setting up for Q3
Ahat = A-L*C;
Bhat = [B L];
% Chat is identity because we want the output of the observer to be the
% full state (there are 4 internally)
Chat = eye(4);
% Dhat is 4x2 because the u is 2x1
Dhat = zeros(4, 2);

%% 3i

xhatinit = [0 0 0 0]';
xinit = [0 1 0 0]';

%%
plot(out1.Time, out1.Data(:, 1), out1.Time, out1.Data(:, 2), out1.Time, out1.Data(:, 3), out1.Time, out1.Data(:, 4));
legend('Linear Position', 'Angular Position', 'Linear Velocity', 'Angular Velocity');

%% 3ii

xhatinit = [0 0 0 0]';
xinit = [0 -1 0 0]';

%%
plot(out1.Time, out1.Data(:, 1), out1.Time, out1.Data(:, 2), out1.Time, out1.Data(:, 3), out1.Time, out1.Data(:, 4));
legend('Linear Position', 'Angular Position', 'Linear Velocity', 'Angular Velocity');


%% Section 3

%% 4i
xinit = [0 1 0 0]';

%%
plot(out2.Time, out2.Data(:, 1), out2.Time, out2.Data(:, 2), out2.Time, out2.Data(:, 3), out2.Time, out2.Data(:, 4));
legend('Linear Position', 'Angular Position', 'Linear Velocity', 'Angular Velocity');

%% 4ii
xinit = [0 -1 0 0]';

%%
plot(out2.Time, out2.Data(:, 1), out2.Time, out2.Data(:, 2), out2.Time, out2.Data(:, 3), out2.Time, out2.Data(:, 4));
legend('Linear Position', 'Angular Position', 'Linear Velocity', 'Angular Velocity');

%% Section 4

eigvals = [-4-0.5*i -4+0.5*i -5 -6];
K = place(A, B, eigvals);

kr = -inv(C*inv(A-B*K)*B);

%% Q6
xinit = [0 0.2 0 0.2]';

%%
plot(out3.Time, out3.Data(:, 1));
xlabel('Time (s)');
ylabel('Position (m)');

%% Section 5

%% Q7
xinit = [0 0.2 0 0.2]';

%%

plot(out4.Time, out4.Data(:, 1));
xlabel('Time (s)');
ylabel('Position (m)');