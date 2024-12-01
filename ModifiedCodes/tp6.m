% Homework: HRV Frequency Domain Analysis

% -----------------------
% Step 1: Load Preprocessed Data
% -----------------------
[data_file, data_path] = uigetfile('*.txt', 'Select a preprocessed data file'); % Open file dialog
data = load([data_path, data_file]); % Load data
RRI = data(:); % Reshape into a single column

% -----------------------
% Step 2: Calculate PSD using Welch Method
% -----------------------
fs = 4; % Sampling frequency (Hz), adjust based on dataset
[pxx, f] = pwelch(RRI, [], [], [], fs); % Welch PSD estimation

% -----------------------
% Step 3: Extract Frequency Domain Parameters
% -----------------------
% Frequency bands (Hz)
VLF_range = [0.003, 0.04];
LF_range = [0.04, 0.15];
HF_range = [0.15, 0.4];

% Total Power (0-0.4 Hz)
total_power = bandpower(RRI, fs, [0, 0.4]);

% VLF Power (0.003-0.04 Hz)
VLF_power = bandpower(RRI, fs, VLF_range);

% LF Power (0.04-0.15 Hz)
LF_power = bandpower(RRI, fs, LF_range);

% HF Power (0.15-0.4 Hz)
HF_power = bandpower(RRI, fs, HF_range);

% Normalized LF and HF Power
LF_norm = LF_power / (total_power - VLF_power) * 100;
HF_norm = HF_power / (total_power - VLF_power) * 100;

% LF/HF Ratio
LF_HF_ratio = LF_power / HF_power;

% -----------------------
% Step 4: Display Results
% -----------------------
fprintf('HRV Frequency Domain Parameters:\\n');
fprintf('Total Power: %.2f ms^2\\n', total_power);
fprintf('VLF Power: %.2f ms^2\\n', VLF_power);
fprintf('LF Power: %.2f ms^2\\n', LF_power);
fprintf('HF Power: %.2f ms^2\\n', HF_power);
fprintf('LF Norm: %.2f %%\\n', LF_norm);
fprintf('HF Norm: %.2f %%\\n', HF_norm);
fprintf('LF/HF Ratio: %.2f\\n', LF_HF_ratio);

% -----------------------
% Step 5: Visualize PSD
% -----------------------
figure;
plot(f, 10*log10(pxx)); % Plot PSD in dB scale
title('Power Spectral Density (PSD)');
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
xlim([0, 0.4]);