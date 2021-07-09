// Analysis of smoking data to demonstrate -network- suite
// Commands as in help file

* Load the smoking data

use smoking, clear

network setup d n, studyvar(stud) trtvar(trt) 

* Draw a network graph using networkplot if installed

network map

* Fit consistency model

network meta c

* Rank treatments, noting that larger treatment effects indicate better treatments

network rank max

* Fit inconsistency model

network meta i

* Forest plot of results, adding a title and reducing the square size from its default of *0.2

network forest, title(Smoking network) msize(*0.15) 

* Explore inconsistency by side-splitting

network sidesplit all



