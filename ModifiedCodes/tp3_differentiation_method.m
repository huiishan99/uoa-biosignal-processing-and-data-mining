% Clear workspace and command window
clear; clc;

% Load the original signal
[data_file, data_path] = uigetfile('*.dat', 'Select a data file'); % Open file dialog
data = load([data_path, data_file]);  % Load 1-minute pressure data
lendata = length(data);
data = (data - 2^16/2) / (2^16/2); % Convert range from 0-65535 to -0.5 to +0.5

% Compute the first derivative of the signal
diff_data = diff(data);

% Enhance the derivative signal (take absolute value)
enhanced_diff = abs(diff_data);

% Set threshold for peak detection
threshold = mean(enhanced_diff) + 0.5 * std(enhanced_diff);

% Find peaks in the enhanced derivative signal
[peaks, locs] = findpeaks(enhanced_diff, 'MinPeakHeight', threshold, 'MinPeakDistance', 50);

% Adjust locs because the length reduces by 1 after diff
locs = locs + 1;

% Plot the original signal and detected peaks
figure;
subplot(2,1,1);
plot(data);
title('Original Signal');
xlabel('Sample Points');
ylabel('Amplitude');

subplot(2,1,2);
plot(enhanced_diff);
hold on;
plot(locs - 1, peaks, 'ro');
title('Enhanced Derivative Signal and Detected Peaks');
xlabel('Sample Points');
ylabel('Amplitude');
legend('Enhanced Derivative Signal', 'Detected Peaks');

% Display detected peak locations
disp('Detected peak locations (indices):');
disp(locs);

%% Performance evaluation

% Assume there is a vector of actual feature point locations
% Example actual feature points
actual_peaks = [21, 588, 806, 1607, 2439, 3280, 4061, 4140, 5740, 5972]; 

% Initialize counters
TP = 0;
FP = 0;
FN = 0;

tolerance = 5; % Define tolerance window

% Convert detected peaks and actual peaks to logical arrays
detected_array = zeros(1, length(data));
detected_array(locs) = 1;

actual_array = zeros(1, length(data));
actual_array(actual_peaks) = 1;

% Calculate TP and FN
for i = 1:length(actual_peaks)
    window_start = max(actual_peaks(i) - tolerance, 1);
    window_end = min(actual_peaks(i) + tolerance, length(data));
    if any(detected_array(window_start:window_end))
        TP = TP + 1;
    else
        FN = FN + 1;
    end
end

% Calculate FP
for i = 1:length(locs)
    window_start = max(locs(i) - tolerance, 1);
    window_end = min(locs(i) + tolerance, length(data));
    if ~any(actual_array(window_start:window_end))
        FP = FP + 1;
    end
end

% Total negatives
Total_Negatives = length(data) - length(actual_peaks);

% Calculate TN
TN = Total_Negatives - FP;

% Compute performance metrics
Accuracy = (TP + TN) / (TP + TN + FP + FN);
Sensitivity = TP / (TP + FN);
Specificity = TN / (TN + FP);
Positive_Predictability = TP / (TP + FP);
Negative_Predictability = TN / (TN + FN);

% Display results
fprintf('\nPerformance Metrics (Differentiation Method):\n');
fprintf('Accuracy: %.2f%%\n', Accuracy * 100);
fprintf('Sensitivity: %.2f%%\n', Sensitivity * 100);
fprintf('Specificity: %.2f%%\n', Specificity * 100);
fprintf('Positive Predictability: %.2f%%\n', Positive_Predictability * 100);
fprintf('Negative Predictability: %.2f%%\n', Negative_Predictability * 100);
