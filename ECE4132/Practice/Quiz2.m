s = tf('s');

P = (s^2 + 81)/(s^2 * (s^2 + 100));
C = (s+1)/(s+13);

sys = P*C/(1+ P*C);
L = P*C;

rlocus(L)

%%
s = tf('s');
C = kp + ki/s + (kd*s)/(1+s*Tf);
% or 
C = tf(kp) + tf(ki, [1 0]) + tf([kd*s, 1+kd*S]) + tf([kd 0], [Tf 1]);

%%
% 37 is the manual steady state output value
stepinfo(DoutModel.data, DoutModel.time, 37, RiseTimeLimits=[0.1, 0.9], SettlingTimeThreshold=0.05)

CTinfo = stepinfo(DoutCT.data, DoutCT.time, 7);
DTinfo = stepinfo(DoutDT.data, DoutDT.time, 7);

CTrise = CTinfo.RiseTime;
CTsettle = CTinfo.SettlingTime;
CTovershoot = CTinfo.Overshoot;

DTrise = DTinfo.RiseTime;
DTsettle = DTinfo.SettlingTime;
DTovershoot = DTinfo.Overshoot;
