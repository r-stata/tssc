// Apr  2 2014
// Brendan Halpin brendan.halpin@ul.ie

/* This file runs through most of the functionality of the SADI package
for Stata, to demonstrate some of its uses. 

It uses the McVicar/Anyadike-Danes data, representing 72 months of the
labour market history of young people in Northern Ireland. Thanks guys.

Duncan McVicar and Michael Anyadike-Danes (2002), Predicting Successful
and Unsuccessful Transitions from School to Work Using Sequence Methods,
Journal of the Royal Statistical Society (Series A), 165, pp317-334.

*/


use http://teaching.sociology.ul.ie/bhalpin/mvad

sort id

// Use the substitution matrix from the MVAD paper
#delimit ;
matrix mvdanes = (0,1,1,2,1,3 \
                  1,0,1,2,1,3 \
                  1,1,0,2,1,2 \
                  2,2,2,0,1,1 \
                  1,1,1,1,0,2 \
                  3,3,2,1,2,0 );
#delimit cr

set matsize 4000

// Get pairwise distance matrices for a range of different distance measures

oma        state1-state72, subsmat(mvdanes) pwd(omd) length(72) indel(1.5)
omav       state1-state72, subsmat(mvdanes) pwd(omv) length(72) indel(1.5)
hollister  state1-state72, subsmat(mvdanes) pwd(hol) length(72) timecost(0.5) localcost(0.5)
twed       state1-state72, subsmat(mvdanes) pwd(twd) length(72) lambda(0.5) nu(0.04) 
hamming    state1-state72, subsmat(mvdanes) pwd(ham) 
dynhamming state1-state72,                  pwd(dyn) 

// Prepare the data in X/t spell format and get duration-weighted combinatorial (Elzinga) distance:
preserve
combinprep, state(state) length(len) idvar(id) nsp(nspells)
local spmax = r(maxspells)
combinadd state1-len`spmax', pwsim(xts) nspells(nspells) nstates(6) rtype(d)
restore

// Rather than use MVAD's substitution matrix, generate one from transition probabilities
// Note the one without the diagonal has more variation
preserve
reshape long state, i(id) j(m)
trans2subs state, id(id) subs(tpr1)
matrix list tpr1
trans2subs state, id(id) subs(tpr2) diag
matrix list tpr2
restore

// Get OMA distance with the transition probability substitution matrix
oma        state1-state72, subsmat(tpr1) pwd(tpr) length(72) indel(1.5)


// Compare all distance matrices with OMA
// corrsqm with the nodiag option gives the correlation between the distances
// between all pairs, excluding the zero distances on the diagonal
foreach dist in dyn ham twd hol omv xts tpr {
  corrsqm omd `dist', nodiag
}

// Test all the distance matrices to ensure they obey the triangle inequality
// (omv and hol do not)

foreach dist in dyn ham twd hol omv xts tpr {
  metricp `dist'
}

// Do cluster analysis on OMA and TWED distances
// Generate 8 and 12 cluster solutions for each
clustermat wards omd, name(oma) add
cluster generate o=groups(8 12)

clustermat wards twd, name(twd) add
cluster generate t=groups(8 12)

// Compare clusterings using Adjusted Rand Index
ari o8 t8

// Compare clusterings using permtab
// gen(pt8) creates a permuted version of t8 so that it matches o8
// as closely as possible

permtab o8 t8, gen(pt8)
tab o8 pt8

// For 12 clusters, permutation takes 9*10*11*12=11880 times as long as for 8
// To deal with this, permtabga yields an approximate-best permutation using
// a genetic algorithm
permtabga o12 t12, gen(pt18)

// Studer et al's discrepancy measure
// See M Studer, G Ritschard, A Gabadinho and NS Müller, Discrepancy
//  analysis of state sequences, Sociological Methods and Research,
//  40(3):471-510

discrepancy o8, dist(omd) id(id)
discrepancy o12, dist(omd) id(id)
discrepancy grammar, dist(omd) id(id)
discrepancy grammar, dist(omd) id(id) niter(1000)

// Descriptive summaries of sequences

//  - string representation of sequences
stripe state1-state72, gen(seqstr) symbols("EFHSTU")
list seqstr in 1/5, clean

// Use discrepancy to identify medoids
discrepancy o8, dist(omd) id(id) dcg(dx)
sort o8 dx
by o8: gen medoid = _n==1
list o8 dx seqstr if medoid, clean
sort id

// - cumulated duration in each state
cumuldur state1-state72, cd(dur) nstates(6)

su dur*
table o8, c(mean dur1 mean dur2 mean dur3) format(%5.2f)
table o8, c(mean dur4 mean dur5 mean dur6) format(%5.2f)

drop dur1-dur6

// - entropy: A simple measure of Shannon entropy
entropy state1-state72, gen(ent) cd(dur) nstates(6)
table o8, c(mean ent)

// - nspells, number of spells
nspells state1-state72, gen(nsp)
tab nsp

// Graphics

// 1: Chronogram

chronogram state*, id(id) by(o8, legend(off)) name(chronogram, replace)

// 2: indexplot (uses sqindexplot from SQOM package)

//    Generate a maximal clustering (as many clusters as distinct sequences)
//    This allows us to order sequences within clusters such that 
//    subcluster-structure is preserved
cluster generate o999 = groups(750), name(oma) ties(fewer)

// Reshape long and register it as an SQ-structured data set
preserve
reshape long state, i(id) j(m)
sqset state id m
sqindexplot, by(o8, note("") legend(off)) order(o999) name(indexplot, replace)
restore

// 3: Transition pattern
trprgr state*, id(id) gmax(485)

// A matrix of transition rates: maketrpr generates the matrix of transition rates
// that is used by dynhamming and trprgr, using tssmooth to average over a moving
// window of successive transitions. 

maketrpr state*, mat(mkt) ma(5)

matlist mkt[1..6,.]
matlist mkt[25..30,.]

