* Example of "r_ml_stata"
* 20 August 2020
* Giovanni Cerulli,IRCrES-CNR

cd"/Users/giocer/Dropbox/Stata_Python/c_r_ml_stata_for_SSC_20_08_2020/r_ml_stata_for_SSC_20_08_2020/Example_r_ml_stata"

use "r_ml_stata_data_example.dta"

h r_ml_stata

r_ml_stata y x1-x13 , mlmodel(nearestneighbor) in_prediction("in_pred") cross_validation("CV") ///
out_sample("r_ml_stata_data_new_example") out_prediction("out_pred") seed(10) save_graph_cv("graph_cv")
