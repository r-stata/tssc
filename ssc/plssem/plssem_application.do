*!Written 01Oct2017
*!Written by Sergio Venturini and Mehmet Mehmetoglu
*!The following code is distributed under GNU General Public License version 3 (GPL-3)

* Section 4 - Empirical application
* Model estimation
use ./data/workout2, clear
plssem (Attractive > face sexy) ///
			 (Appearance > body appear attract) ///
			 (Muscle > muscle strength endur) ///
			 (Weight > lweight calories cweight), ///
			 structural(Appearance Attractive, ///
	                Muscle Appearance, ///
	                Weight Appearance) ///
	     boot(200) seed(123) stats correlate(lv)

estat indirect, effects(Muscle Appearance Attractive, ///
                        Weight Appearance Attractive) ///
								boot(200) seed(456)

plssemplot, loadings

* Stored results
ereturn list

* Multigroup analysis
plssem (Attractive > face sexy) ///
			 (Appearance > body appear attract) ///
			 (Muscle > muscle strength endur) ///
			 (Weight > lweight calories cweight), ///
			 structural(Appearance Attractive, ///
									Muscle Appearance, ///
									Weight Appearance) ///
			 group(women, reps(200) groupseed(123) method(bootstrap) alpha(.1) plot)
