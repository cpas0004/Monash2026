T0 = 300;
% t = 0:0.001:0.5;
t = 0:0.01:100;

T2 = 2/9 *(3*t-1+exp(-3*t))+T0;

plot(t, T2);
xlabel('Time (s)');
ylabel('Temperature (K)');
title('Temperature Variation Over Time');
grid on;