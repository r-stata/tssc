program gpscore_model
version 10.0

args lnf mu sigma

quietly replace `lnf' = ln(normalden($ML_y1, `mu', `sigma'))

end
