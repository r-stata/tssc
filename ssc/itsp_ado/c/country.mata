
version 10.1
mata: mata set matastrict on
mata:
// country 1.0.0  CFBaum 11aug2008
struct country {
    string scalar isocode
    string scalar name
    real scalar population
    real scalar gdppc
    string scalar capital
    real vector latlong
}
end
