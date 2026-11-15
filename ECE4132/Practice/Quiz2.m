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

%%
lsim
% used to simulate system response to arbitrary input

%% The Quiz

s = tf('s');
G = 8/((s+2)*(s+1)^2);

[Gm, Pm, Wcp, Wcg] = margin(G);

%%
s = tf('s');
L = 10/((s+1)*(s^2+4*s+5));
margins = allmargin(L);

%%
A = [
    -18.4456   4.2263  -2.2830   0.2260   0.4220  -0.0951;
    -4.0977  -6.0706   5.6825  -0.6966  -1.2246   0.2873;
    1.4449   1.4336  -2.6477   0.6092   0.8979  -0.2300;
    -0.0093   0.2302  -0.5002  -0.1764  -6.3152   0.1350;
    -0.0464  -0.3489   0.7238   6.3117  -0.6886   0.3645;
    -0.0602  -0.2361   0.2300   0.0915  -0.3214  -0.2087
    ];

B = [
    -0.2748    3.1463;
    -0.0501   -9.3737;
    -0.1550    7.4296;
    0.0716   -4.9176;
    -0.0814  -10.2648;
    0.0244   13.7943
    ];

C = [
    0.5971  -0.7697   4.8850   4.8608  -9.8177  -8.8610;
    3.1013   9.3422  -5.6000  -0.7490   2.9974  10.5719
    ];

D = [
    0  0;
    0  0
    ];

% -ve real eigs to be internally stable
A_eigs = eig(A);

q6_sys = ss(A, B, C, D);
q6_poles = pole(q6_sys);

% Getting L for estimator
desired_eigs = [-5-5*i -5+5*i -2-2*i -2+2*i -20 -30];
L = place(A', C', desired_eigs)';

desired_eigs2 = [-2.5-2.5*i -2.5+2.5*i -1-i -1+i -10 -15];
K = place(A, B, desired_eigs2);

kr = -inv(C*inv(A-B*K)*B);
kr_full = inv(D-(C-D*K)*inv(A-B*K)*B);

%%

s = tf('s');
w5L = ((s^2+81)/(s^2*(s^2+100))) * ((s+1)/(s+13));
rlocus(w5L)
grid on;
%%
sys = tf([1 1 81 81],[1 13 100 1300 0 0]);
rlocus(sys);
grid on;

%%
A = [0 -4; 1 0];
B = [1; 0];
C = [2 3];
D = 1;
eigs = [-1-i -1+i];
K = place(A, B, eigs);

kr = inv(D-(C-D*K)*inv(A-B*K)*B);

sys = tf([1], [1, 2, 1]); % Create a transfer function
step(sys);                 % Plot step response

%%

A = [1 1; -1 1];
B = [1; 0];
C = [1 1];
D = zeros(size(C, 1), size(B, 2));

m = ss(A, B, C, D);
[num, den] = ss2tf(A, B, C, D);

%%
A = [0 1; -4 0];
B = [1; 2];
C = [1 0];
D = 0;

esteigs = [-1-i, -1+i];
L = place(A', C', esteigs)';

despoles = [-0.5 -1];
K = place(A, B, despoles);

%%

A = [2 1; 1 0];
B = [1; 0];
C = [1 0];

despoles = [-2-i -2+i];
K = place(A, B, despoles);

deseigs = [-2-i -2+i];
L = place(A', C', deseigs)';

sys = 3/((s+1)^3);
[Gm, Pm, Wcp, Wcg] = margin(sys);
margin(sys)

%%

s = tf('s');
G = 8/((s+2)*(s+1)^2);
nyquist(G);

%%

L = 30/((s+1)*(s+2)*(s+4));
Gre = 1/(1+L);

bodeplot(Gre);

%%
A = [0 1; 2 -1];
B = [0; 1];
C = [1 0];
D = 0;

Keigs = [-2+2*i -2-2*i];
K = place(A, B, Keigs);

kr = -inv(C*inv(A-B*K)*B);

det(s*eye(2)-(A-[L1; L2]*C))
