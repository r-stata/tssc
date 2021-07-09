# Copyright (c) 2008 University of Illinois.  All rights reserved.
#  
# Developed by: Mark Fredrickson, Jake Bowers, and Ben Hansen
#               University of Illinois
#  
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal with the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   1. Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimers.
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimers in the
#      documentation and/or other materials provided with the distribution.
#   3. Neither the names of Mark Fredrickson, Jake Bowers, and Ben Hansen,  
#      University of Illinois, nor the names of its contributors may be used 
#      to endorse or promote products derived from this Software without 
#      specific prior written permission.
#  
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# WITH THE SOFTWARE.

ignore <- capture.output(library(RItools))

# Get the file name, which should be passed as an argument
filename = commandArgs(trailingOnly = TRUE)
##print(filename) ##only need to print filename to debug
# Load file
f <- read.csv(filename, header = TRUE)#,as.is=TRUE)

# Try a method to get factors to be valid:
##If the treatment variable had a label in Stata, and is thus understood in R as a factor, make it logical (if x has values 1 and 2, then 2=TRUE and 1=FALSE. In the output these will be shown as TRUE=1 and FALSE=0).
if(class(f[,1]) == "factor" & length(levels(f[,1])) == 2){
  ##f[,1]<-as.numeric(f[,1])-1 ##assumes that the numeric codes will be 1,2 for a two-level factor
      f[,1]<-f[,1]==levels(f[,1])[2] ##set the treatment var to TRUE aka 1 for the second of the two levels of the factor
}

# Bail out on improper treatment arguments
if(!(is.numeric(f[[1]]) || is.logical(f[[1]]))) {
	print("******************************* ERROR ***********************************")
	print("Treatement must be a numeric (continuous or binary) or a true/false value")
	print("*************************************************************************")
	quit()
}

cat("\n------------------------ Data Summary ------------------------\n")
print(summary(f))

# construct the variables
cols <- colnames(f) # we need next names to create the formula
z <- cols[1] # the first column is the treatment effect
strata <- as.formula(paste("~", cols[2])) 
covars <- tail(cols, n = length(cols) - 2) # the 3 ... n columnss are covariates

# convenience function for dealing with do.call
pluspaste <- function(...) {
  paste(sep = " + ", ...)
}

# reporting optinos
reports = c("adj.means", "adj.mean.diffs", 'z.scores', 'chisquare.test')

# make an actual formula out of the column names
fmla <- paste(z, "~", do.call(pluspaste, as.list(covars)))

# now the magic happens
cat("\n-------------- Balance Under No Stratification ---------------\n")
print(xBalance(as.formula(fmla),  data = f, report = reports))
cat("\n----------------- Balance with Stratifiation -----------------\n")
print(xBalance(as.formula(fmla), strata = list(strata = strata),  data = f, report = reports))
