
version 10.1
mata:
function myvecsub(struct myvecstr scalar e)
{
	real scalar dist_from_origin, xx, yy, ll, ang
	string scalar clr
	xx = e.pt.coords[1]
 	yy = e.pt.coords[2]
	dist_from_origin = sqrt(xx^2 + yy^2)
 	printf("\n The %s vector begins %7.2f units from the origin at (%f, %f)", ///
 	       e.color, dist_from_origin, xx, yy)
 	printf("\n It is %7.2f units long, at an angle of %5.2f degrees\n", e.length, e.angle)
}
end
