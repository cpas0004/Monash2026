clear all;
close all;

t = 0:0.1:10;

% Our plant (electrically heated oven)
A = [-2 2; 1 -1];
B = [1; 0];
C = [0 1];
D = 0;
plant = ss(A,B,C,D);

% Initial conditions
T0 = 300; % in Kelvin
x10 = 0 ; x20 = 0;
ICs = [x10+T0; x20+T0]; % initial conditions for T1 and T2

%% Simulate open-loop plant with a fixed control input of 2 watts
% (recap from Week 7)
u_const = 2;
u = u_const*ones(size(t));
[y_ol,tOut1,x_ol] = lsim(plant,u,t,ICs); % computes the simulated time response
figure
plot(tOut1,y_ol);
title('Oven with Constant Input of 2 W (Open Loop)');
ylabel('Temperature of Oven Interior (K)');
xlabel('Time');

% Reference input
r_const = 453; % in Kelvin; i.e., approx. 180 degree Celsius

%% Setup: Control via state feedback
% In Week 8, we chose the closed-loop eigenvalues
eigvals = [-1 -3];
% We can use these closed-loop eigenvalues to get state feedback gains K
K = place(A,B,eigvals)
% We can then derive the reference gain kr
kr = 1/(-C/(A-B*K)*B)

%% Simulate closed-loop system with state feedback control
r = r_const.*ones(size(t));
sys_stfb = ss(A-B*K,B*kr,C-D*K,D*kr);
[y_stfb,tOut2,x_stfb] = lsim(sys_stfb,r,t,ICs);
figure
plot(tOut2,y_stfb);
title('Oven with State Feedback Control (Ideal)');
ylabel('Temperature of Oven Interior (K)');
xlabel('Time');

%% Setup: Control via output feedback
% We choose estimator eigenvalues
esteigvals = [-5 -10];
% Then use these to get estimator output error gains L
L = place(A', C', esteigvals)' %%%%% 1. FILL IN THE MISSING INFORMATION IN THIS LINE

%% Simulate closed-loop plant-estimator system (output feedback controller)
% Full state-space model of the plant-estimator closed-loop system with
% the state vector used being the plant states and estimated plant states (xhat)
At = [A -B*K; L*C A-B*K-L*C]; %%%%% 2. COMPLETE THESE LINES
Bt = [B*kr; B*kr]; %%%%% 2. COMPLETE THESE LINES
Ct = [C zeros(size(C))]; %%%%% 2. COMPLETE THESE LINES
Dt = [0]; %%%%% 2. COMPLETE THESE LINES
r = r_const.*ones(size(t));
sys_opfb = ss(At,Bt,Ct,Dt);
x0est = ones(size(ICs))*T0; % assume estimator initial states are T0
x0t = [ICs; x0est]; % assume estimator starts with T0 initial states
[y_opfb,tOut3,x_opfb] = lsim(sys_opfb,r,t,x0t); % returns state trajectory x_opfb, a matrix with length(tOut3) rows and as many columns as states
figure
plot(tOut3,y_opfb);
title('Oven with Output Feedback Control (Practical)');
ylabel('Temperature of Oven Interior (K)');
xlabel('Time');
% Display all of the internal states of the closed-loop plant and state estimator
figure
plot(tOut3,x_opfb(:,1),'k', tOut3,x_opfb(:,2),'b', tOut3,x_opfb(:,3),'r--', tOut3,x_opfb(:,4),'y--'); % plot the state trajectories
title('Internal States of Oven');
ylabel('Internal States');
xlabel('Time');
legend('x1','x2','xhat1','xhat2');