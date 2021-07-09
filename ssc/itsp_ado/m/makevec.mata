
version 10.1
mata:
function makevec(real scalar xcoord, 
                 real scalar ycoord,
                 real scalar len,
                 real scalar ang,
                 string scalar color)
{
    struct myvecstr scalar v
    v.pt.coords = (xcoord, ycoord)
    v.length = len
    v.angle = ang
    v.color = color
    myvecsub(v)
}
end


