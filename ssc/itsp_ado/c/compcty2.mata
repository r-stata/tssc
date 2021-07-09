
version 10.1
mata: mata set matastrict on
mata:
real scalar deg2rad(real scalar deg)
{
	return(deg * pi() / 180)
}

// compcty2 1.0.0  CFBaum 11aug2008
void compcty2(struct country scalar a, struct country scalar b)
{
	real scalar poprat, gdprat, lat1, lat2, lon1, lon2, costhet, res
	printf("\nComparing %15s and %-15s\n\n", a.name, b.name)
	poprat = a.population / b.population
	printf("Ratio of population:     %9.2f\n", poprat)
	gdprat = a.gdppc / b.gdppc
	printf("Ratio of per capita GDP: %9.2f\n", gdprat)
	printf("\nCapital of %15s: %-15s\n Lat. %5.2f deg.  Long. %5.2f deg.\n", ///
	       a.name, a.capital, a.latlong[1] +  a.latlong[2] / 100, a.latlong[3] + a.latlong[4] /100)
	printf("\nCapital of %15s: %-15s\n Lat. %5.2f deg.  Long. %5.2f deg.\n", ///
	       b.name, b.capital, b.latlong[1] + b.latlong[2] / 100, b.latlong[3] + b.latlong[4] / 100)
// convert the latitude/longitude coordinates to radians
	lat1 = deg2rad(a.latlong[1] + a.latlong[2]/60)
	lon1 = deg2rad(a.latlong[3] + a.latlong[4]/60)
	lat2 = deg2rad(b.latlong[1] + b.latlong[2]/60)
	lon2 = deg2rad(b.latlong[3] + b.latlong[4]/60)
	costhet = sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1)
	if (costhet == 1 | (lat1 == lat2 & lon1 == lon2)) {
		res = 0
	}
	else if (costhet == 1) {
		res = 20000
	}
	else {
		res = (pi() / 2 - atan(costhet / sqrt(1 - costhet^2))) * 20000 / pi()
	}
	printf("\nDistance between capitals: %9.2f km.\n",res)
}
end
