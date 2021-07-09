
version 10.1
mata: mata set matastrict on
mata:
// loadcty 1.0.0  CFBaum 11aug2008
pointer(real scalar) loadcty(
                     string scalar isocode,
                     string scalar name,
                     real scalar population,
                     real scalar gdppc,
                     string scalar capital,
                     real scalar latitudeD,
                     real scalar latitudeM,
                     real scalar longitudeD,
                     real scalar longitudeM ) 
{
	struct country scalar c
	c.isocode = isocode
	c.name = name
	c.population = population
	c.gdppc = gdppc
	c.capital = capital
	c.latlong = (latitudeD, latitudeM, longitudeD, longitudeM)
	return(&c)	
}
end
