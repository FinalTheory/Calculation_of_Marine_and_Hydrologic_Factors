Calculation of Marine and Hydrologic Factors
============================================



## 一、[潮汐的最小二乘调和分析](http://nbviewer.jupyter.org/github/FinalTheory/oceanography-numerical-calculations/blob/master/Harmonic%20Analysis/HomeWork1.ipynb)

- 基于Fortran与Python的混合编程
- 使用Numpy的Array对象作为通用的数据存储容器
- 在IPython Notebook上完成基本程序的编写和编译
- 最后输出为ipynb文件，方便各种共享以及重现结果
- 所有涉及的数据文件和代码均可以从该Repo中获取，也可以直接打包下载


## 二、[北太平洋海区SST数据的EOF分解以及分析](http://nbviewer.jupyter.org/github/FinalTheory/oceanography-numerical-calculations/blob/master/EOF%20Analysis/HomeWork2.ipynb)

- 使用Basemap绘图库完成作图
- 分析写得相当水，还请见谅
- 使用eofs工具进行EOF分解，效率更高；在做大规模计算时，相对与matlab程序可以减少一半的内存占用，节省十倍的时间

## 三、二维潮波数值模拟程序

- 使用Fortran语言完成命令行运算程序的编写
- 该运算核心接受17个输入参数，用以决定是否忽略运动方程中的某些项，以及各个系数的取值等
- 使用Python的Tkinter模块编写图形界面，用numpy读取并处理数据，并与MatPlotLib进行整合以实现绘图、动画等功能
- 运行效果如下：
<img src="https://github.com/FinalTheory/oceanography-numerical-calculations/raw/master/Numerical%20Simulation/demonstration.gif" width=1130>

## 四、二维潮波伴随同化模型
