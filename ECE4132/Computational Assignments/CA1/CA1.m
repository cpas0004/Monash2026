clear all; close all; clc;

%% Step response
x = stepResponse.time;
y = stepResponse.data;

plot(x, y);

stepInfo = stepinfo(y, x, 'SettlingTimeThreshold', 0.02);
settleTime = stepInfo.SettlingTime;

steadyStateValue = y(find(x == ceil(settleTime)));
initValue = y(1);

fprintf("Steady state temp: %f\n", steadyStateValue);
fprintf("Initial room temp: %f\n", initValue);

%% 2 Modelling

H = 100;
syms C
eqn = steadyStateValue - initValue == C * H;
c = double(solve(eqn, C));

fprintf("Constant C is: %f\n", c);

T_ss = 40;
syms H
eqn = T_ss - initValue == c*H;
h_40 = double(solve(eqn, H));

fprintf("H for T_ss = 40: %f\n", h_40);

x = ffResponse.time;
y = ffResponse.data;

stepInfo = stepinfo(y, x, 'SettlingTimeThreshold', 0.02);
settleTime = stepInfo.SettlingTime;
steadyStateValue = y(find(x == ceil(settleTime)));
fprintf("Steady state temp for H = 32: %f\n", steadyStateValue);

x = coolResponse.time;
y = coolResponse.data;

plot(x, y);
xlabel("time (s)");
ylabel("Temp (C)");

%% 

hlevel = 50;

x = fbResponse.time;
y = fbResponse.data;

plot(x, y);
xlabel("time (s)");
ylabel("Temp (C)");