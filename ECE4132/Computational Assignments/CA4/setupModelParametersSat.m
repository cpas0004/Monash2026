%% values of plant parameters
a = 0.0102;
K = 0.0051;
tau = 11;
yroom = 23;

ref = 60;
Dref = 60-yroom;

P = tf([-tau/2, 1],[tau/2 1])*tf(K,[1 a]);

%% values of PI controller parameters
kp = 8.75;
ki = 0.1;

%% value for back calculation parameter (uncomment and complete)
% kt = ...;
