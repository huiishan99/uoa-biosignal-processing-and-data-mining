% wavelet1hr_modified.m

% Clear workspace and command window
clear; clc;

% Define wavelet function and maximum decomposition level
WAVELET_FUNC = 'bior3.5';  % You can change this to 'db4', 'sym5', 'coif3', 'haar', etc.
MAX_SCALE = 6;
TH_FACTOR = 0.0025;

% Start timing
tic;

% Load original signal
[data_file, data_path] = uigetfile('*.txt', 'Select a data file'); % Open file dialog
data = load([data_path, data_file]);  % Load 1-hour pressure data
data = data(:, 3:end); % Ignore the first two columns (date and time)
[row, col] = size(data);
lendata = row * col;
data = data'; % Transform data from row vector to column vector
data = reshape(data, lendata, 1); % Reshape data into a (row*col, 1) column vector
data = (data - 2^16 / 2) / (2^16 / 2); % Shift data range from 0-65535 to -1 to +1

% Perform decomposition at level MAX_SCALE using the defined wavelet function
[c, l] = wavedec(data, MAX_SCALE, WAVELET_FUNC);

% Extract approximation coefficients at levels 1 to MAX_SCALE
ca = cell(1, MAX_SCALE); % Initialize cell array
for i = 1:MAX_SCALE
    ca{i} = appcoef(c, l, WAVELET_FUNC, i);
end

% Extract detail coefficients at levels 1 to MAX_SCALE
cd = detcoef(c, l, 1:MAX_SCALE);

% Plot original data, approximation coefficients, and detail coefficients
figure;
subplot(1 + MAX_SCALE, 1, 1); plot(data); title('Original Signal');
for i = 1:MAX_SCALE
    subplot(1 + MAX_SCALE, 2, 2 * i + 1);
    plot(ca{1, i});
    title(['Approximation coefficients at level ', num2str(i)]);
    subplot(1 + MAX_SCALE, 2, 2 * i + 2);
    plot(cd{1, i});
    title(['Detail coefficients at level ', num2str(i)]);
end

% Denoise detail coefficients at levels 4 and 5
thr4 = std(cd{1, 4}) * TH_FACTOR * 2;
cd4x = wthresh(cd{1, 4}, 's', thr4);
thr5 = std(cd{1, 5}) * TH_FACTOR;
cd5x = wthresh(cd{1, 5}, 's', thr5);

% Reconstruct detail components d4x and d5x from denoised cd4x and cd5x
d4x = upcoef('d', cd4x, WAVELET_FUNC, 4, lendata);
d5x = upcoef('d', cd5x, WAVELET_FUNC, 5, lendata);

% Reconstruct approximation component at level 6
a6 = wrcoef('a', c, l, WAVELET_FUNC, 6);

% Plot original signal, a6, and d4x + d5x
figure;
subplot(3, 1, 1); plot(data); title('Original Signal');
subplot(3, 1, 2); plot(a6); title('Approximation component at level 6');
subplot(3, 1, 3); plot(d4x + d5x); title('Detail components at levels 4 and 5');

% Reconstruct the full signal from coefficients c and l
reconstructed_signal = waverec(c, l, WAVELET_FUNC);

% Calculate Mean Squared Error (MSE)
mse = mean((data - reconstructed_signal).^2);

% Calculate Signal-to-Noise Ratio (SNR)
signal_power = mean(data.^2);
noise_power = mse;
snr_value = 10 * log10(signal_power / noise_power);

% End timing and calculate elapsed time
elapsed_time = toc;

% Display results
disp(['Wavelet function: ', WAVELET_FUNC]);
disp(['Mean Squared Error (MSE): ', num2str(mse)]);
disp(['Signal-to-Noise Ratio (SNR): ', num2str(snr_value), ' dB']);
disp(['Elapsed time: ', num2str(elapsed_time), ' seconds']);
