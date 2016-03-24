clear; clc; close all;

load 016023_20140929_1110ZZZZ(w).mat;
dat = RBR.data(:, 3);
start = max(find(abs(dat(1:int32(size(dat, 1)/2))) < 1));
fin = min(find(abs(dat(int32(size(dat, 1)/2) + 1:end)) < 1)) + int32(size(dat, 1)/2);
% ��ȡ��ʼ�ͽ���λ��
dat = dat(start + 1:fin - 1);
% ��ȡʱ��
times = RBR.sampletimes(start + 1:fin - 1);

calc_dat = dat(1:120:end);
calc_time = times(1:120:end);
% ��ʾ�м�ʱ��
disp(calc_time((size(calc_time, 1) + 1) / 2))
% ��ʾ��ʼʱ��
disp(calc_time(1))

save('Zeta.txt', 'calc_dat', '-ascii');