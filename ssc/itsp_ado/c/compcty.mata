
version 10.1
mata: mata set matastrict on
mata:
// compcty 1.0.0  CFBaum 11aug2008
void compcty(struct country scalar a, 
             struct country scalar b)
{
	real scalar poprat, gdprat,dist
	real matrix latlong
	printf("\nComparing %15s and %-15s\n\n", a.name, b.name)
	poprat = a.population / b.population
	printf("Ratio of population:     %9.2f\n", poprat)
	gdprat = a.gdppc / b.gdppc
	printf("Ratio of per capita GDP: %9.2f\n", gdprat)
	printf("\nCapital of %15s: %-15s\n Lat. %5.2f deg.  Long. %5.2f deg.\n", ///
	       a.name, a.capital, a.latlong[1] + a.latlong[2] / 100, a.latlong[3] + a.latlong[4] / 100)
	printf("\nCapital of %15s: %-15s\n Lat. %5.2f deg.  Long. %5.2f deg.\n", ///
	       b.name, b.capital, b.latlong[1] + b.latlong[2] / 100, b.latlong[3] + b.latlong[4] / 100)
// store the latitude/longitude coordinates, reversing long. signs per sphdist convention
	st_view(latlong=., ., ("lat1","long1","lat2","long2"))
	latlong[1, 1] = a.latlong[1] + a.latlong[2]/60
	latlong[1, 2] = -1 * (a.latlong[3] + a.latlong[4]/60)
	latlong[1, 3] = b.latlong[1] + b.latlong[2]/60
	latlong[1, 4] = -1 * (b.latlong[3] + b.latlong[4]/60)
	stata("capture drop __dist")
// call Bill Rising's sphdist routine to compute the distance
	stata("sphdist, gen(__dist) lat1(lat1) lon1(long1) lat2(lat2) lon2(long2)")
	st_view(dist=., .,("__dist"))
	printf("\nDistance between capitals: %9.2f km.\n",dist[1])
}
end
