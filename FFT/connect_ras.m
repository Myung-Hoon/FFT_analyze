path = 'C:/Users/chosh/OneDrive/바탕 화면/FFT/piano_music/';
filename = 'Frequency.csv';
file_path = fullfile(path, filename);

% CSV 파일에서 테이블 읽기
T = readtable(file_path);

% 두 번째 열 데이터만 추출
col_data = T{:, 2};

% 문자열로 변환
csv_str = sprintf('%.6f,', col_data);   % 각 숫자를 문자열로
csv_str = csv_str(1:end-1);             % 마지막 콤마 제거

% TCP 클라이언트 생성
pi_ip = '192.168.0.101';   % IP
pi_port = 5000;            % Raspberry Pi에서 열어둔 포트
t = tcpclient(pi_ip, pi_port);

% 문자열 전송
write(t, csv_str, 'string');  % 전송

% 연결 해제
clear t
