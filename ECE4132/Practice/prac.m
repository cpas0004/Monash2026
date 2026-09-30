A = [1 -2; -2 1];
B = [1 ; 1];
C = [1 0];
D = 0;

model = ss(A, B, C, D);

[num, den] = ss2tf(A, B, C, D);

%% 

A = [-2 2; 1 -1];
B = [1 ; 0];
C = [0 1];
D = 0;

esteigvals = [-5 -10];

L = place(A', C', esteigvals)'
