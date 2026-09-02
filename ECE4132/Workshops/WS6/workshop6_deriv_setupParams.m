% setup model parameters
clear;
close all;

% parameters for DC motor model (from
% http://ctms.engin.umich.edu/CTMS/index.php?example=MotorPosition&section=SystemModeling)
J = 3.2284E-6;
b = 3.5077E-6;
K = 0.0274;
R = 4;
L = 2.75E-6;
s = tf('s');
% transfer function with output angular velocity
S_motor = K/(((J*s+b)*(L*s+R)+K^2));
% transfer function with output angular position
P_motor = S_motor/s;

% transfer function simplified
S_simple = (K/R)/(J*s+b+(K^2)/R);
P_simple = S_simple/s;

%% CT PID controller - setup model parameters
kp = 1; ki = 0.1; kd = 0.2; 
% Tf = 1e-4;
Tf = 1e-2;
% uncomment and complete 
C = kp + ki/s + (kd*s)/(1+s*Tf);
% or tf(kp) + tf(ki, [1 0]) + tf([kd*s, 1+kd*S]) + tf([kd 0], [Tf 1]);
%% if line 27 is causing issues, don't run this section; instead, Run model in Simulink directly
out = sim('workshop6_DCmotor_deriv.slx'); % update file depending on version opened in Simulink
%%
figure(1);
plot(out.thetact.Time,out.thetact.Data);
xlabel('time (s)');
title('DC motor position');
figure(2);
plot(out.uct.Time,out.uct.Data)
xlabel('time (s)');
title('Output of PID controller');


