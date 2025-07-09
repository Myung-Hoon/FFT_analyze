% 기본적인 sin/cos파 그리는 방법

fs = 1000;          % 샘플링 주파수
T = 0:1/fs:1-1/fs;  % 시간 벡터
f1 = 50;            % 50Hz
f2 = 60;            % 60Hz
f3 = 70;            % 70Hz
f4 = 80;            % 80Hz
x = sin(2*pi*f1*T); % sin파 생성
x1 = sin(2*pi*f3*T);% sin파 생성
x2 = cos(2*pi*f2*T);% cos파 생성
x3 = cos(2*pi*f4*T);% cos파 생성


subplot(6,1,1);
plot(T,x);
title("sin50");

subplot(6,1,2);
plot(T,x1);
title("sin70");

subplot(6,1,3);
plot(T,x2);
title("cos60");

subplot(6,1,4);
plot(T,x3);
title("cos80");

total_x = x+x1+x2+x3;
subplot(6,1,5);
plot(T,total_x);
xlabel("Times");
ylabel("frequency");
title("sin+cos");


% FFT 분석

N = length(x);              % 데이터 갯수
X = fft(x+x1+x2+x3);        % fft 실행
f_axis = (0:N-1)*(fs/N);    % 주파수 축 생성
mag = abs(X)/N;             % 크기 스팩트럼

figure;
%subplot(6,1,6);
plot(f_axis,mag);
xlabel("Frequency");
ylabel("Magnitude");
title("FFT Magnitude Spectrum");
xlim([0 100]);


% Goertzel 알고리즘

target_freq = 80;             % 분석할 주파수
k = round(target_freq*N/fs);    % 해당 주파수에 대한 DFT 인덱스
w = 2*pi*k/N;                   % 각 주파수

% 재귀 필터 형태의 계산을 위해 필요한 상수
coeff = 2*cos(w);               % 알고리즘에서 사용하는 상수 계수

% 2차 재귀 필터 형태라서 이전 두 상태값이 필요
s1 = 0;
s2 = 0;

% 알고리즘의 연산 ( 하나의 주파수 성분만 추적할 수 있도록 누적 계산 )
for n = 1:N
    s = total_x(n) + coeff * s1 - s2;
    s2 = s1;
    s1 = s;
end

power = s2^2 + s1^2 - coeff*s1*s2;
disp(['Power at ', num2str(target_freq), 'Hz: ', num2str(power)]);
