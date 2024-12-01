% Homework: HRV Time and Nonlinear Domain Analysis

% -----------------------
% Step 1: Load Data
% -----------------------
[data_file, data_path] = uigetfile('*.txt', 'Select a data file'); % Open file dialog
data = load([data_path, data_file]); % Load data
data = data(:, 3:end); % Ignore the first two columns (timestamps)
data = data(:); % Reshape into a single column
data = (data - 2^16 / 2) / (2^16 / 2); % Normalize data

% -----------------------
% Step 2: Preprocessing
% -----------------------
% Grubbs' Test for outlier detection
mu = mean(data, 'omitnan');
sigma = std(data, 'omitnan');
G = abs(data - mu) / sigma; % Grubbs' Statistic
threshold = 2.5;
data(G > threshold) = NaN;

% Fill missing data with bootstrap
data = fillmissing(data, 'linear');
bootstrap_sample = datasample(data(~isnan(data)), sum(isnan(data)), 'Replace', true);
data(isnan(data)) = bootstrap_sample;

% Wavelet smoothing
WAVELET_FUNC = 'bior4.4';
MAX_SCALE = 6;
[c, l] = wavedec(data, MAX_SCALE, WAVELET_FUNC);
a6 = wrcoef('a', c, l, WAVELET_FUNC, 6);
data_smoothed = a6;

% -----------------------
% Step 3: HRV Analysis
% -----------------------
% Time domain parameters
RRI = data_smoothed;
mean_RRI = mean(RRI) * 1000;
SDNN = std(RRI) * 1000;
diff_RRI = diff(RRI);
RMSSD = sqrt(mean(diff_RRI.^2)) * 1000;
NN50 = sum(abs(diff_RRI) > 0.05);
pNN50 = (NN50 / length(RRI)) * 100;
[hist_counts, bin_centers] = hist(RRI, 128);
HRV_Triangular_Index = sum(hist_counts) / max(hist_counts);
[~, max_bin] = max(hist_counts);
left_bound = find(hist_counts(1:max_bin) <= max(hist_counts) / 2, 1, 'last');
right_bound = find(hist_counts(max_bin:end) <= max(hist_counts) / 2, 1, 'first') + max_bin - 1;
TINN = bin_centers(right_bound) - bin_centers(left_bound);

% Poincaré analysis
SD1 = sqrt(var(diff_RRI) / 2);
SD2 = sqrt(2 * var(RRI) - var(diff_RRI) / 2);

% Sample Entropy
SampEn = sample_entropy(RRI, 2, 0.2 * std(RRI)); % Call the new function

% -----------------------
% Step 4: Display Results
% -----------------------
fprintf('HRV Time Domain Parameters:\n');
fprintf('Mean RRI: %.2f ms\n', mean_RRI);
fprintf('SDNN: %.2f ms\n', SDNN);
fprintf('RMSSD: %.2f ms\n', RMSSD);
fprintf('NN50: %d\n', NN50);
fprintf('pNN50: %.2f %%\n', pNN50);
fprintf('HRV Triangular Index: %.2f\n', HRV_Triangular_Index);
fprintf('TINN: %.2f ms\n', TINN);
fprintf('Poincaré Analysis:\n');
fprintf('SD1 (Short-term variability): %.2f ms\n', SD1);
fprintf('SD2 (Long-term variability): %.2f ms\n', SD2);
fprintf('Sample Entropy (SampEn): %.2f\n', SampEn);

% -----------------------
% Step 5: Visualizations
% -----------------------
% Histogram
figure; bar(bin_centers, hist_counts);
title('RRI Histogram'); xlabel('RRI (ms)'); ylabel('Frequency');

% Overlay Triangular Interpolation
hold on;
plot([bin_centers(left_bound), bin_centers(max_bin), bin_centers(right_bound)], ...
    [0, max(hist_counts), 0], 'r-', 'LineWidth', 2);
legend('Histogram', 'Triangular Interpolation');
hold off;

% Poincaré Plot
figure; scatter(RRI(1:end-1), RRI(2:end), 'b.');
title('Poincaré Plot'); xlabel('RRI_n (ms)'); ylabel('RRI_{n+1} (ms)');
