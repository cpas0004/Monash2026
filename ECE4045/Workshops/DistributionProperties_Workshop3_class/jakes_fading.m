function r = jakes_fading(fd, fs, N, duration)
%JAKES_FADING  Sum-of-sinusoids (Jakes/Clarke-style) Rayleigh fading envelope
% Inputs:
%   fd       - maximum Doppler frequency (Hz)
%   fs       - sampling frequency (Hz)
%   N        - number of sinusoids (e.g., 16 or more)
%   duration - total duration (s)
% Output:
%   r        - Rayleigh fading envelope (row vector)
%

%% When a mobile receiver moves through a wireless environment: Signals arrive from many directions due to reflections (buildings, terrain, vehicles).
%     Each path has a different phase and Doppler shift.% 
%     The superposition of these signals causes fast fluctuations in signal amplitude, called Rayleigh fading.
%     The Jakes model mathematically simulates this fading process.
%____________________________________________________________________________________
    t = 0:1/fs:duration;        % 1 x M
    M = numel(t);

    n = (1:N).';                % N x 1 (column)
    alpha_n = pi * n / (N + 1); % N x 1
    phi_n   = 2*pi*rand(N,1);   % N x 1 random phases

    % N x M matrix of angles for each sinusoid over time
    theta = 2*pi*fd*(cos(alpha_n) * t) + phi_n;

    % In-phase and quadrature components (approximately zero-mean Gaussian)
    I = sqrt(2/N) * sum(cos(theta), 1);  % 1 x M
    Q = sqrt(2/N) * sum(sin(theta), 1);  % 1 x M

    % Complex fading (unit average power) and Rayleigh envelope
    h = (I + 1j*Q) / sqrt(2);
    r = abs(h);                  % 1 x M
end