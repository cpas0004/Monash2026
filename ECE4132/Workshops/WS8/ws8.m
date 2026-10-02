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

% Setup: Control via state feedback
% Earlier today, we chose the closed-loop eigenvalues
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