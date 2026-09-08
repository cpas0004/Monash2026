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

%% plotting

plot(DoutModel.Time, DoutModel.Data);
hold on
plot(Dout.Time, Dout.Data);

%%
ModelSS = DoutModel.data(end);

stepinfo(DoutModel.data, DoutModel.time, 37, RiseTimeLimits=[0.1, 0.9], SettlingTimeThreshold=0.05)

%% value for back calculation parameter (uncomment and complete)
kt = 2*ki/kp;

%%
stepinfo(Dout.Data, Dout.Time, 37, RiseTimeLimits=[0.1, 0.9], SettlingTimeThreshold=0.05)
