function mse = fodCost(a2,K2,tau,Troom2,usys,Tsys)
% function that 
% 1. simulates the response of a first order system with delay (described by equation 3 of the lab notes)
% with parameters a2, K2, tau, and Troom2, when the input is the timeseries object usys
%
% 2. computes the mean-squared error between the simulated response of the first-order-delay system
% and the saved response Tsys (a timeseries object) of the TClab system to input usys (a timeseries object).
% 
% Inputs:
% a2 (scalar)
% K2 (scalar)
% tau (scalar)
% Troom2 (scalar)
% usys (timeseries object)
% Tsys (timeseries object)
%
% Outputs:
% mse (scalar)
% 
% Implement this function using the guide given below:

% use the MATLAB function "tf" to create a MATLAB object representing the transfer 
% function you found in prelab question three. Read the MATLAB documentation
% for "tf" to find out how to do this, particularly how to include a delay!

% uncomment and replace the ... with your code.
sysfod = tf(K2, [1, a2], "InputDelay", tau);

% Simulate the first order with delay differential equation for the temperature deviations D 
% (equation 3 in the lab notes) using the MATLAB function "lsim" and the input usys.
Dfod = lsim(sysfod,usys.data,usys.time);

% Convert temperature deviations predicted by the first-order model to
% temperatures:

% uncomment and replace the ... with your code.
Tfod = Dfod + Troom2;

% compute the mean-squared error between Tsys.data and Tfod.

% uncomment and replace the ... with your code.
N = length(Tfod);
mse = 1/N * sum((Tsys.data - Tfod).^2);



