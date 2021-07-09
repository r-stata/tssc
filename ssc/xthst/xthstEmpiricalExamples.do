clear

adopath + "C:\Users\\`c(username)'\\Dropbox (Heriot-Watt University Team)\Ditzen\Research\StataCode\xthst\ado"
cap program drop xthst

use "C:\Users\\`c(username)'\\Dropbox (Heriot-Watt University Team)\Ditzen\Research\StataCode\xthst\examples\xthst_sample_dataset.dta"

xtset

*** simple solow type growth model
xthst d.log_rgdp log_hc log_ck log_ngd
*** test indicates heterogenous slopes

*** test with log_rgdpo as an ar(1)
xthst d.log_rgdp L.d.log_rgdp
*** test indicates heterogenous slopes

*** test as an ARDL(1,0) model
xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd

*** serial correlation likely. Use Blomquist, Westerlund (2013)
xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd, hac 

** change bandwith and use qs-kernel
xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd, hac bw(5) kernel(qs)

*** cross-sectional dependence is possible (see xtcd2), so check if result from ARDL(1,0) model changes. Use base of variables and use only 2 lags for the dependent variable, 3 lags for the rest
xthst d.log_rgdp L.d.log_rgdp log_hc log_ck log_ngd , cr(d.log_rgdp log_hc log_ck log_ngd, cr_lags(2 3))

*** AR model
xthst d.log_rgdp L.d.log_rgdp , ar