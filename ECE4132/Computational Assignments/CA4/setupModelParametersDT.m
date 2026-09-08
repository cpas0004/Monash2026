%% values of plant parameters
a = 0.0102;
K = 0.0051;
tau = 11;
yroom = 23;

ref = 30;
Dref = ref-yroom;

P = tf([-tau/2, 1],[tau/2 1])*tf(K,[1 a]);

%% values of PI controller parameters
kp = 6.5;
ki = 0.06;

%% value of sampling period
T = 10;

%% discrete-time approximation of PI controller (uncomment and complete)
z = tf('z');
Cd = kp + ki*T*(z+1)/(2*(z-1));

%% Plotting

DoutDTSS = DoutDT.data(end);

plot(DoutCT.time, DoutCT.data);
hold on
plot(DoutDT.time, DoutDT.data);
legend("CT", "DT");

CTinfo = stepinfo(DoutCT.data, DoutCT.time, 7);
DTinfo = stepinfo(DoutDT.data, DoutDT.time, 7);

CTrise = CTinfo.RiseTime;
CTsettle = CTinfo.SettlingTime;
CTovershoot = CTinfo.Overshoot;

DTrise = DTinfo.RiseTime;
DTsettle = DTinfo.SettlingTime;
DTovershoot = DTinfo.Overshoot;

fprintf("For the CT system:\nRise Time: %.2f\nSettling Time: %.2f\nOvershoot: %.2f\n", CTrise, CTsettle, CTovershoot);
fprintf("For the DT system:\nRise Time: %.2f\nSettling Time: %.4f\nOvershoot: %.2f\n", DTrise, DTsettle, DTovershoot);