% Homework: HRV Time Domain Analysis

% -----------------------
% Step 1: Load Data
% -----------------------
[data_file, data_path] = uigetfile('*.txt', 'Select a data file'); % Open file dialog
data = load([data_path, data_file]); % Load data
data = data(:, 3:end); % Ignore the first two columns (timestamps)
data = data(:); % Reshape into a single column
data = (data - 2^16 / 2) / (2^16 / 2); % Normalize data from range 0-65535 to -1 to +1

% -----------------------
% Step 2: Remove Outliers
% -----------------------
% Method 1: Using Grubbs' Test
mu = mean(data, 'omitnan');
sigma = std(data, 'omitnan');
G = abs(data - mu) / sigma; % Grubbs' Statistic
threshold = 2.5; % Threshold (adjustable)
data(G > threshold) = NaN; % Mark outliers as NaN

% Fill NaN for further processing
data_filtered = fillmissing(data, 'linear'); % Use linear interpolation

% -----------------------
% Step 3: Smoothing
% -----------------------
% Define Wavelet Parameters
WAVELET_FUNC = 'bior4.4'; % Biorthogonal wavelet
MAX_SCALE = 6; % Maximum decomposition level
TH_FACTOR = 0.01; % Threshold factor (adjusted for stronger denoising)

% Perform Wavelet Decomposition
[c, l] = wavedec(data_filtered, MAX_SCALE, WAVELET_FUNC);

% Reconstruct Approximation and Detail Components
a6 = wrcoef('a', c, l, WAVELET_FUNC, 6); % Approximation component
data_smoothed = a6;

% -----------------------
% Step 4: Calculate HRV Time Domain Parameters
% -----------------------
% Prepare RRI (BBI) data in seconds
RRI = data_smoothed; % Assuming data is already in BBI (RRI) format
RRI = RRI(~isnan(RRI)); % Remove any remaining NaN

% 1. Mean RRI (ms)
mean_RRI = mean(RRI) * 1000;

% 2. SDNN (ms) - Standard deviation of all NN intervals
SDNN = std(RRI) * 1000;

% 3. RMSSD (ms) - Root mean square of successive differences
diff_RRI = diff(RRI); % Difference between successive intervals
RMSSD = sqrt(mean(diff_RRI.^2)) * 1000;

% 4. NN50 and pNN50
NN50 = sum(abs(diff_RRI) > 0.05); % Count intervals with >50ms difference
pNN50 = (NN50 / length(RRI)) * 100; % Percentage of NN50

% 5. HRV Triangular Index
[hist_counts, bin_centers] = hist(RRI, 128); % Histogram of RRI intervals
HRV_Triangular_Index = sum(hist_counts) / max(hist_counts);

% 6. TINN (Triangular Interpolation of NN intervals)
[~, max_bin] = max(hist_counts); % Find histogram peak
left_bound = find(hist_counts(1:max_bin) <= max(hist_counts) / 2, 1, 'last');
right_bound = find(hist_counts(max_bin:end) <= max(hist_counts) / 2, 1, 'first') + max_bin - 1;
TINN = bin_centers(right_bound) - bin_centers(left_bound);

% -----------------------
% Step 5: Display HRV Results
% -----------------------
fprintf('HRV Time Domain Parameters:\n');
fprintf('Mean RRI: %.2f ms\n', mean_RRI);
fprintf('SDNN: %.2f ms\n', SDNN);
fprintf('RMSSD: %.2f ms\n', RMSSD);
fprintf('NN50: %d\n', NN50);
fprintf('pNN50: %.2f %%\n', pNN50);
fprintf('HRV Triangular Index: %.2f\n', HRV_Triangular_Index);
fprintf('TINN: %.2f ms\n', TINN);

% -----------------------
% Step 6: Visualize Results
% -----------------------
% Plot RRI Histogram
figure;
bar(bin_centers, hist_counts);
title('RRI Histogram');
xlabel('RRI (s)');
ylabel('Frequency');

% Overlay Triangular Interpolation
hold on;
plot([bin_centers(left_bound), bin_centers(max_bin), bin_centers(right_bound)], ...
    [0, max(hist_counts), 0], 'r-', 'LineWidth', 2);
legend('Histogram', 'Triangular Interpolation');
hold off;
