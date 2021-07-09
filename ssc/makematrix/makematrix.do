sysuse auto, clear 
makematrix, from(r(rho)) : spearman head trunk length displacement weight
makematrix, from(r(rho)) format(%4.3f) : spearman head trunk length displacement weight
pca head trunk length displacement weight
score score1-score5
makematrix, from(r(rho)) cols(score?) : correlate head trunk length displacement weight
makematrix R, from(r(rho)) cols(score?) : correlate head trunk length displacement weight
matrix colnames R = "score 1" "score 2" "score 3" "score 4" "score 5"
matrix li R, format(%4.3f) 
makematrix , from(r(rho) r(p)) label cols(price) : spearman mpg-foreign
makematrix , from(r(rho) r(p)) list label format(%4.3f %6.5f) sep(0) cols(price) : spearman mpg-foreign
makematrix, from(r(mean) r(sd) r(skewness)) : su head trunk length displacement weight, detail
makematrix, from(r(mean) r(sd) r(skewness)) list format(%2.1f %2.1f %4.3f) sep(0) : su head trunk length displacement weight, detail
makematrix, from(r(rho) r(p)) lhs(rep78-foreign) : spearman mpg
makematrix, from(r(rho) r(p)) rhs(rep78-foreign) : spearman mpg
makematrix, from(e(r2) e(rmse) _b[_cons] _b[mpg]) lhs(rep78-foreign) : regress mpg
makematrix, from(e(r2) e(rmse) _b[_cons] _b[mpg]) lhs(rep78-foreign) list dp(3 2 2 3) abb(9) sep(0) divider : regress mpg
makematrix, from(e(r2) e(rmse) _b[_cons] _b) rhs(rep78-foreign) : regress mpg
makematrix, from(e(r2) e(rmse) _b[_cons] _b) rhs(rep78-foreign) list dp(3 2 2 3) abb(9) sep(0) divider : regress mpg
gen weightsq = weight^2
makematrix, from(e(r2) e(rmse)) lhs(mpg-trunk length-foreign) : regress weight weightsq
makematrix, from(e(r2) e(rmse)) lhs(mpg-trunk length-foreign) list dp(3 2) sep(0) divider : regress weight weightsq
makematrix, from(r(sum)) vector: su head trunk length displacement weight, meanonly

