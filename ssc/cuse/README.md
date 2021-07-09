cuse<img src="https://czxa.github.io/cuse/assets/cuse-fit.png" align="right" />
========================================================
[![](https://img.shields.io/badge/build-passing-brightgreen.svg?style=plastic)](https:czxa.top) [![](https://img.shields.io/badge/Stata-cuse-brightgreen.svg?style=plastic)](https://czxa.top) [![](https://img.shields.io/badge/github-Stata-orange.svg?style=plastic)](https://czxa.top) [![](https://img.shields.io/badge/platform-Windows_OS|Mac_OS-orange.svg?style=plastic)](https://czxa.top)

cuse 命令通过使用必应词典和有道翻译的接口实现了在Stata中进行中英文单词、词语和句子的互译。

安装
--------

Stata 提供了一种安装外部命令的基础命令：`net install`，你可以在 Stata 的命令输出窗口输入下面的命令安装 `cuse` 命令：

```py
net install cuse, from("https://czxa.github.io/cuse/")
```

推荐使用 [E. F. Haghish](https://github.com/haghish) 开发的 [github](https://github.com/haghish/github) 命令安装：

首先你需要安装github命令：

```stata
net install github, from("https://haghish.github.io/github/")
```

然后就可以安装这个命令了：

```stata
github install czxa/cuse, replace
```

帮助文档
--------

[CUSE：构建自己的Stata 数据集仓库.PDF](https://czxa.github.io/cuse/cuse-paper/cuse.pdf)

用法
--------

> cuse ["]filename["] [, <u>c</u>lear <u>w</u>eb <u>s</u>avetosystem]

* filename：是你想要调用的数据集名称，例如上面的grilic_small。

--------

1. <u>c</u>lear：可以简写为c。使用该选项时会先清空已有数据集再读入。
2. <u>w</u>eb：可以简写w。使用该选项时表示从GitHub 上读取数据。
3. <u>s</u>avetosystem：可以简写s。使用该选项时表示读入数据集后把该数据集存放在系统文件夹里。
选项


示例
--------

从本地文件夹读取 `ctbc2.dta` 数据集（只有我自己能使用）：

```stata
cuse ctbc2, clear
*> (2002年-2018年中债国债到期收益率)
```

从 GitHub 上读取 `ctbc2.dta` 数据集：

```stata
cuse ctbc2, clear web
*> (2002年-2018年中债国债到期收益率)
```

查看当前数据集仓库中的所有可用数据：

```stata
cuselist
*> 【0】
*> ----------------------------------------------------------------------
*> 1. 000001.dta: 平安银行历史股票数据
*> 【a】
*> ----------------------------------------------------------------------
*> 1. amricancellmapdata.dta: 美国蜂窝地图各个省份的位置坐标
*> 【c】
*> ----------------------------------------------------------------------
*> 1. cellmapdata.dta: 中国蜂窝地图各个省份的位置坐标
*> 1. countycode.dta: 中国各省市区县编号(即身份证前六位号码)
······（此处省略了一些代码结果）
*> 【书籍数据集】
*> 注意！如果你想调用的数据集的名字里含大写字母，你需要把它的首字母调成小写才能调用!
*> 1. 《计量经济学及Stata应用》——陈强著
*> 2. 《高级计量经济学及Stata应用》——陈强著
*> 3. 《An Introduction to Stata Programming, Second Edition》——Christopher F. Baum著
```


致谢
-----

> HAGHISH E F. github: a module for building, searching, installing, managing, and mining stata packages from github[EB/OL].
https://github.com/haghish/github.

> MITCHELL M N, 2012. A visual guide to stata graphics[M/OL]. 3rd edition ed. Stata Press. https://www.stata-press.com/data/vgsg3.html.


------------

<h4 align="center">

License

</h4>

<h6 align="center">

MIT © czxa.top

</h6>
