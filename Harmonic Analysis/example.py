# -*- coding: utf-8 -*-

import Tides
import dateutil
import datetime
import numpy as np
from getData import get_variables
import matplotlib.pyplot as plt

#�ȶ���һ��������ͼ�ĺ���
def show_diff(original, predict):
	fig, axes = plt.subplots(figsize=(18,4))
	axes.plot(original, 'b', lw=2)
	axes.plot(predict, 'r', lw = 0.5)
	axes.set_title('Diff between real data and predicted')
	axes.legend(["real", "predicted"])
	plt.show()

#��������
date = dateutil.parser.parse('21/09/2014 1:20:30.000 PM')
middle_date = (date + datetime.timedelta(hours = 371) - datetime.timedelta(hours=8)).ctime()
#��������
zeta = np.loadtxt('Zeta.txt')
#��λת���ɺ���
zeta = zeta * 1000
#�����м�ʱ�̣���������Ҫ��
P, Q, sigma, V, f, kappa, alpha, corr, mask, record = get_variables(middle_date)
#���е��ͷ�����������ͳ���
H, g, S_0 = Tides.analyze(P, zeta, sigma, V, f, kappa, alpha, corr)
#������ͳ������лر�
zeta_predict = Tides.predict(-172, 172, sigma, V, f, H, g, S_0, mask, 1.)
#�ر�����ӵĳ�λ���Լ���ߵͳ�ʱ�ͳ���
zeta_predict_minute = Tides.predict(-172*60, 172*60, sigma, V, f, H, g, S_0, mask, 1./60.)
#ͬͼ���ƻر�����������ʵ���������
show_diff(zeta, zeta_predict);
#����ر��Ĺ�����������ʵ����ֵ�����ϵ����������ֵ�൱�ӽ�1��˵���ر������ȷ
print '���ϵ����%.5f' % plt.xcorr(zeta, zeta_predict, maxlags=1)[1][1]
print 'ƽ�����棺%.2fmm' % S_0
print '�ֳ������Ӧ��H��g��'
for k in record.keys():
    print '�ֳ�����: %s\t\t���: %.2fmm\t\t�ٽ�: %.2frad' % (record[k], H[k-1], g[k-1])

    
def print_max_min(data, time):
    ssum1 = 0.
    ssum2 = 0.
    num1 = 0
    num2 = 0
    t = dateutil.parser.parse(time)
    for i in range(1, data.size - 1):
        if data[i] > data[i - 1] and data[i] > data[i + 1]:
            print '�߳�ʱ: %s\t��λ:%dmm' % ( (t + datetime.timedelta(minutes=i)).strftime('%c'), data[i] )
            ssum1 += data[i]
            num1 += 1
        elif data[i] < data[i - 1] and data[i] < data[i + 1]:
            print '�ͳ�ʱ: %s\t��λ:%dmm' % ( (t + datetime.timedelta(minutes=i)).strftime('%c'), data[i] )
            ssum2 += data[i]
            num2 += 1
    print 'ƽ�����%.2fmm' % ( ssum1 / float(num1) - ssum2 / float(num2)  )

print_max_min(zeta_predict_minute, '14/09/2014 9:20:30.000 AM')
fig, axes = plt.subplots(figsize=(18,4))
axes.plot(zeta - zeta_predict);
axes.set_title('Residual water level')
plt.show();