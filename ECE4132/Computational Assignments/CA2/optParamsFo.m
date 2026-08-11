% script to optimize parameters of first-order model (of the form given in
% equation 2 of the lab notes) to minimize mse between predicted and
% measured system responses.

% load input and output signals for TClab step response 
load Tsys.mat
load usys.mat

% set initial values of parameters
% uncomment these lines and replace ... with your code.
a1 = 0.0047;
K1 = 0.0086;
Troom1 = 22.5;
thetaFo0 = [a1; K1; Troom1];

% set options for fminsearch to display progress of optimization method.
options = optimset('Display','iter');
% optimize parameters
thetaFoopt = fminsearch(@(theta)foCost(theta(1),theta(2),theta(3),usys,Tsys),thetaFo0,options);

thetaFoopt

