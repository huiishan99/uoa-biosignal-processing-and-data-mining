% Load original signal.                 
        [ data_file, data_path ] = uigetfile( '*.dat', 'Get a data file' ); % open file dialog box
        data = load ([ data_path, data_file]);  % 1 minute pressure data
        lendata = length(data);                     
        data=(data-2^16/2)/(2^16); % range shift from 0-65535 to -0.5-+0.5

% Define wavelet function
        waveletfunc = 'bior4.4';
        
% Perform decomposition at level 6 of data using the defined wavelet.
        [c,l] = wavedec(data, 6, waveletfunc);                
                                                           
% Extract approximation coefficients at level 6,
% from wavelet decomposition structure [c,l].   
        ca6 = appcoef(c, l, waveletfunc, 6);                                                            
        
% Extract detail coefficients at levels 4 and 5,
% from wavelet decomposition structure [c,l].      
        cd4 = detcoef(c, l, 4);                       
        cd5 = detcoef(c, l, 5);                       
        
% Now plot original data, ca6, cd4 and cd5.
        figure;
        subplot 411; plot(data); title('original signal');
        subplot 412; plot(ca6); title('approximation coefficients at level 6');
        subplot 413; plot(cd4); title('detail coefficients at levels 4');
        subplot 414; plot(cd5); title('detail coefficients at levels 5');
                
% Reconstruct approximation component at level 6,      
% from wavelet decomposition structure [c,l].
        a6 = wrcoef('a', c, l, waveletfunc, 6);         
                                              
% Reconstruct detail coefficients at levels 4 and 5,
% from the wavelet decomposition structure [c,l].     
        d4 = wrcoef('d', c, l, waveletfunc, 4);                  
        d5 = wrcoef('d', c, l, waveletfunc, 5);                  
        
% Now plot original signal, a6, d4 and d5.
        figure;
        subplot 511; plot(data); title('original signal');
        subplot 512; plot(a6); title('approximation component at level 6');
        subplot 513; plot(d4); title('detail component at level 4');
        subplot 514; plot(d5); title('detail component at level 5');
        subplot 515; plot(d4+d5); title('detail components at level 4+5');

% Reconstruct s from the wavelet decomposition structure [c,l].
        a0 = waverec(c, l, waveletfunc);      

% Now plot data and a0.
        figure;
        subplot 211; plot(data); title('original signal');
        subplot 212; plot(a0); title('reconstructed original signal from the wavelet decomposition structure [c,l]');


        