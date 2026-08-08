% setup DC motor model 
clear;
close all;

% parameters for DC motor model (from
% http://ctms.engin.umich.edu/CTMS/index.php?example=MotorPosition&section=SystemModeling)
J = 3.22E-6;
D = 3.50E-6;
K = 0.027;
R = 4;
L = 2.75E-6;

% transfer functions for subsystems
Gelec = tf(1, [L, R]);
Gmech = tf(1, [J, D]);
A = K * Gelec * Gmech;
B = K;
integrator = tf(1, [1, 0]);

% transfer functions for overall system
Gvomega = feedback(A, B);
Gvtheta = Gvomega * integrator;

%% Simulating in MATLAB environment 
% step responses (in new figures since otherwise these overwrite the active figure)
figure(1);
step(Gvtheta);
figure(2);
step(Gvomega);


% step response parameters
[y, t] = step(Gvomega);
stepinfo(y, t)

% simulation of the system (in a new figure)
t = 0:0.001:0.5;
u = sign(sin((10*pi*t)));
figure(3);
lsim(Gvomega, u, t);
                                 
                                 
                                 
%% Modelling subsystems of DC motor (analytical and data-driven approaches)
% simplified transfer function GvomegaSimplified (uncomment and complete)
GvomegaSimplified = feedback((1/R)*K*Gmech, K); 

% compute step responses of both models (uncomment and complete)
[ystep,ts] = step(Gvomega);
ystepSimplified = step(GvomegaSimplified, ts);

% plot difference between model step responses on the same set of axes
figure(1);
% add plotting code here
plot(ts, ystep-ystepSimplified)

% generate noisy step response data
stddev = 0.5;
ystepNoisy = ystep + stddev*randn(size(ystep));

% plot noisy step response data
figure(2);
% add plotting code here
plot(ts, ystepNoisy);


% function handle for least squares cost (uncomment and complete)
cost = @(theta) sum((ystepNoisy - step( tf(theta(2), [theta(1), 1]), ts )).^2);

% initial guess (uncomment and complete)
theta0 = [0.1, 0.1];


% optimize parameters (uncomment and complete)
thetaOpt = fminsearch(cost, theta0)


% compute step response with optimal parameters (uncomment and complete)
ystepOpt = step( tf(thetaOpt(2), [thetaOpt(1), 1]), ts);


% plot ystepOpt on same set of axes as noisy step response
figure(3);
% add plotting code here
plot(ts, ystepNoisy, ts, ystepOpt);


