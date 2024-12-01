% wavelet1hr_modified_zh.m

% 清除工作空间和命令窗口
clear; clc;

% 定义小波函数和最大分解层数
WAVELET_FUNC = 'bior4.4';  % 可以修改为 'db4', 'sym5', 'coif3', 'haar' 等
MAX_SCALE = 6;
TH_FACTOR = 0.0025;

% 记录开始时间
tic;

% 加载原始信号
[ data_file, data_path ] = uigetfile( '*.txt', '选择一个数据文件' ); % 打开文件对话框
data = load ([data_path, data_file]);  % 加载1小时的压力数据
data = data(:, 3:end); % 忽略前两列的日期和时间
[row, col] = size( data );
lendata = row * col;                     
data = data'; % 将数据从行向量转换为列向量
data = reshape(data, lendata, 1); % 将数据重塑为 (row*col, 1) 的列向量
data = (data - 2^16 / 2) / (2^16 / 2); % 将数据范围从 0-65535 转换为 -1 到 +1

% 使用定义的小波函数对数据进行 MAX_SCALE 层分解
[c, l] = wavedec(data, MAX_SCALE, WAVELET_FUNC);                

% 从小波分解结构 [c, l] 中提取第 1 到 MAX_SCALE 层的近似系数
ca = cell(1, MAX_SCALE); % 初始化单元结构
for i = 1:MAX_SCALE
    ca{i} = appcoef(c, l, WAVELET_FUNC, i);                                                            
end

% 从小波分解结构 [c, l] 中提取第 1 到 MAX_SCALE 层的细节系数
cd = detcoef(c, l, 1:MAX_SCALE);                       

% 绘制原始数据、近似系数和细节系数
figure;
subplot(1 + MAX_SCALE, 1, 1); plot(data); title('原始信号');
for i = 1:MAX_SCALE
    subplot(1 + MAX_SCALE, 2, 2 * i + 1);
    plot(ca{1, i});
    title(['第 ', num2str(i), ' 层近似系数']);
    subplot(1 + MAX_SCALE, 2, 2 * i + 2);
    plot(cd{1, i});
    title(['第 ', num2str(i), ' 层细节系数']);
end

% 对第 4 和 5 层的细节系数进行去噪处理       
thr4 = std(cd{1, 4}) * TH_FACTOR * 2;
cd4x = wthresh(cd{1, 4}, 's', thr4);
thr5 = std(cd{1, 5}) * TH_FACTOR;
cd5x = wthresh(cd{1, 5}, 's', thr5);

% 从去噪后的 cd4x 和 cd5x 系数重构细节分量 d4x 和 d5x
d4x = upcoef('d', cd4x, WAVELET_FUNC, 4, lendata);
d5x = upcoef('d', cd5x, WAVELET_FUNC, 5, lendata);

% 从小波分解结构 [c, l] 中重构第 6 层的近似分量 a6
a6 = wrcoef('a', c, l, WAVELET_FUNC, 6);         

% 绘制原始信号、a6 和 d4x + d5x
figure;
subplot(3, 1, 1); plot(data); title('原始信号');
subplot(3, 1, 2); plot(a6); title('第 6 层近似分量 a6');
subplot(3, 1, 3); plot(d4x + d5x); title('第 4 和 5 层细节分量之和');

% 从分解系数 c 和 l 重构完整的信号
reconstructed_signal = waverec(c, l, WAVELET_FUNC);

% 计算均方误差（MSE）
mse = mean((data - reconstructed_signal).^2);

% 计算信噪比（SNR）
signal_power = mean(data.^2);
noise_power = mse;
snr_value = 10 * log10(signal_power / noise_power);

% 记录结束时间并计算运行时间
elapsed_time = toc;

% 显示结果
disp(['母小波函数：', WAVELET_FUNC]);
disp(['均方误差（MSE）：', num2str(mse)]);
disp(['信噪比（SNR）：', num2str(snr_value), ' dB']);
disp(['运行时间：', num2str(elapsed_time), ' 秒']);
