# **Homework - Topic 6:**
# **Analysis of HRV in Frequency Domain**

**Lai Hui Shan M5281022**

---

## **1. Data Preprocessing**

- The raw BBI data was preprocessed using Grubbs’ Test and median filtering.
- Missing data was handled using linear interpolation and bootstrap resampling.
- The smoothed BBI data was converted to RRI format and used for frequency domain analysis.

---

## **2. HRV Frequency Domain Analysis**

### **Parameters and Results**

The following frequency domain parameters were calculated based on the processed RRI data:

| **Parameter**        | **Value**         |
|----------------------|-------------------|
| Total Power          | 1098099207.82 ms² |
| VLF Power (0.003-0.04 Hz) | 394052.09 ms²  |
| LF Power (0.04-0.15 Hz)   | 1158361.66 ms² |
| HF Power (0.15-0.4 Hz)    | 2757832.19 ms² |
| LF Norm (%)          | 0.11%            |
| HF Norm (%)          | 0.25%            |
| LF/HF Ratio          | 0.42             |

### **Key Observations**

1. **Total Power**:
   - The total power (TP) is extremely high, which may indicate an unusually high variability in the dataset.
2. **LF and HF Power**:
   - Both LF and HF power values are relatively low compared to the total power, resulting in low normalized values.
3. **LF/HF Ratio**:
   - The LF/HF ratio is 0.42, indicating a dominance of high-frequency components in the dataset.

---

## **3. Power Spectral Density (PSD) Visualization**

The PSD of the RRI data was estimated using Welch's method. The following figure shows the PSD distribution within the frequency range of 0-0.4 Hz.

![Power Spectral Density (PSD)](../Figures/tp6_psd.png)

---

## **4. Conclusion**

- The frequency domain analysis revealed a dominance of high-frequency (HF) components in the dataset, as indicated by the low LF/HF ratio.
- The low normalized LF and HF power values suggest limited variability in the lower frequency bands.
- These results indicate a potential issue with the input data's scale or sampling rate, which may require further validation or correction.

---

### **Appendices: MATLAB Code**

```matlab
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
