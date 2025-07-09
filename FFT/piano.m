clear;

path = 'C:/Users/chosh/OneDrive/바탕 화면/FFT/piano_music/';

% 피아노 음성 파일 불러오기
[signal , fs] = audioread(path + "piano.mp3");  % signal: 음성 데이터, fs: 샘플링 주파수

% 스테레오일 경우 모노로 변환
if size(signal, 2) == 2
    signal = mean(signal, 2);
end

start_sec = 0;
end_sec = 8;

start_sample = round(start_sec * fs);
end_sample = round(end_sec * fs);

% 경계값 확인 (signal 범위를 넘지 않도록)
start_sample = max(1, start_sample);
end_sample   = min(length(signal), end_sample);

signal = signal(start_sample : end_sample);

% Hamming Window 적용 => 끝부분에서 생기는 FFT 진동현상을 줄이기 위해 실행
window = hann(length(signal));
signal_windowed = signal .* window;

msTime = round(1000*size(signal,1)/fs); % 전체 신호의 길이(ms)
dt = 1000;                               % 분석에 사용할 프레임 단위
dtSmaples = round(dt*fs/1000);          % 프레임 시간(dt, ms)에 해당하는 샘플 수

N = dtSmaples;                          
cols = round(dtSmaples/2);
rows = floor(size(signal,1)/dtSmaples);

sampleF = zeros(rows, cols);            % 주파수 축
sampleN = zeros(rows, cols);            % 시간 축
mag = zeros(rows, cols);                % 진폭(크기) 축

pk_freqs = zeros(rows,1);
pk_mags = zeros(rows,1);

for i = 1:floor(size(signal,1)/dtSmaples)
    Y = fft(signal_windowed(dtSmaples*(i-1)+1:i*dtSmaples));
    f = (1:N-1)*(fs/N);
    magnitude = abs(Y)/N;               % 진폭 크기 스팩트럼
    
    % 대칭되는 양쪽 주파수 중 절반만 사용
    half_N = floor(N/2);
    f = f(1:half_N);
    magnitude = magnitude(1:half_N);
    magnitude(2:end) = 2 * magnitude(2:end);
    coherent_gain = sum(window)/length(window); % 윈도우 함수 사용
    magnitude = magnitude / coherent_gain;

    % 결과 저장
    sampleN(i,:) = ones(size(f))*((i-1)*dt/1000 + start_sec); % 프레임 시간 정보
    sampleF(i,:) = f;                           % 주파수 정보
    mag(i,:) = magnitude';                      % 진폭
    
    [pk_mags(i),idx] = max(magnitude);          % 가장 큰 진폭
    pk_freqs(i) = f(idx);                       % 해당 진폭이 발생한 주파수
end

freq_resolution = fs / N;
max_plot_bin = round(1000 / freq_resolution);

mag_filter = mag;
% mag_filter(mag_filter < 0.05) = NaN;

figure;
plot3(sampleF(:,1:max_plot_bin),sampleN(:,1:max_plot_bin),mag_filter(:,1:max_plot_bin));
xlabel('Frequency (Hz)');
ylabel('Time (s)');
zlabel('Magnitude');
title('FFT spectrum of Piano Note');
grid on;

T = table((0:rows-1)'*dt/1000, pk_freqs, pk_mags, ...
     'VariableNames', {'Time_sec','Peak_Freq_Hz','Peak_Magnitude'});

disp(T);
writetable(T, path + "Frequency.csv");

max_pk = max(pk_mags);
fprintf('%f',max_pk);