%% Second order system model parameters

a = 0.0102;
K = 0.0051;
tau = 11;
y_room = 23;

s = tf('s');

%% Section 2.1

P = (K*(1-(s*tau)/2))/((1+(s*tau)/2)*(s+a));
% Gp = (P*kp)/(1 + P*kp);

rlocus(P);

%% Section 2.2

kp = 10;

A = tau/2*s^3 + (1 + a*tau/2 - tau*K*kp/2)*s^2 + (a+kp*K)*s;
B = K - tau*K*s/2;

rlocus(B/A);
grid on;
title(sprintf('Root locus for k_p = %.2f', kp))