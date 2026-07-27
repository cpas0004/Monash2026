function TC = arduino_sim_MIMO(heater)

persistent T0 icount

if (isempty(icount)),
    % set initial condition
    T0 = [23+273.15;23+273.15]; % K
    icount = 0;
end

% increment counter
icount = icount + 1;
time = [0,1];
[time,T] = ode15s(@(t,x)energy_bal(t,x,heater(1),heater(2)),time,T0);
TK = T(end,:)';
T0 = TK;

%noise = (rand(2,1)-0.5)*1.0;
TC = TK -273.15;% + noise;

end
