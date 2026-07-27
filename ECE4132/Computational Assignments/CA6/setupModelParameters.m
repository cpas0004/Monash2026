% script to set model parameters
% Whenever you make changes in this file, rerun it *before* running your
% Simulink simulations.
clear;
close all;

% system parameters
    g = 9.8; %m/s^2
    m = 0.2; % kg
    M = 0.5; % kg
    l = 0.3; % m
    J = 0.006; % (moment of inertia)
    gamma = 0.005; % coefficient of friction for pendulum
    c = 0.1; % coefficient of friction for cart
    
    
% define matrices of the linearized system here:
% A = ;
% B = ;
% C = ;
% D = ;

% define system initial condition here 
% states = [postion; angle; velocity; angular velocity];
xinit = [0;0;0;0]; 

% compute observability matrix and check for observability of linearised
% system (for prelab)

% set desired eigenvalues for estimator system and find estimator gains

% set desired eigenvalues, controller parameters


