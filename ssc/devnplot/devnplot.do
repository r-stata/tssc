set scheme s1color 

sysuse auto, clear 
devnplot mpg
more 
devnplot mpg foreign
more 
devnplot mpg rep78
more
devnplot mpg rep78, pgap(5)
more
devnplot mpg rep78, overall
more
devnplot mpg rep78, overall pgap(3)
more
devnplot mpg rep78, overall plines
more
devnplot mpg rep78, overall plines pgap(3)
more
devnplot price foreign 
more 
devnplot price foreign, sort(weight)
more
devnplot price rep78, clean
more
devnplot price rep78, clean plines
more
devnplot mpg rep78, clean plines recast(connected)
more
devnplot mpg foreign, pgap(3) plines(lstyle(major_grid) lc(bg) lw(*8)) plotregion(color(gs15))
more 

devnplot mpg foreign rep78 
more 
devnplot mpg foreign rep78, superplines(lstyle(yxline)) plines 
more
egen median = median(mpg), by(foreign) 
devnplot mpg foreign rep78, superplines(lstyle(yxline)) level(median)
more 

webuse systolic, clear 
version 9: anova systolic drug disease drug*disease
predict predict
predict residual, residual
devnplot systolic drug disease, level(predict) superplines 
more 
devnplot residual drug disease, level(0) superplines 
more

webuse grunfeld, clear  
devnplot invest company, sort(time) clean ysc(log) yla(1000 300 100 30 10 3 1) recast(line) subtitle(Grunfeld data)

