* Example of "c_ml_stata"
* 20 August 2020
* Giovanni Cerulli,IRCrES-CNR

cd "/Users/giocer/Dropbox/Stata_Python/c_r_ml_stata_for_SSC_20_08_2020/c_ml_stata_for_SSC_20_08_2020/Example_c_ml_stata"

use "c_ml_stata_data_example.dta"

h c_ml_stata

c_ml_stata y x1-x4 , mlmodel(tree) in_prediction("in_pred") cross_validation("CV") ///
out_sample("c_ml_stata_data_new_example") out_prediction("out_pred") seed(10) save_graph_cv("graph_cv")
