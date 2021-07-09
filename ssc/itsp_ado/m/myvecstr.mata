
mata: mata clear
mata: mata set matastrict on

version 10.1
mata:
struct mypoint {
        real vector coords
}

struct myvecstr {
        struct mypoint scalar pt
        real scalar length, angle
        string scalar color
}
end
