*! version 1.2  09dec2017 Michael D Barker Felix Pöge

/*
    Testing the strdist method using direct inputs.
*/

clear all

version 10

noi di as result "Make sure that this is the correct strdist version."
which strdist
set more on
more
set more off

// Tests for empty strings
strdist "" ""
assert r(d) == 0
strdist "x" ""
assert r(d) == 1
strdist "" "x"
assert r(d) == 1
strdist "yxz" ""
assert r(d) == 3
strdist "" "yxz"
assert r(d) == 3

// Tests for equal strings
strdist "x" "x"
assert r(d) == 0
strdist "test" "test"
assert r(d) == 0

// Tests for inserts only
strdist "test" "test1"
assert r(d) == 1
strdist "test" "te1st"
assert r(d) == 1
strdist "test" "1test2"
assert r(d) == 2
strdist "test" "xxtyxexysyyxctc"
assert r(d) == 11

// Tests for deletes only
strdist "test1" "test"
assert r(d) == 1
strdist "te1st" "test"
assert r(d) == 1
strdist "1test2" "test"
assert r(d) == 2
strdist "xxtyxexysyyxctc" "test"
assert r(d) == 11

// Tests for substitutions only
strdist "x" "y"
assert r(d) == 1
strdist "vx" "vy"
assert r(d) == 1
strdist "xv" "yv"
assert r(d) == 1
strdist "vxm" "vym"
assert r(d) == 1

// Tests for multiple operations at the same time
strdist "example" "samples"
assert r(d) == 3
strdist "sturgeon" "urgently"
assert r(d) == 6
strdist "levenshtein" "frankenstein"
assert r(d) == 6
strdist "distance" "difference"
assert r(d) == 5

// Testing all the cases again, but this time with variables instead of direct inputs.
// Also, test the usage of gen
clear
 input str20 x str20 y target
 "" "" 0
 "x" "" 1
 "" "x" 1
 "yxz" "" 3
 "" "yxz" 3
 "x" "x" 0
 "test" "test" 0
 "test" "test1" 1
 "test" "te1st" 1
 "test" "1test2" 2
 "test" "xxtyxexysyyxctc" 11
 "test1" "test" 1
 "te1st" "test" 1
 "1test2" "test" 2
 "xxtyxexysyyxctc" "test" 11
 "x" "y" 1
 "vx" "vy" 1
 "xv" "yv" 1
 "vxm" "vym" 1
 "example" "samples" 3
 "sturgeon" "urgently" 6
 "levenshtein" "frankenstein" 6
 "distance" "difference" 5
 end
strdist x y, gen(test_strdist)
assert target == test_strdist
drop test_strdist

/*
    Testing the same cases again with one part variable, one part string.
    Also, test the usage of if and in.
*/
count
noi di as text "Case: " _c
forvalues i = 1/`=r(N)' {
    local to_test = x[`i']
    strdist "`to_test'" y in `i'
    assert strdist == target in `i'
    drop strdist 
    local to_test = y[`i']
    strdist x "`to_test'" if _n == `i'
    assert strdist == target | _n != `i'
    drop strdist 
    noi di as text "`i' " _c
}


/*
	Testing maximum string lengths
*/
clear
set obs 1
qui gen x = ""
qui gen y = ""
forvalues i = 1/100 {
	qui replace x = x + " a"
	qui replace y = y + " v"
}
strdist x y
assert strdist == 100
drop strdist

strdist x y, maxdist(100)
assert strdist == 100
drop strdist

strdist x y, maxdist(0)
assert strdist == 100
drop strdist

strdist x y, maxdist(-1)
assert strdist == 100
drop strdist

strdist x y, maxdist(1)
assert missing(strdist)
drop strdist

strdist x y, maxdist(99)
assert missing(strdist)
drop strdist

strdist x y, maxdist(10)
assert missing(strdist)
drop strdist

// This here checks the first way strdist reacts to maxdist
// - if the distance between the string lengths is already too large to
// satisfy maxdist
gen a = "abc"
gen b = "abcdef"
strdist a b
assert strdist == 3
drop strdist

strdist a b, max(2)
assert missing(strdist)
drop strdist

// These used to give some faulty behavior
strdist "x" "yav", maxdist(1)
assert r(d) == .

strdist "mx" "yavz", maxdist(1)
assert r(d) == .

strdist "mx" "yavz", maxdist(2)
assert r(d) == .

strdist "yav" "x", maxdist(1)
assert r(d) == .

strdist "yavz" "mx", maxdist(1)
assert r(d) == .

strdist "yavz" "mx", maxdist(2)
assert r(d) == .

// Testing compatibility with several ascii examples
forvalues i = 1/255 {
    quietly {
        // These do not work for Stata reasons (Characters $ and `).
        // They are tested below.
        if inlist(`i', 36, 96) {    
            continue
        }
        noi di as text char(`i') _c
        cap {
            noi di as text char(`i') _c
            strdist `""' `"`=char(`i')'"'
            assert r(d) == 1
            strdist `"`=char(`i')'"' `""'
            assert r(d) == 1
            strdist `"test"' `"test`=char(`i')'"'
            assert r(d) == 1
            strdist `"test`=char(`i')'"' `"test`=char(`i')'"'
            assert r(d) == 0
            strdist `"`=char(`i')'test`=char(`i')'"' `"te`=char(`i')'st"'
            assert r(d) == 3
            strdist `"test`=char(`=`i'+1')'"' `"test`=char(`i')'"'
            assert r(d) == 1
        }
        if _rc == 9 {
            noi di as error _n "Failed for `i' (`=char(`i')')."
            error 9
        }
    }
}

// Testing $ and `
strdist "" "$"
assert r(d) == 1
strdist "$" ""
assert r(d) == 1
// ` cannot be directly put as a string, hence it is here tested using a variable
clear
set obs 1
gen x = ""
replace x = char(96) in 1
strdist "a" x
assert strdist == 1
drop strdist
strdist x "a"
assert strdist == 1
clear

/*************************************************************************************
    ALL TESTS SUCCESSFUL
*************************************************************************************/
