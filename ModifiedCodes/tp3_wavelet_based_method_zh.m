% 清空工作区和命令窗口
clear; clc;

% 加载原始信号
[data_file, data_path] = uigetfile('*.dat', '选择一个数据文件'); % 打开文件对话框
data = load([data_path, data_file]);  % 加载1分钟的压力数据
lendata = length(data);
data = (data - 2^16/2) / (2^16/2); % 将范围从0-65535转换到-0.5到+0.5

% 定义小波函数
waveletfunc = 'bior4.4';

% 使用定义的小波对数据进行6级分解
[c, l] = wavedec(data, 6, waveletfunc);

% 提取第4级和第5级的细节系数
cd4 = detcoef(c, l, 4);
cd5 = detcoef(c, l, 5);

% 对cd4和cd5进行去噪
thrfactor = 0.1;
thr5 = std(cd5) * thrfactor;
cd5x = wthresh(cd5, 's', thr5);
thr4 = std(cd4) * thrfactor * 2;
cd4x = wthresh(cd4, 's', thr4);

% 从去噪后的系数重构细节分量
d4x = wrcoef('d', c, l, waveletfunc, 4);
d5x = wrcoef('d', c, l, waveletfunc, 5);

% 合并细节分量
reconstructed_signal = d4x + d5x;

% 增强信号（平方）
enhanced_signal = reconstructed_signal .^ 2;

% 设置峰值检测的阈值
threshold = mean(enhanced_signal) + 0.5 * std(enhanced_signal);

% 在增强的信号中查找峰值
[peaks, locs] = findpeaks(enhanced_signal, 'MinPeakHeight', threshold, 'MinPeakDistance', 50);

% 绘制原始信号和检测到的峰值
figure;
subplot(2,1,1);
plot(data);
title('原始信号');
xlabel('样本点');
ylabel('幅值');

subplot(2,1,2);
plot(enhanced_signal);
hold on;
plot(locs, peaks, 'ro');
title('增强信号与检测到的峰值');
xlabel('样本点');
ylabel('幅值');
legend('增强信号', '检测到的峰值');

% 显示检测到的峰值位置
disp('检测到的峰值位置（索引）：');
disp(locs);

%% 性能评估

% 这里假设有一个实际特征点位置的向量actual_peaks

% 示例实际特征点
actual_peaks = [29, 1132, 2172, 3389, 4325, 5397, 5941];

% 初始化计数
TP = 0;
FP = 0;
FN = 0;

tolerance = 5; % 定义容忍度窗口

% 将检测到的峰值和实际峰值转换为逻辑数组
detected_array = zeros(1, length(data));
detected_array(locs) = 1;

actual_array = zeros(1, length(data));
actual_array(actual_peaks) = 1;

% 计算TP和FN
for i = 1:length(actual_peaks)
    window_start = max(actual_peaks(i) - tolerance, 1);
    window_end = min(actual_peaks(i) + tolerance, length(data));
    if any(detected_array(window_start:window_end))
        TP = TP + 1;
    else
        FN = FN + 1;
    end
end

% 计算FP
for i = 1:length(locs)
    window_start = max(locs(i) - tolerance, 1);
    window_end = min(locs(i) + tolerance, length(data));
    if ~any(actual_array(window_start:window_end))
        FP = FP + 1;
    end
end

% 总的负例数量
Total_Negatives = length(data) - length(actual_peaks);

% 计算TN
TN = Total_Negatives - FP;

% 计算性能指标
Accuracy = (TP + TN) / (TP + TN + FP + FN);
Sensitivity = TP / (TP + FN);
Specificity = TN / (TN + FP);
Positive_Predictability = TP / (TP + FP);
Negative_Predictability = TN / (TN + FN);

% 显示结果
fprintf('\n性能指标（小波变换法）：\n');
fprintf('准确率（Accuracy）：%.2f%%\n', Accuracy * 100);
fprintf('灵敏度（Sensitivity）：%.2f%%\n', Sensitivity * 100);
fprintf('特异性（Specificity）：%.2f%%\n', Specificity * 100);
fprintf('阳性预测值（Positive Predictability）：%.2f%%\n', Positive_Predictability * 100);
fprintf('阴性预测值（Negative Predictability）：%.2f%%\n', Negative_Predictability * 100);
