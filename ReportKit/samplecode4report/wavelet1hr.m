% Define wavelet function and max scale
        WAVELET_FUNC = 'bior4.4';
        MAX_SCALE = 6;
        TH_FACTOR = 0.0025;
        
% Load original signal.                 
        [ data_file, data_path ] = uigetfile( '*.txt', 'Get a data file' ); % open file dialog box
        data = load ([data_path, data_file]);  % 1 hour pressure data
        data = data(:, 3:end); % ignore the first two columns of date and time
        [row, col] = size( data );
        lendata = row*col;                     
        data = data'; % transform 1min data format from one row to one column 
        data = reshape(data, lendata, 1); % dataから列方向に要素を使ってrow*col行1列の行列を出力する
        data = (data-2^16/2) / (2^16/2); % range shift from 0-65535 to -1-+1
        
% Perform decomposition at level MAX_SCALE of data using the defined wavelet WAVELET_FUNC.
        [c,l] = wavedec(data, MAX_SCALE, WAVELET_FUNC);                
                                                           
% Extract approximation coefficients at level 1-MAX_SCALE,
% from wavelet decomposition structure [c,l].  
        ca = cell(1, MAX_SCALE); % initialize cell structure
        for (i=1:MAX_SCALE)
            ca{i} = appcoef(c, l, WAVELET_FUNC, i);                                                            
        end;
% Extract detail coefficients at levels 1-MAX_SCALE,
% from wavelet decomposition structure [c,l].      
        cd = detcoef(c, l,  [1:MAX_SCALE]);                       

% Plot original data, approximation and detail coefficients
        figure;
        subplot(1+MAX_SCALE, 1, 1); plot(data); title('original signal');
        for (i=1:MAX_SCALE)
            subplot(1+MAX_SCALE, 2, 2*i+1);
            plot(ca{1,i});
            title(['approximation coefficients at level ', num2str(i)]);
            subplot(1+MAX_SCALE, 2, 2*i+2);
            plot(cd{1,i});
            title(['detail coefficients at level ', num2str(i)]);
        end;
              
% Denoise of detail coefficients at levels 4 and 5       
        thr4 = std( cd{1,4} ) * TH_FACTOR * 2;
        cd4x = wthresh( cd{1,4}, 's', thr4 );
        thr5 = std( cd{1,5} ) * TH_FACTOR;
        cd5x = wthresh( cd{1,5}, 's', thr5 );
        
% Reconstruct detail components d4x and d5x from denoised cd4x and cd5x coefficients
        d4x = upcoef('d', cd4x, WAVELET_FUNC, 4, lendata);
        d5x = upcoef('d', cd5x, WAVELET_FUNC, 5, lendata);
                      
% Reconstruct approximation component at level 6,      
% from wavelet decomposition structure [c,l].
        a6 = wrcoef('a', c, l, WAVELET_FUNC, 6);         

% Plot original signal, a6, and d4x+d5x.
        figure;
        subplot 311; plot(data); title('original signal');
        subplot 312; plot(a6); title('approximation component at level 6');
        subplot 313; plot(d4x+d5x); title('detail components at level 4+5');        