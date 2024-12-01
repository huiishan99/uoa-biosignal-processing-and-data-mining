function SampEn = sample_entropy(data, m, r)
    % Calculate Sample Entropy (SampEn)
    % data: Time-series data (RRI)
    % m: Embedding dimension
    % r: Tolerance (usually 0.2 * standard deviation of the data)

    N = length(data); % Length of the time series

    % Check if data is long enough
    if N <= m + 1
        SampEn = NaN;
        warning('Data length is too short for given embedding dimension m.');
        return;
    end

    % Create embedding vectors
    X = zeros(N - m, m);
    for i = 1:(N - m)
        X(i, :) = data(i:i + m - 1);
    end

    % Count matches for embedding dimension m
    B = 0; % Matches for m
    for i = 1:(N - m)
        for j = i + 1:(N - m)
            if max(abs(X(i, :) - X(j, :))) <= r
                B = B + 1;
            end
        end
    end

    % Count matches for embedding dimension m+1
    X_plus1 = zeros(N - m - 1, m + 1);
    for i = 1:(N - m - 1)
        X_plus1(i, :) = data(i:i + m); % Add one more dimension
    end

    A = 0; % Matches for m+1
    for i = 1:(N - m - 1)
        for j = i + 1:(N - m - 1)
            if max(abs(X_plus1(i, :) - X_plus1(j, :))) <= r
                A = A + 1;
            end
        end
    end

    % Calculate SampEn
    if B == 0
        SampEn = NaN;
        warning('No matches found for m dimension. SampEn cannot be calculated.');
    else
        SampEn = -log(A / B); % Negative log of the probability ratio
    end
end
