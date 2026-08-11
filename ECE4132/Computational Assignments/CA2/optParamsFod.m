% script to optimize parameters of first-order model with delay (of the form given in
% equation 3 of the lab notes) to minimize mse between predicted and
% measured system responses.

% load input and output signals for TClab step response 
load Tsys.mat
load usys.mat

% set initial values of parameters
% uncomment these lines and replace ... with your code.
a2 = 0.0095;
K2 = 0.0052;
tau = 8.2362;
Troom2 = 22.5;
thetaFod0 = [a2; K2; tau; Troom2];

% set options for fminsearch to display progress of optimization method.
options = optimset('Display','iter');
% optimize parameters
% uncomment this line and replace ... with your code.
thetaFodopt = fminsearch(@(theta)fodCost(theta(1),theta(2),theta(3), theta(4),usys,Tsys),thetaFod0);
thetaFodopt


