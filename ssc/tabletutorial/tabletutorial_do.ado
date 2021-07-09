*! version 1.0.1  17nov2008  Ben Jann
prog def tabletutorial_do
    version 8.2
    qui findfile `0'
    set more off
    do `"`r(fn)'"'
end
