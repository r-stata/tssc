// This do file contains all the examples from the spmat suite

clear all
set more off

mata mata mlib index

// spreg

capture spmat drop cobj
use pollute
spmat use cobj using pollute.spmat
spreg ml pollution factories area, id(id) dlmat(cobj) elmat(cobj)
spreg gs2sls pollution factories area, id(id) dlmat(cobj) elmat(cobj)

// spreg postestimation

capture spmat drop cobj
use pollute
spmat use cobj using pollute.spmat
spreg ml pollution factories area, id(id) dlmat(cobj) elmat(cobj)
predict y0
replace factories = factories+1 in 50
predict y1
gen deltay = abs(y1-y0)
count if deltay!=0

// spivreg

capture spmat drop cobj
clear
use pollute
spmat use cobj using pollute.spmat
spivreg pollution area (factories = penalties), id(id) dlmat(cobj) elmat(cobj)

// spivreg postestimation

capture spmat drop cobj
use pollute
spmat use cobj using pollute.spmat
spivreg pollution area (factories = penalties), id(id) dlmat(cobj) elmat(cobj)
predict yhat

// spmat contiguity

clear all
use pollute
spmat contiguity cobj using pollutexy, id(id) normalize(minmax)
*spmat eigenvalues cobj
*spmat save cobj using pollute.spmat, replace

// spmat idistance
use pollute
spmat idistance dobj longitude latitude, id(id) dfunction(dhaversine)

// spmat summarize

capture spmat drop cobj
spmat use cobj using pollute.spmat
spmat summarize cobj, links

// spmat note

capture spmat drop cobj
spmat use cobj using pollute.spmat
spmat note cobj: "Simulated data for spmat"
spmat note cobj
spmat note cobj: "- queen contiguity"
spmat note cobj
spmat note cobj: `"Is this "queen" contiguity?"', replace
spmat note cobj
spmat note cobj drop

// spmat graph

capture spmat drop cobj
spmat use cobj using pollute.spmat
spmat graph cobj, blocks(5) name(cobj)

// spmat lag

capture spmat drop cobj
clear
use pollute
spmat use cobj using pollute.spmat
spmat lag double pollution_w cobj pollution

// spmat eigenvalues

capture spmat drop cobj
clear
spmat use cobj using pollute.spmat
spmat eigenvalues cobj

// spmat drop

capture spmat drop cobj
spmat use cobj using pollute.spmat
spmat drop cobj

// spmat save

clear all
capture erase cobj.spmat
use pollute
spmat contiguity cobj using pollutexy, id(id) normalize(minmax)
spmat save cobj using cobj.spmat
erase cobj.spmat

// spmat export

capture spmat drop cobj
capture erase cobj.txt
spmat use cobj using pollute.spmat
spmat export cobj using cobj.txt
erase cobj.txt

// spmat getmatrix

capture spmat drop cobj
spmat use cobj using pollute.spmat
spmat getmatrix cobj mymat
spmat getmatrix cobj, eig(myeig)

// spmat use

clear all
capture erase cobj.spmat
use pollute
spmat contiguity cobj using pollutexy, id(id) normalize(minmax)
spmat save cobj using cobj.spmat
spmat drop cobj
spmat use cobj using cobj.spmat
erase cobj.spmat

// spmat import

capture spmat drop cobj
capture erase cobj.txt
clear all
use pollute
spmat contiguity cobj using pollutexy, id(id) normalize(minmax)
spmat export cobj using cobj.txt
spmat drop cobj
spmat import cobj using cobj.txt
erase cobj.txt

// spmat dta

capture spmat drop cobj
capture erase cobj.txt
clear 
spmat use cobj using pollute.spmat
spmat export cobj using cobj.txt
spmat drop cobj
insheet using cobj.txt, delimiter(" ") clear
rename v1 id
spmat dta cobj v*, id(id) replace
erase cobj.txt

// spmat putmatrix

capture spmat drop cobj
spmat use cobj using pollute.spmat
spmat getmatrix cobj mymat, id(myid)
spmat drop cobj
spmat putmatrix cobj mymat, id(myid)

// spmat permute

clear
use pollute
capture spmat drop cobj
spmat use cobj using pollute.spmat
spmat summarize cobj

gen p = _n
sort longitude latitude
gen dist = sqrt( (longitude-longitude[1])^2 + (latitude-latitude[1])^2 )
sort dist

spmat permute cobj p

spmat summarize cobj, banded
if `r(canband)'==1 spmat tobanded cobj, dtr(`r(lband)' `r(uband)') replace
spmat summarize cobj

// spmat tobanded

capture spmat drop cobj
clear
use pollute
sort longitude latitude
spmat contiguity cobj using pollutexy, id(id) norm(minmax)
spmat summarize cobj, links
spmat tobanded cobj, replace
spmat summarize cobj, links

clear all
