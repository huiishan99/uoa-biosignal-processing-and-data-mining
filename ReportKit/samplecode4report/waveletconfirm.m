% Load original signal.                 
        [ data_file, data_path ] = uigetfile( '*.dat', 'Get a data file' ); % open file dialog box
        data = load ([ data_path, data_file]);  % 1 minute pressure data
        lendata = length(data);                     
        data=(data-2^16/2)/(2^16/2); % range shift from 0-65535 to -0.5-+0.5

% Define wavelet function
        waveletfunc = 'bior4.4';
        
% Perform decomposition at level 6 of data using the defined wavelet.
        [c,l] = wavedec(data, 6, waveletfunc);                
                                                           
% Extract approximation coefficients at level 1-6,
% from wavelet decomposition structure [c,l].   
        ca1 = appcoef(c, l, waveletfunc, 1);                                                            
        ca2 = appcoef(c, l, waveletfunc, 2);                                                            
        ca3 = appcoef(c, l, waveletfunc, 3);                                                            
        ca4 = appcoef(c, l, waveletfunc, 4);                                                            
        ca5 = appcoef(c, l, waveletfunc, 5);                                                            
        ca6 = appcoef(c, l, waveletfunc, 6);                                                            
        
% Extract detail coefficients at levels 1-6,
% from wavelet decomposition structure [c,l].      
        cd1 = detcoef(c, l, 1);                       
        cd2 = detcoef(c, l, 2);                       
        cd3 = detcoef(c, l, 3);                       
        cd4 = detcoef(c, l, 4);                       
        cd5 = detcoef(c, l, 5);                       
        cd6 = detcoef(c, l, 6);                       

% Plot original data, ca6, cd4 and cd5.
        figure;
        subplot 711; plot(data); title('original signal');
        subplot 723; plot(ca1); title('approximation coefficients at level 1');
        subplot 724; plot(cd1); title('detail coefficients at levels 1');
        subplot 725; plot(ca2); title('approximation coefficients at levels 2');
        subplot 726; plot(cd2); title('detail coefficients at levels 2');
        subplot 727; plot(ca3); title('approximation coefficients at levels 3');
        subplot 728; plot(cd3); title('detail coefficients at levels 3');
        subplot 729; plot(ca4); title('approximation coefficients at levels 4');
        subplot(7,2,10); plot(cd4); title('detail coefficients at levels 4');
        subplot(7,2,11); plot(ca5); title('approximation coefficients at levels 5');
        subplot(7,2,12); plot(cd5); title('detail coefficients at levels 5');
        subplot(7,2,13); plot(ca6); title('approximation coefficients at levels 6');
        subplot(7,2,14); plot(cd6); title('detail coefficients at levels 6');
        
% Denoise of cd4 and cd5       
        thrfactor=.1;
        thr5 = std( cd5 ) * thrfactor;
        cd5x = wthresh( cd5, 's', thr5 );
        thr4 = std( cd4 ) * thrfactor * 2;
        cd4x = wthresh( cd4, 's', thr4 );
        
% Reconstruct d4 and d5 components from denoised cd4x and cd5x coefficients
        d4x = upcoef('d', cd4x, waveletfunc, 4, 6000);
        d5x = upcoef('d', cd5x, waveletfunc, 5, 6000);

% Plot original data, ca6, cd4 and cd5.
        figure;
        subplot 411; plot(data); title('original signal');
        subplot 412; plot(ca6); title('approximation coefficients at level 6');
        subplot 413; plot(cd4); title('detail coefficients at levels 4');
        subplot 413; hold on; plot(cd4x, 'r'); title('detail coefficients at levels 4');
        subplot 414; plot(cd5); title('detail coefficients at levels 5');
        subplot 414; hold on; plot(cd5x, 'r'); title('detail coefficients at levels 5');
                       
% Reconstruct approximation component at level 6,      
% from wavelet decomposition structure [c,l].
        a6 = wrcoef('a', c, l, waveletfunc, 6);         
                                              
% Reconstruct detail coefficients at levels 4 and 5,
% from the wavelet decomposition structure [c,l].     
        d4 = wrcoef('d', c, l, waveletfunc, 4);                  
        d5 = wrcoef('d', c, l, waveletfunc, 5);                  
        
% Plot original signal, a6, d4 and d5.
        figure;
        subplot 511; plot(data); title('original signal');
        subplot 512; plot(a6); title('approximation component at level 6');
        subplot 513; plot(d4); title('detail component at level 4');
        subplot 514; plot(d5); title('detail component at level 5');
        subplot 515; plot(d4+d5); title('detail components at level 4+5');
        subplot 515; hold on; plot(d4x+d5x, 'r'); title('detail components at level 4+5');        