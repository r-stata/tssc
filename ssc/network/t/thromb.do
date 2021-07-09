// Analysis of thrombolytics data to demonstrate -network- suite

* Load the thrombolytics data

use thromb, clear

network setup r n, studyvar(study) trtvar(trt)

network map

* Fit consistency and inconsistency models 

network convert augment
network meta c
network meta i

* Graphs of results

network forest, name(throm_forest, replace) xtitle(Log odds ratio and 95% CI) ///
    title(Thrombolytics network) msym(Sh) contrastopt(mlabsize(small))

* Explore inconsistency by side-splitting

network sidesplit all

