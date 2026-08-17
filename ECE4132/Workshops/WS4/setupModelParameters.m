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

%% Simulink: Motor model selection
S = S_simple; % Simplified Motor Model
% S = S_motor; % Full Motor Model

%% Velocity control, P-controller, simple TF : Root locus
rlocus(S_simple);
% kp = linspace(0.1,1000,10001);
% rlocus(S_simple,kp);

%% Velocity control, P-controller, full TF : Root locus
rlocus(S_motor);
% kp = linspace(0.1,1000,10001);
% rlocus(S_motor,kp);

%% Position control, P-controller, simple TF : Root locus
rlocus(P_simple);
% kp = linspace(0.1,1000,10001);
% rlocus(P_simple,kp);

%% Position control, P-controller, full TF : Root locus
rlocus(P_motor);
% kp = linspace(0.1,1000,10001);
% rlocus(P_motor,kp);

%% Position control, PD-controller, simple TF : Root locus
% uncomment for fixed Kp and finding root locus of changing Kd in PD controller
kp = 1; % change for a new constant value
G_OLhat = tf( [P_simple.num{1} 0], P_simple.den{1}+kp*P_simple.num{1} );
rlocus(G_OLhat);
% kd = linspace(0.002,20,10001);
% rlocus(G_OLhat,kd);

% uncomment for fixed Kd and finding root locus of changing Kp in PD controller
% kd = 1; % change for a new constant value
% G_OLhat = tf( P_simple.num{1},[kd*P_simple.num{1} P_simple.den{1}] );
% rlocus(G_OLhat);
% kp = linspace(0.0002,0.2,1001);
% rlocus(G_OLhat,kp);

%% Position control, PD-controller, full TF : Root locus
% uncomment for fixed Kp and finding root locus of changing Kd in PD controller
kp = 1; % change for a new constant value
G_OLhat = tf( [P_motor.num{1} 0], P_motor.den{1}+kp*P_motor.num{1} );
rlocus(G_OLhat);
% kd = linspace(0.002,20,10001);
% rlocus(G_OLhat,kd);

% uncomment for fixed Kd and finding root locus of changing Kp in PD controller
% kd = 1; % change for a new constant value
% G_OLhat = tf( P_motor.num{1},[kd*P_motor.num{1} P_motor.den{1}] );
% rlocus(G_OLhat);
% kp = linspace(0.0002,0.2,1001);
% rlocus(G_OLhat,kp);