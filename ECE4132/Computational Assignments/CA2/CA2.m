%%
clear all; clc;

%% 
load("Tsys.mat");
load("usys.mat");

Tsys_time = Tsys.time;
Tsys_data = Tsys.data;

usys_time = usys.time;
usys_data = usys.data;

plot(Tsys_time, Tsys_data, usys_time, usys_data);
xlabel("Time");
ylabel("Temp");

init_temp = Tsys_data(1);

fprintf("Initial temp (or T_room) is: %f\n", init_temp);
fprintf("Temp remain for approx 14s before rising\n");
fprintf("Temp steady state value is approx 49.5\n");
fprintf("Steady state of temp DEVIATION (D(t)=T(t)-Troom) = 27\n");
fprintf("Takes approx 109s to for temp DEVIATION to reach 63%% (17.01) of it's steady state (at total temp 39.51)\n");
fprintf("109-14 = 95s from delayed rise start to 63%%");