% 作业：BBI数据处理

% -----------------------
% Step 1: 加载数据
% -----------------------
[data_file, data_path] = uigetfile('*.txt', '选择数据文件'); % 打开文件对话框
data = load([data_path, data_file]); % 加载数据
data = data(:, 3:end); % 忽略前两列（时间戳）
data = data(:); % 转为一列
data = (data - 2^16 / 2) / (2^16 / 2); % 范围从0-65535调整为-1到+1

% -----------------------
% Step 2: 离群值去除
% -----------------------
% 方法 1: 使用 Grubbs' 方法
mu = mean(data, 'omitnan');
sigma = std(data, 'omitnan');
G = abs(data - mu) / sigma; % Grubbs' 统计量
threshold = 2.5; % 阈值 (可调整)
data(G > threshold) = NaN; % 标记离群值为 NaN

% 可视化 Grubbs' 统计量分布
figure;
plot(G);
title('Grubbs统计量分布');
xlabel('样本点');
ylabel('统计量 G');

% 方法 2: 使用中值滤波器
window_size = 5; % 滑动窗口大小
data_filtered = medfilt1(data, window_size);

% 填补 NaN 以便后续处理
data_filtered = fillmissing(data_filtered, 'linear'); % 使用线性插值

% -----------------------
% Step 3: 平滑处理
% -----------------------
% 定义小波参数
WAVELET_FUNC = 'bior4.4'; % 双正交小波
MAX_SCALE = 6; % 最大分解层数
TH_FACTOR = 0.01; % 阈值因子（调整为更强的去噪）

% 小波分解
[c, l] = wavedec(data_filtered, MAX_SCALE, WAVELET_FUNC);

% 提取并去噪细节系数
cd = cell(1, MAX_SCALE); % 初始化细节系数
for i = 4:5 % 对4和5层进行去噪
    thr = std(detcoef(c, l, i)) * TH_FACTOR;
    cd{i} = wthresh(detcoef(c, l, i), 's', thr); % 去噪
end

% 重构近似分量和细节分量
a6 = wrcoef('a', c, l, WAVELET_FUNC, 6); % 近似分量
d4x = upcoef('d', cd{4}, WAVELET_FUNC, 4, length(data)); % 细节分量4
d5x = upcoef('d', cd{5}, WAVELET_FUNC, 5, length(data)); % 细节分量5

% 平滑后的数据
data_smoothed = a6 + d4x + d5x;

% -----------------------
% Step 4: 缺失数据填补
% -----------------------
% 方法 1: 线性插值
data_filled = fillmissing(data_smoothed, 'linear');

% 方法 2: 使用 Bootstrap 方法
nan_count_before = sum(isnan(data_filled)); % 填补前 NaN 数量
for i = 1:10 % 生成10个填补数据集
    bootstrap_sample = datasample(data_filled(~isnan(data_filled)), ...
        sum(isnan(data_filled)), 'Replace', true);
    data_filled(isnan(data_filled)) = bootstrap_sample;
end
nan_count_after = sum(isnan(data_filled)); % 填补后 NaN 数量

% 显示填补效果
fprintf('填补前NaN数量: %d\n', nan_count_before);
fprintf('填补后NaN数量: %d\n', nan_count_after);

% -----------------------
% Step 5: 可视化结果
% -----------------------
figure;
subplot(3, 1, 1); plot(data); title('原始数据');
subplot(3, 1, 2); plot(data_smoothed); title('平滑后的数据');
subplot(3, 1, 3); plot(data_filled); title('填补后的数据');

% -----------------------
% Step 6: 检查结果
% -----------------------
% 可视化原始数据与平滑数据的对比
figure;
plot(data, 'b', 'DisplayName', '原始数据');
hold on;
plot(data_smoothed, 'r', 'DisplayName', '平滑后的数据');
legend;
title('原始数据与平滑数据对比');
xlabel('样本点');
ylabel('幅值');
