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
        subplot 511; plot(data);
        subplot 512; plot(ca6);
        subplot 513; plot(cd4);
        subplot 514; plot(cd5);
        subplot 515; plot(cd4+cd5);
                
% Reconstruct approximation at level 3,      
% from wavelet decomposition structure [c,l].
        a3 = wrcoef('a', c, l, waveletfunc, 3);         
                                              
% Reconstruct detail coefficients at levels 1, 2 and 3,
% from the wavelet decomposition structure [c,l].     
        d3 = wrcoef('d', c, l, waveletfunc, 3);                  
        d2 = wrcoef('d', c, l, waveletfunc, 2);                  
        d1 = wrcoef('d', c, l, waveletfunc, 1);                          

% Now plot a3, d3, d2 and d1.
        figure;
        subplot 511; plot(data);
        subplot 512; plot(a3);
        subplot 513; plot(d3);
        subplot 514; plot(d2);
        subplot 515; plot(d1);

% Reconstruct s from the wavelet decomposition structure [c,l].
        a0 = waverec(c, l, waveletfunc);      

% Now plot data and a0.
        figure;
        subplot 211; plot(data);
        subplot 212; plot(a0);


        