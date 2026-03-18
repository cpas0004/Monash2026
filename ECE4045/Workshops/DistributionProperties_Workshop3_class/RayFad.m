close all;
clear;

%% Parameters
fs = 1000;                 % Sampling frequency (Hz)
duration = 1000;           % Duration (s)
tim = 0:1/fs:duration;    % Time vector
fd = 100;                 % Doppler frequency (Hz)
threshold_dB = -20;       % Fade threshold (dB)

% The Jakes model is a deterministic approximation that generates
% time-correlated Rayleigh fading, capturing Doppler spread in mobile channels.

%% Generate Rayleigh fading using Jakes model
N_jakes = 100;  % Number of sinusoids (more = smoother)
rayleigh_envelope = jakes_fading(fd, fs, N_jakes, duration);

% Ensure time vector matches envelope length
tim = tim(1:length(rayleigh_envelope));

%% Apply fading to a constant signal
x = ones(1, length(rayleigh_envelope));
y = x .* rayleigh_envelope;

%% Convert envelope magnitude to dB
r_dB = 20 * log10(abs(y));

%% Plot fading signal
figure;
plot(tim, r_dB);
hold on;
yline(threshold_dB, 'r--', 'Threshold');
title('Rayleigh Fading Signal with Fade Events');
xlabel('Time (s)');
ylabel('Envelope Magnitude (dB)');
grid on;

%% Detect fades below threshold
fade_events = r_dB < threshold_dB;
fade_start = find(diff([0; fade_events(:)]) == 1);      % start indices
fade_end   = find(diff([fade_events(:); 0]) == -1)+1;     % end indices

%% Fade statistics
num_fades = length(fade_start);
fade_durations = (fade_end - fade_start) / fs;          % seconds

fprintf('Number of fades below %d dB: %d\n', threshold_dB, num_fades);
fprintf('Average fade duration: %.3f s\n', mean(fade_durations));

%% Interfade times (time between end of one fade and start of next fade)
if num_fades >= 2
    % 1) Complete expression: (fade_start(k+1) - fade_end(k)) * sampling period
    interfade_times = (fade_start(2:end) - fade_end(1:end-1)) / fs;  % seconds

    figure;
    histogram(interfade_times, 'BinMethod', 'sturges');
    title('Histogram of Interfade Times');
    xlabel('Interfade Time (s)');
    ylabel('Frequency');
    grid on;

    fprintf('Average inter-fade time: %.3f s\n', mean(interfade_times));
    fprintf('Minimum inter-fade time: %.3f s\n', min(interfade_times));
    fprintf('Maximum inter-fade time: %.3f s\n', max(interfade_times));
else
    warning('Not enough fade events to compute interfade times.');
end

%% Poisson analysis of fades per second
fade_times = tim(fade_start);        % fade start times (s)
time_bins = 0:1:duration;            % 1-second bins
fade_counts = histcounts(fade_times, time_bins);  % fades per 1-sec bin

% 2) lambda_hat = sample mean fades per second
lambda_hat = mean(fade_counts);

max_count = max(fade_counts);
x_vals = 0:max_count;
poisson_pmf = (lambda_hat.^x_vals .* exp(-lambda_hat)) ./ factorial(x_vals);

%% Compare empirical and Poisson distribution
figure;
histogram(fade_counts, ...
    'BinEdges', -0.5:1:max_count + 0.5, ...
    'Normalization', 'probability', ...
    'FaceAlpha', 0.6, ...
    'DisplayName', 'Empirical');
hold on;
stem(x_vals, poisson_pmf, 'r', 'filled', 'DisplayName', 'Poisson PMF');
plot(x_vals, poisson_pmf);
xlabel('Number of Fades per Second');
ylabel('Probability');
title(sprintf('Fades per Second: Empirical vs Poisson (\\lambda = %.2f)', lambda_hat));
legend('Location', 'best');
grid on;