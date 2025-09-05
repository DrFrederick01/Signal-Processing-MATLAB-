%% Loads audio from provided .mat file
load("Cw2fluid_and_solid_data.mat");

for i = 1:length(fluid)
    dataset = fluid(i);
    audioData = dataset{1};

    fprintf('\n----------\n');
    fprintf(1, 'Now reading sample %u\n', i);

    %% Inspect the Audio Data
    % Display basic properties of the audio data
    disp('Audio data size:');
    size_audio_data = size(audioData);
    disp(size_audio_data);
    disp('Sampling Frequency (Fs):');
    disp(Fs);
    time = size_audio_data(1) / Fs;
    disp('Time (s):');
    disp(time);
    
    %% Plot the Time-Domain Signal
    % Create a time vector based on the sampling frequency
    N = length(audioData);       % Total number of samples
    t = (0:N-1)/Fs;            % Time vector in seconds
    
    % Plot the waveform
    figure('visible','off');
    plot(t, audioData);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Swallowing Sound - Time Domain (Recording %u)', i));
    grid on;
    saveas(gcf, [pwd sprintf('/output/given/time-domain-%u.png', i)]);
    
    %% Play the Audio
    % Uncomment the following line if you want to listen to the audio
    % sound(audioData, Fs);

    %% SNR Estimation
    % Define a time window that corresponds to the swallowing event.
    [maxSignal, indexOfMax] = max(audioData); % approximate time of swallowing event at maximum signal strength
    T1 = (indexOfMax / Fs) - 0.25; % Start time (seconds) of swallowing event, with tolerance of 0.25 seconds before
    fprintf('T1 = %.2f\n', T1);
    T2 = T1 + 1;   % End time (seconds) of swallowing event
    
    % Extract the signal region (swallowing event)
    signal_region = audioData(t >= T1 & t <= T2);
    
    % Define noise regions: combine segments before and after the event
    noise_region = [audioData(t < T1); audioData(t > T2)];
    
    % Compute power (mean squared value) for signal and noise
    signal_energy = sum(signal_region.^2);
    fprintf('Signal energy = %.4f \n', signal_energy);
    signal_power = signal_energy / size_audio_data(1);
    fprintf('Signal power = %.4f \n', signal_power);

    noise_energy = sum(noise_region.^2);
    fprintf('Noise energy = %.4f \n', noise_energy);
    noise_power = noise_energy / size_audio_data(1);
    fprintf('Noise power = %.4f \n', noise_power);

    total_energy = signal_energy + noise_energy;
    fprintf('Total energy = %.4f \n', total_energy);

    total_power = total_energy / time;
    fprintf('Total power = %.4f \n', total_power);

    % Calculate SNR in dB
    SNR_dB = 10 * log10(signal_power / noise_power);
    fprintf('Estimated SNR = %.2f dB\n', SNR_dB);
    
    %% Frequency-Domain Analysis (Adjusted)
    % Zero-pad the signal to improve frequency resolution
    nfft = 2^(nextpow2(length(audioData)) + 2);  % Pad by a factor of 4
    Y = fft(audioData, nfft);
    
    % Create a frequency vector for the padded FFT
    f = (-nfft/2:nfft/2-1) * (Fs/nfft);  % Frequency range including negative frequencies

    % Shift the FFT result to center the zero frequency
    Y_shifted = fftshift(Y);
    
    maxFreq = 1000;  % Maximum frequency (Hz) to display
    idx = f <= maxFreq;

    % Plot the magnitude spectrum for the selected frequency range
    figure('visible','off');
    plot(f(idx), abs(Y_shifted(idx)));
    xlabel('Frequency (Hz)');
    xlim([-maxFreq maxFreq])
    ylabel('Magnitude');
    title(sprintf('Frequency Spectrum (Zoomed In) (Recording %u)', i));
    grid on;
    saveas(gcf, [pwd sprintf('/output/given/frequency-spectrum-%u.png', i)]);
    
    %% Downsampling Investigation
    max_down_rate = round(max(abs(Y(idx)))/2);
    down_factors = [2, 4, 10, 20, max_down_rate];
    fprintf('Maximum down factor: %u \n', max_down_rate);
    powers = [[signal_power, noise_power]];
    snrs = [SNR_dB];

    for j = 1:length(down_factors)
        downFactor = down_factors(j);
        audioData_down = downsample(audioData, downFactor);
        Fs_down = Fs / downFactor;
        t_down = (0:length(audioData_down)-1) / Fs_down;
        
        % Recompute the signal and noise regions in the downsampled signal
        signal_region_down = audioData_down(t_down >= T1 & t_down <= T2);
        noise_region_down = [audioData_down(t_down < T1); audioData_down(t_down > T2)];
        
        % Compute power for the downsampled signal
        signal_energy_down = sum(signal_region_down.^2);
        signal_power_down = signal_energy_down / size_audio_data(1);
        noise_energy_down = sum(noise_region_down.^2);
        noise_power_down = noise_energy_down / size_audio_data(1);
        
        % Calculate SNR for the downsampled signal in dB
        SNR_dB_down = 10 * log10(signal_power_down / noise_power_down);
        fprintf('Estimated SNR after downsampling = %.2f dB\n', SNR_dB_down);
        
        powers = [powers; [signal_power_down, noise_power_down]];
        snrs = [snrs; SNR_dB_down];
    end

    %% Plot bar charts for powers and SNR
    down_factors = {'None', '2', '4', '10', '20', sprintf('%u', max_down_rate)};
    figure('visible','off');
    subplot(2,1,1);

    % Define the x positions for each category
    x_positions = 1:length(down_factors); % Evenly spaced positions
    set(gca, 'XTick', x_positions, 'XTickLabel', down_factors);
    
    bar(down_factors, powers);

    xlabel('Down Factor');
    ylabel('Power (W)');
    title(sprintf('Powers of signal and noise, before and after downsampling (Sample %u)', i));
    labels = {'Signal power', 'Noise power'};
    legend(labels, 'Location', 'best');
    
    subplot(2,1,2);
    bar(down_factors, snrs);
    xlabel('Down Factor');
    ylabel('Signal-to-Noise Ratio (dB)');
    title(sprintf('Signal-to-noise ratios before and after downsampling (Sample %u)', i));
    labels = {'Signal-to-noise ratio'};
    legend(labels, 'Location', 'best');
    saveas(gcf, [pwd sprintf('/output/given/power-and-snr-bar-%u.png', i)]);

    %% Redo frequency analysis
    % For consistency, we downsample all recordings in this analysis by a factor of 20
    audioData_down = downsample(audioData, 20);
    Fs_down = Fs / 20;
    t_down = (0:length(audioData_down)-1) / Fs_down;

    % Zero-pad the signal to improve frequency resolution
    nfft = 2^(nextpow2(length(audioData_down)) + 2);  % Pad by a factor of 4
    Y = fft(audioData_down, nfft);
    
    % Create a frequency vector for the padded FFT
    f = (-nfft/2:nfft/2-1) * (Fs/nfft);  % Frequency range including negative frequencies

    % Shift the FFT result to center the zero frequency
    Y_shifted = fftshift(Y);
    
    maxFreq = 1000;  % Maximum frequency (Hz) to display
    idx = abs(f) <= maxFreq;

    % Plot the magnitude spectrum for the selected frequency range
    figure('visible','off');
    plot(f(idx), abs(Y_shifted(idx)));
    xlabel('Frequency (Hz)');
    xlim([-maxFreq maxFreq])
    ylabel('Magnitude');
    title(sprintf('Downsampled Frequency Spectrum (Zoomed In) (Recording %u)', i));
    grid on;
    saveas(gcf, [pwd sprintf('/output/given/downsampled-frequency-spectrum-%u.png', i)]);
    
    %% Plot Original and Downsampled Signals
    figure('visible','off');
    subplot(2,1,1);
    plot(t, audioData);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Original Audio Signal (Recording %u)', i));
    
    subplot(2,1,2);
    plot(t_down, audioData_down);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Downsampled Audio Signal (Recording %u)', i));
    saveas(gcf, [pwd sprintf('/output/given/downsampled-%u.png', i)]);
end
