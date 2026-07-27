function mse = foCost(a1,K1,Troom1,usys,Tsys)
% function that 
% 1. simulates the response of a first order system (described by equation 2 of the lab notes)
% with parameters a1, K1, tau, and Troom2, when the input is the timeseries object usys
%
% 2. computes the mean-squared error between the simulated response of the first-order system
% and the saved response Tsys (a timeseries object) of the TClab system to input usys (a timeseries object).
%
% Inputs:
% a1 (scalar)
% K1 (scalar)
% Troom1 (scalar)
% usys (timeseries object)
% Tsys (timeseries object)
%
% Outputs:
% mse (scalar)
% 
% Implement this function using the guide given below:

% use the MATLAB function "tf" to create a MATLAB object representing the transfer 
% function you found in prelab question one. Read the MATLAB documentation
% for "tf" to find out how to do this!

% uncomment and replace the ... with your code.
% sysfo = tf(...);

% Simulate the first order differential equation for the temperature deviations D 
% (equation 2 in the lab notes) using the MATLAB function "lsim" and the input usys.
Dfo = lsim(sysfo,usys.data,usys.time);

% Convert temperature deviations predicted by the first-order model to
% temperatures:

% uncomment and replace the ... with your code.
% Tfo = ...;

% compute the mean-squared error between Tsys.data and Tfo.

% uncomment and replace the ... with your code.
% mse = ...;

