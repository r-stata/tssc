version 14.2

cscript colrspace adofile colrspace_source.sthlp

mata:
void virtuallyequal(real matrix A, real matrix B) almostequal(A, B, 1e-15)
void almostequal(real matrix A, real matrix B, real scalar tol) {
    assert(mreldif(A, B) <= tol)
}
end

/*----------------------------------------------------------------------------*/
// Check consistency of string input: S.colors()/S.Colors()

set seed 4723098
mata:
RGB = (26, 71, 111) \ (144, 53, 59) \ (0, 0, 128) \ (128, 0, 0)
rgb = "26 71 111" \ "144 53 59" \ "0 0 128" \ "128 0 0"
S = ColrSpace()
S.set(RGB)
assert(S.Colors()==rgb)
// named colors
colors = "navy" \ "maroon" \ "Navy" \ "Maroon"
test   = rgb
// HEX
colors = colors \ S.get("HEX")
test = test \ rgb
// RGB (no tag)
C = S.get("RGB")
for (i=1;i<=4;i++) colors = colors \ invtokens(strofreal(C[i,]))
test = test \ rgb
// CMYK (no tag)
C = S.get("CMYK")
for (i=1;i<=4;i++) colors = colors \ invtokens(strofreal(C[i,]))
test = test \ rgb
// CMYK1 (no tag)
C = S.get("CMYK1")
for (i=1;i<=4;i++) colors = colors \ invtokens(strofreal(C[i,]))
test = test \ rgb
end
// various spaces
local spaces CMYK CMYK1 HSL HSV RGB RGB1 lRGB XYZ XYZ1 xyY xyY1 Lab Luv CAM02 JMh Jab 
foreach a in J Q {
    foreach b in C M s {
        foreach c in h H {
            local spaces `spaces' "CAM02 `a'`b'`c'"
        }
    }
}
foreach a in UCS LCD SCD "1.10 .008 .02"{
    local spaces `spaces' "JMh `a'" "Jab `a'"
}
mata:
spaces = tokens(st_local("spaces"))
spaces
for (j=1; j<=length(spaces); j++) {
    space = spaces[j]
    C = S.get(space)
    for (i=1;i<=4;i++) colors = colors \ (space + " " + invtokens(strofreal(C[i,])))
    test = test \ rgb
}
end
// Test consistency
mata:
length(colors)
p = unorder(length(colors))
colors = colors[p]
test = test[p]
S = ColrSpace()
S.Colors(colors)
assert(S.Colors(1)==test)
test = `"""' :+ test :+ `"""'
test = invtokens(test')
colors = `"""' :+ colors :+ `"""'
colors = invtokens(colors')
S = ColrSpace()
S.colors(colors)
assert(S.colors(1)==test)
end

/*----------------------------------------------------------------------------*/
// Check consistency of translators by back-transformation

// A. convert() function
mata:
S = ColrSpace()
S.palette("s2")
end
foreach from in CMYK1 HSL HSV RGB1 lRGB XYZ XYZ1 xyY xyY1 Lab Luv CAM02 JMh Jab {
    foreach to in CMYK1 HSL HSV RGB1 lRGB XYZ XYZ1 xyY xyY1 Lab Luv CAM02 JMh Jab {
        di "`from' <-> `to': " _c
        capt mata: virtuallyequal(S.get("`from'"), ///
            S.convert(S.convert(S.get("`from'"), "`from'", "`to'"), "`to'", "`from'"))
        if _rc == 0 di "ok"
        else {
            capt mata: almostequal(S.get("`from'"), ///
                S.convert(S.convert(S.get("`from'"), "`from'", "`to'"), "`to'", "`from'"), 1e-14)
            if _rc == 0 di "1e-14"
            else {
                capt mata: almostequal(S.get("`from'"), ///
                    S.convert(S.convert(S.get("`from'"), "`from'", "`to'"), "`to'", "`from'"), 1e-13)
                if _rc == 0 di "1e-13"
                else {
                    mata: almostequal(S.get("`from'"), ///
                        S.convert(S.convert(S.get("`from'"), "`from'", "`to'"), "`to'", "`from'"), 1e-12)
                    di "1e-12"
                }
            }
        }
    }
}
mata: virtuallyequal(S.get("RGB"), S.convert(S.convert(S.get("RGB"), "RGB", "HEX"), "HEX", "RGB"))
foreach a in J Q {
    foreach b in C M s {
        foreach c in h H {
            di "RGB1 <-> CAM02 `a'`b'`c': " _c
            mata: almostequal(S.get("RGB1"), ///
                S.convert(S.convert(S.get("RGB1"), "RGB1", "CAM02 `a'`b'`c'"), ///
                    "CAM02 `a'`b'`c'", "RGB1"), 1e-14)
            di "ok"
        }
    }
}
foreach a in UCS LCD SCD "1.10 .008 .02"{
    di "RGB1 <-> JMh `a': " _c
    mata: almostequal(S.get("RGB1"), ///
        S.convert(S.convert(S.get("RGB1"), "RGB1", "JMh `a'"), ///
            "JMh `a'", "RGB1"), 1e-14)
    di "ok"
}
foreach a in UCS LCD SCD "1.10 .008 .02"{
    di "RGB1 <-> Jab `a': " _c
    mata: almostequal(S.get("RGB1"), ///
        S.convert(S.convert(S.get("RGB1"), "RGB1", "Jab `a'"), ///
            "Jab `a'", "RGB1"), 1e-14)
    di "ok"
}
mata: almostequal(S.get("CAM02 QsH"), S.convert(S.get("JMh LCD"), "JMh LCD", "CAM02 QsH"), 1e-14)
mata: almostequal(S.get("JMh SCD"), S.convert(S.get("CAM02 JMH"), "CAM02 JMH", "JMh SCD"), 1e-14)
mata: almostequal(S.get("CAM02 QsH"), S.convert(S.get("Jab LCD"), "Jab LCD", "CAM02 QsH"), 1e-14)
mata: almostequal(S.get("Jab SCD"), S.convert(S.get("CAM02 JMH"), "CAM02 JMH", "Jab SCD"), 1e-14)


// B. S.get() / S.set() functions
mata:
S = ColrSpace()
S.palette("s2")
RGB1 = S.get("RGB1")
end
foreach from in CMYK1 HSL HSV RGB1 lRGB XYZ XYZ1 xyY xyY1 Lab Luv CAM02 JMh Jab {
    mata: S.set(RGB1, "RGB1")  // reset
    mata: Test = S.get("`from'")
    foreach to in CMYK1 HSL HSV RGB1 lRGB XYZ XYZ1 xyY xyY1 Lab Luv CAM02 JMh Jab {
        di "`from' <-> `to': " _c
        mata: S.set(Test, "`from'")
        mata: S.set(S.get("`to'"), "`to'")
        capt mata: virtuallyequal(S.get("`from'"), Test)
        if _rc == 0 di "ok"
        else {
            capt mata: almostequal(S.get("`from'"), Test, 1e-14)
            if _rc == 0 di "1e-14"
            else {
                capt mata: almostequal(S.get("`from'"), Test, 1e-13)
                if _rc == 0 di "1e-13"
                else {
                    mata: almostequal(S.get("`from'"), Test, 1e-12)
                    di "1e-12"
                }
            }
        }
    }
}
mata: S.set(RGB1, "RGB1")
mata: Test = S.get("RGB")
mata: S.set(S.get("HEX"),"HEX") 
mata: virtuallyequal(S.get("RGB"), Test)
foreach a in J Q {
    foreach b in C M s {
        foreach c in h H {
            di "RGB1 <-> CAM02 `a'`b'`c': " _c
            mata: S.set(RGB1, "RGB1")
            mata: S.set(S.get("CAM02 `a'`b'`c'"), "CAM02 `a'`b'`c'")
            mata: almostequal(S.get("RGB1"), RGB1, 1e-14)
            di "ok"
        }
    }
}
foreach a in UCS LCD SCD "1.10 .008 .02"{
    di "RGB1 <-> JMh `a'`b'`c': " _c
    mata: S.set(RGB1, "RGB1")
    mata: S.set(S.get("JMh `a'"), "JMh `a'")
    mata: almostequal(S.get("RGB1"), RGB1, 1e-14)
    di "ok"
}
foreach a in UCS LCD SCD "1.10 .008 .02"{
    di "RGB1 <-> Jab `a'`b'`c': " _c
    mata: S.set(RGB1, "RGB1")
    mata: S.set(S.get("Jab `a'"), "Jab `a'")
    mata: almostequal(S.get("RGB1"), RGB1, 1e-14)
    di "ok"
}

/*----------------------------------------------------------------------------*/
// Confirm results found in colorspacious documentation, revision 59e02260
// https://colorspacious.readthedocs.io/

mata:
// test values from: https://colorspacious.readthedocs.io/en/latest/tutorial.html

S = ColrSpace()
S.rgbspace("sRGB2") // use same definition as colorspacious

// RGB -> XYZ
Input = (128, 128, 128)
Test  = (20.51692894, 21.58512253, 23.506738)
almostequal(S.convert(Input,"RGB", "XYZ"), Test, 1e-9)
S.set(Input, "RGB")
almostequal(S.get("XYZ"), Test, 1e-9)

// RGB1 -> XYZ (image data)
Input = (0.08235294,  0.09411765,  0.3019608 ) \
        (0.10588235,  0.11764706,  0.33333334) \
        (0.10196079,  0.11372549,  0.32156864) \
        (0.09803922,  0.10980392,  0.32549021)
Test  = (1.97537605,  1.34848558,  7.17731319) \
        (2.55586737,  1.81738616,  8.81036579) \
        (2.38827051,  1.70749148,  8.18630399) \
        (2.37740322,  1.66167069,  8.37900306)
almostequal(S.convert(Input,"RGB1", "XYZ"), Test, 1e-7)
S.set(Input, "RGB1")
almostequal(S.get("XYZ"), Test, 1e-7)

// RGB1 with CVD -> CAM02 JCh
Input = (1,0,0)
Test  = (47.72696721,  62.75654782,  71.41502844)
almostequal(S.convert(S.convert(Input,"RGB1", "CVD", .5, "d"), "RGB1", "CAM02 JCh"), Test, 1e-9)
S.set(Input, "RGB1")
S.cvd(.5, "d")
almostequal(S.get("CAM02 JCh"), Test, 1e-9)

// RGB1 without CVD -> CAM02 JCh
Input = (1,0,0)
Test  = (46.9250674,  111.3069358,   32.1526953)
almostequal(S.convert(Input,"RGB1", "CAM02 JCh"), Test, 1e-9)
S.set(Input, "RGB1")
almostequal(S.get("CAM02 JCh"), Test, 1e-9)

// Color differences
S = ColrSpace()
S.rgbspace("sRGB2") // use same definition as colorspacious

Test = 55.337158728500363
S.set((1, 0.5, 0.5) \ (0.5, 1, 0.5), "RGB1")
virtuallyequal(S.delta(), Test)
virtuallyequal(S.delta(., "jab"), Test)
virtuallyequal(S.delta((1,2), "jab"), Test)
virtuallyequal(S.delta((2,1), "jab"), Test)

Test = 55.490775265826485
S.set((255, 127, 127) \ (127, 255, 127), "RGB")
virtuallyequal(S.delta(), Test)
virtuallyequal(S.delta(., "jab"), Test)

Test = 114.05544189591937
S.set((1, 0.5, 0.5) \ (0.5, 1, 0.5), "RGB1")
virtuallyequal(S.delta(., "lab"), Test)
virtuallyequal(S.delta(., "E76"), Test)
end


/*----------------------------------------------------------------------------*/
// Confirm results found in gold_values.py from colorspacious
// https://github.com/njsmith/colorspacious/blob/master/colorspacious/gold_values.py

// CIECAM02

mata:
Input = (19.31, 23.93, 10.14)
Test  = (191.0452, 48.0314, 183.1240, 46.0177, 38.7789, 38.7789, 240.8885)
S = ColrSpace()
S.xyzwhite(98.88, 90, 32.03)
S.viewcond(18, 200, 1, .69, 1)
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-6)
S = ColrSpace()
S.xyzwhite((98.88, 90, 32.03))
S.viewcond((18, 200, 1, .69, 1))
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-6)
S = ColrSpace()
S.xyzwhite(98.88, 90, 32.03)
S.viewcond(18, 200, (1, .69, 1))
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-6)
S = ColrSpace()
S.xyzwhite("98.88 90 32.03")
S.viewcond("18 200 1 .69 1")
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-6)
S = ColrSpace()
S.xyzwhite("98.88 90 32.03")
S.viewcond("18 200 average")
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-6)

Test = (185.3445, 47.6856, 113.8401, 51.1275, 36.0527, 29.7580, 232.6630)
Input = (19.31, 23.93, 10.14)
S = ColrSpace()
S.xyzwhite(98.88, 90, 32.03)
S.viewcond(18, 20, 1, .69, 1)
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-5)

Test = (219.04841, 41.73109, 195.37131, 2.36031, 0.10471, 0.10884, 278.06070)
Input = (19.01, 20.00, 21.78)
S = ColrSpace()
S.xyzwhite(95.05, 100.0, 108.88)
S.viewcond(20, 318.30988618379, 1, .69, 1)
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-5)

Test = (19.55739, 65.95523, 152.67220, 52.24549, 48.57050, 41.67327, 399.38837)
Input = (57.06, 43.06, 31.96)
S = ColrSpace()
S.xyzwhite(95.05, 100.0, 108.88)
S.viewcond(20, 31.830988618379, 1, .69, 1)
S.set(Input, "XYZ")
almostequal(S.get("CAM02 hJQsCMH"), Test, 1e-6)
end

// linear RGB

mata:
S = ColrSpace()

Input = (0.1, 0.2, 0.3) \ (0.9, 0.8, 0.7) \ (0.04, 0.02, 0.01)
Test  = (0.010022825574869, 0.0331047665708851, 0.0732389558784054) \
        (0.787412289395617, 0.603827338855338, 0.447988412441883) \
        (0.00309597523219814, 0.00154798761609907, 0.000773993808049536)
S.set(Input, "RGB1")
virtuallyequal(S.get("lRGB"), Test)
virtuallyequal(S.convert(Input, "RGB1", "lRGB"), Test)
virtuallyequal(S.convert(Test, "lRGB", "RGB1"), Input)

Input = (0.00650735931, 0.00789021442, 0.114259116060) \
        (0.03836396959, 0.01531740787, 0.014587362033)
Test  = (2.61219, 1.52732, 10.96471) \
        (2.39318, 2.01643, 1.64315)
S.set(Input,"lRGB")
almostequal(S.get("XYZ"), Test, 1e-3) // test values are inaccurate; see gold_values.py
end

// CIELab

mata:
S = ColrSpace()

Input = (10, 20, 30) \ (80, 90, 10) \ (0.5, 0.6, 0.4)
Test  = (51.8372, -56.3591, -13.1812) \
        (95.9968, -10.6593, 102.8625) \
        (5.4198, -2.8790, 3.6230)
S.set(Input, "XYZ")
almostequal(S.get("Lab"), Test, 1e-4)

Input = (10, 20, 30) \ (80, 90, 10)
Test  = (51.8372, 57.8800, 193.1636) \
        (95.9968, 103.4134, 95.9163)
S.set(Input, "XYZ")
almostequal(S.get("LCh"), Test, 1e-6)
end

mata:
S = ColrSpace()
S.xyzwhite("D50")

Input = (2.61219, 1.52732, 10.96471) \ 
        (2.39318, 2.01643, 1.64315) \ 
        (0.5, 0.6, 0.4)
Test  = (12.7806, 26.1147, -52.4348) \
        (15.5732, 9.7574, 0.2281) \
        (5.4198, -3.1711, 1.7953)
S.set(Input, "XYZ")
almostequal(S.get("Lab"), Test, 1e-4)

Input = (10, 20, 30) \ (80, 90, 10)
Test  = (51.8372, 63.0026, 204.1543) \
        (95.9968, 95.0085, 97.8122)
S.set(Input, "XYZ")
almostequal(S.get("LCh"), Test, 1e-6)
end

// CAM02-UCS

mata:
S = ColrSpace()

Input = (50, 20, 10) \ 
        (10, 60, 100) 
Test  = (62.96296296,  16.22742674,   2.86133316) \
        (15.88785047,  -6.56546789,  37.23461867)
S.set(Input, "CAM02 JMh")
almostequal(S.get("Jab UCS"), Test, 1e-9)
almostequal(S.get("Jab 1 .007 .0228"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab UCS"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab  1 .007 .0228"), Test, 1e-9)
almostequal(S.get("Jab"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab"), Test, 1e-9)

Test  = (81.77008177,  18.72061994,   3.30095039) \
        (20.63357204,  -9.04659289,  51.30577777)
Test = Test :* (0.77,1,1)  // because test values contain J'/K_L not J'
S.set(Input, "CAM02 JMh")
almostequal(S.get("Jab LCD"), Test, 1e-9) 
almostequal(S.get("Jab 0.77 0.007 0.0053"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab LCD"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab  0.77 0.007 0.0053"), Test, 1e-9)
S.ucscoefs("LCD")
almostequal(S.get("Jab"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab"), Test, 1e-9)


Test  = (50.77658303,  14.80756375,   2.61097301) \
        (12.81278263,  -5.5311588 ,  31.36876036)
Test = Test :* (1.24,1,1)  // because test values contain J'/K_L not J'
S.set(Input, "CAM02 JMh")
almostequal(S.get("Jab SCD"), Test, 1e-9)
almostequal(S.get("Jab 1.24 0.007 0.0363"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab SCD"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab  1.24 0.007 0.0363"), Test, 1e-9)
S.ucscoefs("SCD")
almostequal(S.get("Jab"), Test, 1e-9)
almostequal(S.convert(Input, "CAM02 JMh", "Jab"), Test, 1e-9)

end

// Color difference

mata:
S = ColrSpace()
S.rgbspace("sRGB2") // use same definition as colorspacious

Test = (80.3336, 14.7071)'
S.set((173,  52,  52) \ (69,  100,  52) \ (69, 120,  51) \ (69, 120,  51), "RGB")
almostequal(S.delta((1,3)\(2,4), "lab"), Test, 1e-4)

Test = (44.698469808449964, 8.503323264883667)'
almostequal(S.delta((1,3)\(2,4)), Test, 1e-14)
almostequal(S.delta((1,3)\(2,4), "jab"), Test, 1e-14)
almostequal(S.delta((1,3)\(2,4), "jab ucs"), Test, 1e-14)
almostequal(S.delta((1,3)\(2,4), "jab 1 .007 .0228"), Test, 1e-14)

Test = S.delta((1,3)\(2,4), "jab LCD")
virtuallyequal(S.delta((1,3)\(2,4), "jab 0.77 0.007 0.0053"), Test)

Test = S.delta((1,3)\(2,4), "jab SCD")
virtuallyequal(S.delta((1,3)\(2,4), "jab 1.24 0.007 0.0363"), Test)
end

// CVD

mata:
S = ColrSpace()

Input = (0.1, 0.2, 0.3) \ (0.9, 0.5, 0.3)
Test  = (0.12440528,  0.19103024,  0.29911687) \ 
        (0.76726301,  0.59528358,  0.29263454)
S.set(Input, "RGB1")
S.cvd(.5, "deut")
almostequal(S.get("RGB1"), Test, 1e-8)
almostequal(S.convert(Input, "RGB1", "CVD", .5, "deut"), Test, 1e-8)

Test  = (0.15588987,  0.2038791 ,  0.30416046) \ 
        (0.62151883,  0.55237436,  0.27997229)
S.set(Input, "RGB1")
S.cvd(.95, "prot")
almostequal(S.get("RGB1"), Test, 1e-8)
almostequal(S.convert(Input, "RGB1", "CVD", .95, "prot"), Test, 1e-8)
end

// no independent test values for tritanomaly; using own results

mata:
S = ColrSpace()
Input = (0.1, 0.2, 0.3) \ (0.9, 0.5, 0.3)
Test  = (-.0394112568142782,   .223311834497421,  .2353104336058275) \
        ( .9818005265609083,  .4213151820522694,  .4540710154678977)
S.set(Input, "RGB1")
S.cvd(1, "tritanomaly")
//mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)
virtuallyequal(S.convert(Input, "RGB1", "CVD", 1, "tritanomaly"), Test)
end

/*----------------------------------------------------------------------------*/
// compare saturate() and luminate() to results from 
// https://gka.github.io/chroma.js/
// note: chroma.js changes saturation/luminance in steps of 18

mata:
S = ColrSpace()

S.colors("Slategray")
S.saturate(18*1, "LCh")
assert(S.get("hex")=="#4b83ae")

S.colors("Slategray")
S.saturate(18*2, "LCh")
assert(S.get("hex")=="#0087cd")

S.colors("Slategray")
S.saturate(18*3, "LCh")
assert(S.get("hex")=="#008bec")

S.colors("Hotpink")
S.saturate(18*-1, "LCh")
assert(S.get("hex")=="#e77dae")

S.colors("Hotpink")
S.saturate(18*-2, "LCh")
assert(S.get("hex")=="#cd8ca8")

S.colors("Hotpink")
S.saturate(18*-3, "LCh")
assert(S.get("hex")=="#b199a3")

S.colors("Hotpink")
S.luminate(18*-1, "Lab")
assert(S.get("hex")=="#c93384")

S.colors("Hotpink")
S.luminate(18*-2, "Lab")
assert(S.get("hex")=="#930058")

S.colors("Hotpink")
S.luminate(18*-2.6, "Lab")
assert(S.get("hex")=="#74003f")

S.colors("Hotpink")
S.luminate(18*1, "Lab")
assert(S.get("hex")=="#ff9ce6")

S.colors("Hotpink")
S.luminate(18*2, "Lab")
assert(S.get("hex")=="#ffd1ff")

S.colors("Hotpink")
S.luminate(18*3, "Lab")
assert(S.get("hex")=="#ffffff")

end




/*----------------------------------------------------------------------------*/
// CIELuv / HCL
// using values from http://www.brucelindbloom.com/

mata:
S = ColrSpace()

Input = (10, 20, 30) \ (80, 90, 10) \ (0.5, 0.6, 0.4)
S.set(Input, "XYZ")

Test  = (51.8372, -65.9327, -12.3565) \
        (95.9968, 26.6292, 107.8962) \
        (5.4198, -0.7697, 2.5602)
almostequal(S.get("Luv")[(1\2),], Test[(1\2),], 1e-5)
almostequal(S.get("Luv")[3,], Test[3,], 1e-4)

Test  = (190.6148, 67.0806,  51.8372) \
        (76.1362 , 111.1338, 95.9968) \
        (106.7325,  2.6734,  5.4198 )
almostequal(S.get("HCL")[(1\2),], Test[(1\2),], 1e-6)
almostequal(S.get("HCL")[3,], Test[3,], 1e-4)
end

/*----------------------------------------------------------------------------*/
// HSV / HSL
// using values from http://colorizer.org/

mata:
S = ColrSpace()

Input = (10,200,100) \ (140, 71, 33) \ (0, 65, 190)
HSL = (148.42, 90.48/100, 41.18/100) \ 
      (21.31, 61.85/100, 33.92/100) \ 
      (219.47, 100/100, 37.25/100)
HSV = (148.42, 95/100, 78.43/100) \ 
      (21.31 , 76.43/100 , 54.9/100) \
      (219.47, 100/100, 74.51/100)
S.set(Input,"RGB")
almostequal(S.get("HSL"), HSL, 1e-4)
almostequal(S.get("HSV"), HSV, 1e-4)
end


/*----------------------------------------------------------------------------*/
// Chromatic adaption and RGB spaces
// using values from http://www.brucelindbloom.com/

// XYZ to XYZ when changing white point
mata:
S = ColrSpace()
Input = (10, 20, 30) \ (80, 90, 10) \ (0.5, 0.6, 0.4)

// D65 -> D50
Test = ( 9.6110, 19.7574, 25.4118) \
       (83.1836, 90.8406,  8.8248) \
       ( 0.5098,  0.6015,  0.3399)
S.xyzwhite("D65")
S.set(Input,"XYZ")
S.xyzwhite("D55")
almostequal(S.get("XYZ")[(1\2),], Test[(1\2),], 1e-5)
almostequal(S.get("XYZ")[3,], Test[3,], 1e-4)

// D65 -> A
Test = (  9.7364, 18.1581, 9.9211) \
       (105.7563, 94.0775, 4.4626) \
       (  0.6128,  0.6034, 0.1355)
S.xyzwhite("D65")
S.set(Input,"XYZ")
S.xyzwhite("A")
almostequal(S.get("XYZ")[(1\2),], Test[(1\2),], 1e-5)
almostequal(S.get("XYZ")[3,], Test[3,], 1e-4)
end

// XYZ to sRGB using different chromatic adaption techniques

mata:
S = ColrSpace()
Input = (10, 20, 30) \ (80, 90, 10) \ (0.5, 0.6, 0.4)

// D65 -> sRGB
Test = (-0.400105, 0.575542,  0.567505) \
       ( 1.066934, 0.962661, -0.200901) \
       ( 0.060866, 0.075038,  0.042356)
S.xyzwhite("D65")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// D55 -> Bradford -> sRGB
Test = (-0.419644, 0.577802,  0.617377) \
       ( 1.028278, 0.969786, -0.146792) \
       ( 0.055012, 0.075770,  0.051081)
S.xyzwhite("D55")
S.chadapt("Bfd")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// D55 -> von Kries-> sRGB
Test = (-0.420379, 0.574739,  0.617755) \
       ( 1.018542, 0.977498, -0.133229) \
       ( 0.054247, 0.076025,  0.051209)
S.xyzwhite("D55")
S.chadapt("vKries")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// D55 -> XYZscaling-> sRGB
Test = (-0.439498, 0.578162,  0.617608) \
       ( 1.056273, 0.965384, -0.125692) \
       ( 0.056187, 0.075550,  0.051247)
S.xyzwhite("D55")
S.chadapt("identity")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// D55 -> CAT02-> sRGB
// no independent test values; using own results
Test = (-.4162117530223047 ,   .5773754092986618  ,  .6090043662590734) \
       ( 1.033506396008826 ,   .9674505460051687  , -.1278423983163492) \
       ( .0559325649513772 ,   .0755821890885082  ,  .0498748046759724)
S.xyzwhite("D55")
S.chadapt("CAT02")
S.set(Input,"XYZ")
// mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)

end

// XYZ to sRGB for various white points
// (only testing the white point for which test values can be generated at
//  brucelindbloom.com)

mata:
S = ColrSpace()
Input = (10, 20, 30) \ (80, 90, 10) \ (0.5, 0.6, 0.4)

// A -> sRGB
Test = (-0.551537, 0.606789,  0.978710) \
       ( 0.711133, 1.044350,  0.392250) \
       ( 0.005451, 0.083806,  0.112264)
S.xyzwhite("A")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// B -> sRGB
Test = (-0.446564, 0.585534,  0.641223) \
       ( 0.971552, 0.985669, -0.111809) \
       ( 0.046151, 0.077657,  0.055208)
S.xyzwhite("B BL")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// C -> sRGB
Test = (-0.412467, 0.581464,  0.543457) \
       ( 1.045316, 0.972669, -0.221619) \
       ( 0.057671, 0.076329,  0.038104)
S.xyzwhite("C")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// D50 -> sRGB
Test = (-0.432988, 0.579721,  0.652246) \
       ( 1.001249, 0.975359, -0.086191) \
       ( 0.050771, 0.076354,  0.057116)
S.xyzwhite("D50")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// D75 -> sRGB
Test = (-0.386586, 0.574417,  0.533885) \
       ( 1.093233, 0.958537, -0.228064) \
       ( 0.064722, 0.074627,  0.036445)
S.xyzwhite("D75")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// E -> sRGB
Test = (-0.439988, 0.586953,  0.591521) \
       ( 0.986461, 0.985682, -0.179809) \
       ( 0.048632, 0.077798,  0.046570)
S.xyzwhite("E")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// F2 -> sRGB
Test = (-0.462862, 0.585885,  0.720303) \
       ( 0.937179, 0.990677,  0.127829) \
       ( 0.040207, 0.078038,  0.068775)
S.xyzwhite("F2")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// F7 -> sRGB
Test = (-0.400189, 0.575538,  0.567868) \
       ( 1.066761, 0.962673, -0.200574) \
       ( 0.060841, 0.075038,  0.042420)
S.xyzwhite("F7")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// F11 -> sRGB
Test = (-0.475415, 0.589853,  0.736339) \
       ( 0.907326, 0.998898,  0.153553) \
       ( 0.035197, 0.079007,  0.071501)
S.xyzwhite("F11")
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

end

// XYZ to various RGB working spaces
// (only testing the spaces for which test values can be generated at
//  brucelindbloom.com)

mata:
S = ColrSpace()
Input = (10, 20, 30) \ (80, 90, 10) \ (0.5, 0.6, 0.4)

// Adobe -> sRGB
S.rgbspace("Adobe")
Test = (-0.135252, 0.570348, 0.562751) \
       ( 1.040024, 0.961453, 0.095852) \
       ( 0.093469, 0.101897, 0.075686)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Apple -> sRGB
S.rgbspace("Apple")
Test = (-0.285723, 0.513064,  0.495013) \
       ( 1.082500, 0.958994, -0.219074) \
       ( 0.053413, 0.061819,  0.040938)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Best -> sRGB
S.rgbspace("Best")
Test = ( 0.139733, 0.531394, 0.557269) \
       ( 1.016358, 0.959703, 0.333165) \
       ( 0.093167, 0.100107, 0.078154)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Beta -> sRGB
S.rgbspace("Beta")
Test = ( 0.173136, 0.553175, 0.557176) \
       ( 1.012120, 0.955171, 0.271544) \
       ( 0.093268, 0.100815, 0.077073)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Bruce -> sRGB
S.rgbspace("Bruce")
Test = (-0.322825, 0.570348, 0.562767) \
       ( 1.057397, 0.961453, 0.109896) \
       ( 0.091362, 0.101897, 0.075757)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// CIE -> sRGB
S.rgbspace("CIE")
Test = (-0.279695, 0.532727, 0.556996) \
       ( 1.080325, 0.931949, 0.325045) \
       ( 0.093848, 0.098751, 0.077982)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Colormatch -> sRGB
S.rgbspace("Colormatch")
Test = (-0.245799, 0.514359,  0.497223) \
       ( 1.057920, 0.961913, -0.224186) \
       ( 0.053312, 0.061949,  0.040964)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Don 4 -> sRGB
S.rgbspace("Don 4")
Test = ( 0.137169, 0.547850, 0.558295) \
       ( 1.016480, 0.955392, 0.310362) \
       ( 0.093151, 0.100594, 0.077790)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// ECI v2 -> sRGB
S.rgbspace("ECI v2")
Test = ( 0.085790, 0.603267, 0.594490) \
       ( 1.017658, 0.983395, 0.163307) \
       ( 0.048896, 0.060347, 0.031002)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Ekta PS5 -> sRGB
S.rgbspace("Ekta PS5")
Test = (-0.122544, 0.550024, 0.557349) \
       ( 1.010962, 0.943155, 0.271391) \
       ( 0.091802, 0.100070, 0.077082)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// NTSC -> sRGB
S.rgbspace("NTSC")
S.rgb_gamma(2.2)                        // brucelindbloom.com uses simple gamma
Test = ( 0.071107, 0.564607, 0.556040) \
       ( 1.022332, 0.993689, 0.220944) \
       ( 0.093071, 0.103287, 0.076303)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// PAL/SECAM -> sRGB
S.rgbspace("PAL/SECAM")
S.rgb_gamma(2.2)                        // brucelindbloom.com uses simple gamma
Test = (-0.374255, 0.570348,  0.562326) \
       ( 1.065118, 0.961453, -0.243583) \
       ( 0.090393, 0.101897,  0.073901)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// ProPhoto -> sRGB
S.rgbspace("ProPhoto")
Test = ( 0.219458, 0.461716, 0.489056) \
       ( 0.949875, 0.951374, 0.276083) \
       ( 0.054248, 0.060039, 0.044560)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// SMPTE-C -> sRGB
S.rgbspace("SMPTE-C")
S.rgb_gamma(2.2)                        // brucelindbloom.com uses simple gamma
Test = (-0.435422, 0.577839,  0.561842) \
       ( 1.079953, 0.966748, -0.194429) \
       ( 0.089261, 0.102503,  0.074485)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

// Wide Gamut -> sRGB
S.rgbspace("Wide Gamut BL")
Test = ( 0.230004, 0.532301, 0.558585) \
       ( 1.026203, 0.944447, 0.247087) \
       ( 0.094916, 0.099366, 0.076801)
S.set(Input,"XYZ")
almostequal(S.get("RGB1"), Test, 1e-6)

end

/*----------------------------------------------------------------------------*/
// Grayscale / Desaturation
// no independent test values; using own results

mata:
S = ColrSpace()
S.rgbspace("sRGB2")
Input = (0.1, 0.2, 0.3) \ (0.9, 0.5, 0.3)

Test  = (.1934290362906098,    .1934366564620332,     .193411650106877) \
        (.6061375710930151,    .6061578504520685,    .6060913017057676)
S.set(Input,"RGB1")
S.gray()
//mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", 1, "lch"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", 1, "hcl"), Test)

Test  = (.1917241609664255 ,   .1874524691436175  ,  .1866499960320828) \
        (.6362371969125397 ,   .6242693690755496  ,  .6220211123096046)
S.set(Input,"RGB1")
S.gray(1, "JCh")
//mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", 1, "JCh"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", 1, "jmh"), Test)

Test  = (.1878009807888925 ,   .1939818385735516 ,   .2039957079453397) \
        (.6448059399952002 ,   .5970541590619414 ,   .5758877784337004)
S.set(Input,"RGB1")
S.gray(.9)
//mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", .9), Test)

Test  = (.1873802935479996 ,   .1940024240082789   , .2049306129944468) \
        (.6472491461502893 ,    .595654261502345   , .5820086498187241)
S.set(Input,"RGB1")
S.gray(.9, "hcl")
//mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", .9, "hcl"), Test)

Test  = ( .1866268719970364 ,   .1886297786075018 ,   .1945711009718938) \
        ( .6649821912136421 ,   .6150890470498098 ,   .5946175265684293)
S.set(Input,"RGB1")
S.gray(.9, "JCh")
//mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", .9, "JCh"), Test)

Test  = ( .1875172979743542 ,   .1884293663489769 ,   .1932020274480589) \
        ( .6572708194084104 ,   .6176303307019754 ,   .6021242780567131) 
S.set(Input,"RGB1")
S.gray(.9, "jmh")
//mm_matlist(S.get("RGB1"),"%18.0g")
virtuallyequal(S.get("RGB1"), Test)
virtuallyequal(S.convert(Input, "RGB1", "gray", .9, "jmh"), Test)
end


/*----------------------------------------------------------------------------*/
// Test manual specification of RGB working space

mata:
S = ColrSpace()
S.rgbspace("NTSC")
gamma = S.rgb_gamma()
assert(gamma==(1/0.45, 0.099, 0.018, 4.5))
rgbwhite = S.rgb_white()
assert(rgbwhite==( 98.074, 100, 118.232))
xy = S.rgb_xy()
assert(xy==((0.6700, 0.3300) \ (0.2100, 0.7100) \ (0.1400, 0.0800)))
M = S.rgb_M()
//mm_matlist(M, "%18.0g")
virtuallyequal(M, ((  .606890921238938,   .173501121238938, .2003479575221239) \
                   ( .2989164238938053,  .5865990289506954, .1144845471554994) \
                   (-5.02824085220e-17,  .0660956652338812, 1.116224334766119)))
invM = S.rgb_invM()
//mm_matlist(invM, "%18.0g")
virtuallyequal(invM, (( 1.909996098918454, -.5324541554529706, -.2882091300158282) \
                      (-.9846663050051851,  1.999170982889315,  -.028308199910794) \
                      ( .0583056402155416, -.1183781180133722,  .8975534918028808)))

Input = (10, 20, 30) \ (80, 90, 10) \ (0.5, 0.6, 0.4)
S.set(Input,"XYZ")
Test = S.get("RGB1")
//mm_matlist(Test, "%18.0g")
virtuallyequal(Test,((  .01340988035922, .5250602546678395, .5156852060297969) \
                     (1.024294623934066, .9931336691567361,  .147511851871282) \
                     (.0242438672558301, .0304871042078975, .0156605886628426)))

S = ColrSpace()
S.rgb_gamma(gamma)
S.rgb_white(rgbwhite)
S.rgb_xy(xy)
S.set(Input,"XYZ")
assert(S.get("RGB1")==Test)

S = ColrSpace()
S.rgb_xy(xy)
S.rgb_white(rgbwhite) // so that M/invM have to be recomputed
S.rgb_gamma(gamma)
S.set(Input,"XYZ")
assert(S.get("RGB1")==Test)

S = ColrSpace()
S.rgb_xy(xy)
S.rgb_white(rgbwhite[1], rgbwhite[2], rgbwhite[3])  // individual args
S.rgb_gamma(gamma[1], gamma[2], gamma[3], gamma[4]) // individual args
S.set(Input,"XYZ")
assert(S.get("RGB1")==Test)

S = ColrSpace()
S.rgb_xy(xy)
S.rgb_white(invtokens(strofreal(rgbwhite)))         // string
S.rgb_gamma(invtokens(strofreal(gamma, "%24.0g")))  // string
S.set(Input,"XYZ")
assert(S.get("RGB1")==Test)

S = ColrSpace()
S.rgb_M(M)  // specify M instead of xy
S.rgb_white(rgbwhite)
S.rgb_gamma(gamma)
S.set(Input,"XYZ")
virtuallyequal(S.get("RGB1"),Test)

S = ColrSpace()
S.rgb_invM(invM) // specify invM instead of xy
S.rgb_white(rgbwhite)
S.rgb_gamma(gamma)
S.set(Input,"XYZ")
virtuallyequal(S.get("RGB1"),Test)

end

/*----------------------------------------------------------------------------*/
// Test all illuminants (confirm that results did not change)

mata:
T =     (  -.5515874633030511 ,   .6067561409225282  ,   .978621690571115)
T = T \ (   .7111435048883084 ,   1.044357795539455  ,  .3922481075135849)
T = T \ (  -.5581177589236097 ,   .6099953949054264  ,  .9830499385834822)
T = T \ (   .6867027334424911 ,   1.050340581165016  ,  .3949953738825114)
T = T \ (  -.4466145964549765 ,    .585547867962313  ,  .6407804026986892)
T = T \ (   .9715189055779957 ,   .9857505576064308  , -.1123169094174329)
T = T \ (  -.4465933024392457 ,   .5855105711400613  ,   .641163733614514)
T = T \ (   .9715716762205197 ,   .9857014397072436  ,  -.111594383681427)
T = T \ (  -.4479555421713793 ,   .5857737414098341  ,  .6444441788588199)
T = T \ (   .9685632260645806 ,   .9863701651740661  , -.1054758966450101)
T = T \ (  -.4124912909290596 ,   .5814434259113496  ,  .5434069425863413)
T = T \ (   1.045337454440666 ,   .9727102337757697  , -.2214857028058306)
T = T \ (  -.4089599122791617 ,   .5798715026983235  ,  .5485654095162836)
T = T \ (   1.051680404605115 ,   .9699895733667999  , -.2172397291651669)
T = T \ (  -.4330184963415868 ,   .5796979738134783  ,   .652186503869161)
T = T \ (   1.001269186207457 ,   .9753953615063043  , -.0859154091677648)
T = T \ (  -.4358222534127171 ,   .5803751053259423  ,   .656464777235565)
T = T \ (   .9954236496947736 ,   .9769080299905845  , -.0754514578317874)
T = T \ (  -.4196731822711846 ,   .5777800741015556  ,  .6173199627086325)
T = T \ (   1.028299329873386 ,   .9698258610296971  , -.1466091460313426)
T = T \ (  -.4215292995921253 ,   .5780828317733322  ,  .6214495144550972)
T = T \ (    1.02457561313603 ,   .9706308059233794  , -.1409245278694319)
T = T \ (  -.4001307851913201 ,   .5755221369488969  ,  .5674524051918982)
T = T \ (   1.066955800819633 ,   .9627060191886455  , -.2007534246143978)
T = T \ (  -.3999628748873669 ,   .5751142419377242  ,  .5717411003856276)
T = T \ (   1.067056507414067 ,   .9621656390294345  , -.1967981298894024)
T = T \ (  -.3866105069042504 ,   .5743973018038599  ,  .5338356923303493)
T = T \ (   1.093255541709753 ,   .9585858568342503  , -.2279273525043305)
T = T \ (  -.3844292446140032 ,   .5733612008905241  ,  .5384872244349976)
T = T \ (   1.096612890730674 ,   .9568479500014105  , -.2243774893390953)
T = T \ (  -.3824378336443103 ,   .5772615252861073  ,  .4905938403592227)
T = T \ (   1.105315606408873 ,   .9615559299289164  , -.2568058543600217)
T = T \ (  -.4400144922169025 ,   .5869306143577367  ,  .5914666510221888)
T = T \ (   .9864813781581553 ,   .9857157478966613  , -.1796621276438604)
T = T \ (  -.3895236104436467 ,   .5711152964823338  ,  .5822576170837884)
T = T \ (    1.08532984508464 ,   .9550555250514837  , -.1862344954526575)
T = T \ (  -.4036589234313438 ,    .575314768554065  ,  .5832189221453687)
T = T \ (   1.059779957904876 ,   .9632036110661047  , -.1857770790003498)
T = T \ (  -.4628964937755924 ,   .5858598223427117  ,  .7202371619694975)
T = T \ (   .9371972655086892 ,   .9907056090342953  ,  .1279813594184831)
T = T \ (  -.4837774510893292 ,   .5953501165699556  ,  .7106245443577565)
T = T \ (   .8837009021343283 ,   1.007631843977608  ,  .1034041077536304)
T = T \ (  -.5043222152089347 ,   .5951564479264112  ,   .833142450802954)
T = T \ (   .8397049293834181 ,   1.014295929145784  ,  .2691631608948061)
T = T \ (  -.5279700054791512 ,   .6082694427061787  ,  .8145461619077506)
T = T \ (   .7626221604698331 ,   1.036731561975497  ,  .2460298923317588)
T = T \ (  -.5436982363898424 ,   .6061066063479836  ,  .9385531163407919)
T = T \ (   .7308644159165798 ,   1.040512832797335  ,  .3604954365116252)
T = T \ (  -.5680629412336188 ,   .6221059449700643  ,  .9114137463538681)
T = T \ (   .6256891571521838 ,   1.066906834167159  ,  .3336497173066545)
T = T \ (   -.380321703257418 ,   .5672465043809736  ,  .5972391343138519)
T = T \ (    1.10077268518611 ,    .948432623184264  , -.1699161118853855)
T = T \ (  -.3982017714614948 ,   .5725138654758379  ,  .5969994682677899)
T = T \ (     1.0694315419753 ,   .9586072818809462  , -.1707494753890034)
T = T \ (  -.4594882724486487 ,   .5812800526438434  ,  .7619709318399565)
T = T \ (   .9489009021068079 ,   .9846646967782081  ,  .1931328246824744)
T = T \ (  -.4838944815191978 ,   .5924855134998224  ,  .7490413204162812)
T = T \ (    .886492809596408 ,   1.004513198459158  ,  .1718351325423242)
T = T \ (  -.4002154991634556 ,   .5755178687580491  ,  .5678155191662859)
T = T \ (   1.066782565957607 ,   .9627185016015248  , -.2004266804992146)
T = T \ (  -.4063518240646091 ,   .5772027836662752  ,  .5705108297983943)
T = T \ (   1.055274940527642 ,   .9661074335111234  , -.1982049018534021)
T = T \ (  -.4331310114347305 ,   .5796810830220136  ,  .6529299833291561)
T = T \ (   1.001049182045951 ,   .9754049883039509  , -.0841153121926404)
T = T \ (  -.4384676334010064 ,   .5812513037411143  ,  .6575455952486732)
T = T \ (   .9897706235059863 ,   .9786145187779042  , -.0730061177092795)
T = T \ (  -.4689883183480444 ,   .5885610587003191  ,  .7174124175577191)
T = T \ (   .9221222922769836 ,   .9955343582742996  ,  .1213579321034685)
T = T \ (  -.4785655389716927 ,   .5926082544416835  ,  .7171319447027757)
T = T \ (   .8978395145682543 ,   1.002961685668625  ,  .1186930235941015)
T = T \ (  -.4322338345201499 ,   .5791685372080225  ,  .6554533524437196)
T = T \ (    1.00300196478363 ,   .9745803424690457  , -.0774966271778394)
T = T \ (  -.4479463916240516 ,   .5854102250857882  ,  .6491675530590947)
T = T \ (   .9686695042858581 ,   .9859457909569876  , -.0955921960428312)
T = T \ (  -.4754497339031893 ,   .5898274638174021  ,  .7362720516944303)
T = T \ (   .9073440390949692 ,   .9989228965030458  ,  .1536692242257638)
T = T \ (  -.4897967527959281 ,   .5966607782139447  ,  .7284400158007051)
T = T \ (   .8687704396565884 ,   1.010992190209296  ,  .1375107190892267)
T = T \ (  -.5379681892121785 ,   .6034211103765643  ,  .9342917228471705)
T = T \ (   .7504555770372995 ,   1.035486127021758  ,  .3576140353888968)
T = T \ (  -.5523561082342723 ,   .6124941588925745  ,  .9198383257097447)
T = T \ (   .6937640842048889 ,   1.050559026851946  ,  .3434347701075069)
ill = (
"A"             , 
"A 10 degree"   , 
"B"             , 
"B BL"          , 
"B 10 degree"   , 
"C"             , 
"C 10 degree"   , 
"D50"           , 
"D50 10 degree" , 
"D55"           , 
"D55 10 degree" , 
"D65"           , 
"D65 10 degree" , 
"D75"           , 
"D75 10 degree" , 
"9300K"         , 
"E"             , 
"F1"            , 
"F1 10 degree"  , 
"F2"            , 
"F2 10 degree"  , 
"F3"            , 
"F3 10 degree"  , 
"F4"            , 
"F4 10 degree"  , 
"F5"            , 
"F5 10 degree"  , 
"F6"            , 
"F6 10 degree"  , 
"F7"            , 
"F7 10 degree"  , 
"F8"            , 
"F8 10 degree"  , 
"F9"            , 
"F9 10 degree"  , 
"F10"           , 
"F10 10 degree" , 
"F11"           , 
"F11 10 degree" , 
"F12"           , 
"F12 10 degree")
R = J(0,3,.)
S = ColrSpace()
S.rgbspace("sRGB2")
Input = (10, 20, 30) \ (80, 90, 10)
for (i=1; i<=length(ill); i++) {
    S.xyzwhite(ill[i])
    S.set(Input,"XYZ")
    R = R \ S.get("RGB1")
}
//mm_matlist(R,"%18.0g")
virtuallyequal(R, T)
end

/*----------------------------------------------------------------------------*/
// Test all RGB working spaces (confirm that results did not change)

mata:
T =     (  -.1352518516228318  ,   .570348297087347  ,  .5627505097081739)
T = T \ (   .0934691525889328  ,  .1018974288053926  ,   .075686478305183)
T = T \ (  -.2857227432561982  ,  .5130637368997438  ,  .4950128572059819)
T = T \ (   .0534130290562238  ,  .0618191815211114  ,  .0409384527163397)
T = T \ (   .1397327231746135  ,  .5313937099358295  ,  .5572693553242392)
T = T \ (   .0931668276555813  ,  .1001073869846748  ,  .0781544120363015)
T = T \ (   .1731359379287372  ,  .5531753379379178  ,  .5571757165106445)
T = T \ (   .0932679464647435  ,  .1008154141484417  ,  .0770734046989264)
T = T \ (  -.3228247138283149  ,   .570348297087347  ,  .5627674623382313)
T = T \ (   .0913623054044616  ,  .1018974288053926  ,  .0757567688364897)
T = T \ (  -.2796948921946236  ,  .5327267279805842  ,  .5569955350079718)
T = T \ (   .0938479383429725  ,  .0987510188292341  ,  .0779822012264308)
T = T \ (  -.2457988688366239  ,  .5143588922204192  ,  .4972233791201395)
T = T \ (   .0533120833537882  ,  .0619486300211039  ,  .0409638396281911)
T = T \ (   .1371691465469467  ,  .5478501517850016  ,  .5582954771714486)
T = T \ (   .0931506449641046  ,  .1005935035485708  ,  .0777902006722289)
T = T \ (   .0857903157270416  ,  .6032671814333317  ,   .594490346173794)
T = T \ (   .0488963605956262  ,  .0603467406443317  ,  .0310023793748405)
T = T \ (   -.122543531811992  ,  .5500238373682125  ,  .5573492353648846)
T = T \ (   .0918016538990737  ,  .1000696855394529  ,  .0770816622604228)
T = T \ (    -.31138253616304  ,  .5123247741102468  ,  .4941397627721907)
T = T \ (   .0528932151260999  ,  .0620606047808274  ,  .0417751241752437)
T = T \ (   -.344246442451804  ,  .5313422827058496  ,  .5226686939218854)
T = T \ (   .0224339134300207  ,  .0295918154562403  ,   .014773330919645)
T = T \ (     .01340988035922  ,  .5250602546678395  ,  .5156852060297969)
T = T \ (   .0242438672558301  ,  .0304871042078975  ,  .0156605886628426)
T = T \ (  -.3163683377016729  ,  .5313422827058496  ,  .5225642651434101)
T = T \ (   .0227358185045382  ,  .0295918154562403  ,  .0145964465047886)
T = T \ (   .2194577105019934  ,   .461716449935468  ,  .4890561976216512)
T = T \ (   .0542482961697498  ,  .0600389520626142  ,   .044560361212379)
T = T \ (  -.2156800486796168  ,  .4416800047388779  ,  .4227279805883065)
T = T \ (    .027670498853034  ,  .0330935041942331  ,  .0199787858149805)
T = T \ (  -.3762321367841714  ,  .5340908730257931  ,  .5163809571584268)
T = T \ (   .0196567504074958  ,  .0266490990919512  ,  .0132010996551091)
T = T \ (  -.3835243869836369  ,  .5395376523879015  ,  .5220347769038768)
T = T \ (   .0221138442084327  ,  .0299802364784451  ,  .0148512371119977)
T = T \ (  -.4001307851913201  ,  .5755221369488969  ,  .5674524051918982)
T = T \ (   .0608672759716554  ,  .0750403510709697  ,  .0423504057083242)
T = T \ (  -.4001416622556361  ,  .5755161706914378  ,  .5674483424617707)
T = T \ (   .0608669385703879  ,  .0750374910923002  ,  .0423492696681782)
T = T \ (  -.4001046964133452  ,  .5755423529671716  ,  .5675045886363074)
T = T \ (   .0608664440789066  ,   .075037541379668  ,  .0423561197939233)
T = T \ (    .230243665288436  ,  .5324225854748819  ,  .5585585524032631)
T = T \ (   .0949033094798619  ,   .099365057186732  ,  .0768209727511439)
T = T \ (    .230004079026991  ,  .5323007253018559  ,  .5585848792520898)
T = T \ (   .0949157084501879  ,  .0993658147815576  ,  .0768014076146556)
rgbspace = (
"Adobe 1998",
"Apple",
"Best",
"Beta",
"Bruce",
"CIE",
"ColorMatch",
"Don 4",
"ECI v2",
"Ekta PS5",
"Generic",
"HDTV",
"NTSC",
"PAL/SECAM",
"ProPhoto",
"SGI",
"SMPTE-240M",
"SMPTE-C",
"sRGB2",
"sRGB3",
"sRGB",
"Wide Gamut",
"Wide Gamut BL")
R = J(0,3,.)
S = ColrSpace()
Input = (10, 20, 30) \ (0.5, 0.6, 0.4)
for (i=1; i<=length(rgbspace); i++) {
    S.rgbspace(rgbspace[i])
    S.set(Input,"XYZ")
    R = R \ S.get("RGB1")
}
//mm_matlist(R,"%18.0g")
virtuallyequal(R, T)
end

/*----------------------------------------------------------------------------*/
// Test interpolation (confirm that results did not change)

mata:
T =     (   .9999999999999992 ,   .7529411764705889  ,  .7960784313725494)
T = T \ (   .8691519760983997 ,    .766925790646909  ,  .6805554989733742)
T = T \ (   .7298192188195803 ,   .7756662018242904  ,   .565054951593039)
T = T \ (   .5533161267996684 ,   .7867626842178519  ,   .416501092850337)
T = T \ (    .196078431372553 ,   .8039215686274508  ,  .1960784313725496)
T = T \ (   .8420870445208668 ,   .7690653994395849  ,  .6578049271865218)
T = T \ (   .7799513300612819 ,   .7729845211472987  ,  .6075941543611733)
T = T \ (   .7148156309657665 ,    .776501343662152  ,  .5520749547775667)
T = T \ (   .6413268929850862 ,   .7809702060156642  ,  .4887724513610379)
T = T \ (   .5533161267996684 ,   .7867626842178519  ,   .416501092850337)
T = T \ (   1.194873468265182 ,   .6932238904349822  ,  .9506182418215606)
T = T \ (   .9460306655260958 ,   .7603214251689652  ,  .7508429059745241)
T = T \ (   .7298192188195803 ,   .7756662018242904  ,   .565054951593039)
T = T \ (   .3915643888619612 ,   .7964379961557764  ,  .3000386261956365)
T = T \ (  -.5455355484248587 ,   .8294307873429757  , -.2557829584447869)
T = T \ (   .9054057797655873 ,   .7639885585431907  ,  .7136724803052301)
T = T \ (   .8090605737707094 ,   .7713192618479805  ,   .631303008850722)
T = T \ (   .7056191403039956 ,   .7770266132875719  ,  .5441023658708725)
T = T \ (   .5786682923855848 ,   .7850877837490244  ,  .4367701559958627)
T = T \ (    .391564388861961 ,   .7964379961557764  ,  .3000386261956368)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725492)
T = T \ (   .7990196078431369 ,   .7656862745098039  ,  .6460784313725492)
T = T \ (   .5980392156862739 ,   .7784313725490197  ,  .4960784313725491)
T = T \ (   .3970588235294111 ,   .7911764705882354  ,  .3460784313725491)
T = T \ (   .1960784313725479 ,    .803921568627451  ,   .196078431372549)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725492)
T = T \ (   .7990196078431369 ,   .7656862745098039  ,  .6460784313725492)
T = T \ (   .5980392156862738 ,   .7784313725490197  ,  .4960784313725493)
T = T \ (   .3970588235294109 ,   .7911764705882355  ,  .3460784313725491)
T = T \ (   .1960784313725478 ,    .803921568627451  ,  .1960784313725492)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725492)
T = T \ (   .8849579460220172 ,   .7661034841910185  ,  .7055101334131393)
T = T \ (   .7457647326304206 ,   .7789768382957052  ,  .5965621838844821)
T = T \ (   .5600782312710535 ,   .7915778347713245  ,  .4531643836581223)
T = T \ (   .1960784313725477 ,    .803921568627451  ,  .1960784313725493)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725492)
T = T \ (   .8849579460220173 ,   .7661034841910185  ,  .7055101334131393)
T = T \ (   .7457647326304205 ,   .7789768382957053  ,  .5965621838844821)
T = T \ (   .5600782312710532 ,   .7915778347713246  ,  .4531643836581223)
T = T \ (   .1960784313725479 ,    .803921568627451  ,   .196078431372549)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725489)
T = T \ (   .7956553629246332 ,   .8009192072124669  ,  .6362600488712371)
T = T \ (   .6104909037210627 ,   .8178930661893289  ,  .4929676744857784)
T = T \ (   .4265920821677862 ,   .8169235557441333  ,  .3540295507905734)
T = T \ (   .1960784313725479 ,    .803921568627451  ,   .196078431372549)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725492)
T = T \ (   .8487991677799847 ,   .7791837238700844  ,  .6572009367494843)
T = T \ (   .6852137065454543 ,   .7954152571512038  ,  .5170263753867106)
T = T \ (   .4944436369232061 ,   .8032713328986882  ,  .3703771585317109)
T = T \ (   .1960784313725485 ,    .803921568627451  ,  .1960784313725493)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725492)
T = T \ (   1.060855129012005 ,   .6952992384682555  ,  .5997043431640492)
T = T \ (   .9812558455753625 ,   .7024357753529044  ,  .3494627412538779)
T = T \ (   .7350401810548404 ,    .756742537306096  ,  .1189989135637145)
T = T \ (   .1960784313725484 ,    .803921568627451  ,  .1960784313725495)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725491)
T = T \ (   .8519072956785885 ,     .77627616257819  ,  .6797416271838898)
T = T \ (   .6910914871717972 ,   .7916957480453706  ,  .5543350261692406)
T = T \ (   .5015202868752804 ,   .8005732577265944  ,  .4090483114776163)
T = T \ (   .1960784313725483 ,    .803921568627451  ,  .1960784313725482)
T = T \ (   .9999999999999999 ,   .7529411764705882  ,  .7960784313725491)
T = T \ (   .9889182521065484 ,   .7286347379553066  ,  .6141958599694194)
T = T \ (   .8884406730199141 ,   .7408973652958443  ,  .3565091816654695)
T = T \ (   .6823078272000844 ,   .7722944074921573  , -.0870988320649893)
T = T \ (    .196078431372549 ,    .803921568627451  ,  .1960784313725482)
T = T \ (   .9999999999999992 ,   .7529411764705889  ,  .7960784313725494)      // "CAM02 JCh"
T = T \ (    1.04350536953997 ,     .68499649289585  ,  .5584028969071891)      // "CAM02 JCh"
T = T \ (   .9708673947158318 ,   .6841061909196277  ,  .2620969345794703)      // "CAM02 JCh"
T = T \ (   .7502542103205839 ,   .7391904861234038  , -.0468628291697285)      // "CAM02 JCh"
T = T \ (    .196078431372553 ,   .8039215686274508  ,  .1960784313725496)      // "CAM02 JCh"
T = T \ (   .9999999999999992 ,   .7529411764705889  ,  .7960784313725494)      // "Jab 1.1 0.008 0.03"
T = T \ (   .8699215960785107 ,   .7656345518614488  ,  .6868433400425207)      // "Jab 1.1 0.008 0.03"
T = T \ (   .7357885443916489 ,   .7723046766455516  ,   .575170135846235)      // "Jab 1.1 0.008 0.03"
T = T \ (   .5629621771099094 ,   .7834893065261311  ,  .4266072649451947)      // "Jab 1.1 0.008 0.03"
T = T \ (   .1960784313725533 ,   .8039215686274508  ,  .1960784313725492)      // "Jab 1.1 0.008 0.03"
T = T \ (   .9999999999999992 ,   .7529411764705889  ,  .7960784313725494)      // "Jab UCS"
T = T \ (   .8691519760983997 ,    .766925790646909  ,  .6805554989733742)      // "Jab UCS"
T = T \ (   .7298192188195803 ,   .7756662018242904  ,   .565054951593039)      // "Jab UCS"
T = T \ (   .5533161267996684 ,   .7867626842178519  ,   .416501092850337)      // "Jab UCS"
T = T \ (    .196078431372553 ,   .8039215686274508  ,  .1960784313725496)      // "Jab UCS"
T = T \ (   .9999999999999992 ,   .7529411764705889  ,  .7960784313725494)      // "Jab LCD"
T = T \ (    .861270116690832 ,   .7727945971692519  ,  .6554458967106757)      // "Jab LCD"
T = T \ (   .7033743632168371 ,   .7876079951449787  ,  .5276290185468969)      // "Jab LCD"
T = T \ (   .5171729131569732 ,   .7971212854141276  ,  .3818253499356336)      // "Jab LCD"
T = T \ (    .196078431372553 ,   .8039215686274508  ,  .1960784313725496)      // "Jab LCD"
T = T \ (   .9999999999999992 ,   .7529411764705889  ,  .7960784313725494)      // "Jab SCD"
T = T \ (   .8705794830895147 ,   .7652151896919741  ,  .6917425235771134)      // "Jab SCD"
T = T \ (   .7404005027766711 ,   .7704010830948774  ,   .583143757522842)      // "Jab SCD"
T = T \ (   .5704109208487492 ,   .7813900653484392  ,  .4346449324834392)      // "Jab SCD"
T = T \ (    .196078431372553 ,   .8039215686274508  ,  .1960784313725496)      // "Jab SCD"
T = T \ (                  1 ,   .7529411764705882 ,   .7960784313725489)       // "HSV"
T = T \ (  .9509803921568627 ,   .7263805498287313 ,   .5950108307311447)       // "HSV"
T = T \ (  .9019607843137255 ,   .8624652092624076 ,   .4495569246349903)       // "HSV"
T = T \ (  .6081729320135515 ,   .8529411764705883 ,   .3165794581821251)       // "HSV"
T = T \ (   .196078431372549 ,    .803921568627451 ,    .196078431372549)       // "HSV"
T = T \ (                    1 ,   .7529411764705882  ,  .7960784313725489 )    // "HSL"
T = T \ (    .9786620530565167 ,   .7309386499697921  ,  .5860438292964244 )    // "HSL"
T = T \ (    .9388696655132641 ,   .8951081086029185  ,    .43760092272203 )    // "HSL"
T = T \ (    .6191300049431536 ,   .8806228373702423  ,  .3076124567474048 )    // "HSL"
T = T \ (     .196078431372549 ,    .803921568627451  ,   .196078431372549 )    // "HSL"

S = ColrSpace()
S.rgbspace("sRGB2")
S.colors("Pink LimeGreen")
Input = S.get("RGB1")

S.set(Input,"RGB1")
S.ipolate(5)
R = S.get("RGB1")

S.set(Input,"RGB1")
S.ipolate(5, "", (.3, .75))
R = R \ S.get("RGB1")

S.set(Input,"RGB1")
S.ipolate(5, "", ., ., ., 1)
R = R \ S.get("RGB1")

S.set(Input,"RGB1")
S.ipolate(5, "", (.3, .75), ., ., 1)
R = R \ S.get("RGB1")

spaces = (
"CMYK1",
"RGB1",
"lRGB",
"XYZ",
"xyY",
"Lab",
"LCh",
"Luv",
"HCL",
"CAM02 JCh",
"Jab 1.1 0.008 0.03",
"Jab UCS",
"Jab LCD",
"Jab SCD",
"HSV",
"HSL"
)
for (i=1; i<=length(spaces); i++) {
    S.set(Input,"RGB1")
    S.ipolate(5, spaces[i])
    R = R \ S.get("RGB1")
}
//mm_matlist(R,"%18.0g")
virtuallyequal(R, T)

end

/*----------------------------------------------------------------------------*/
// Test S.intensify()

local intensity 0.01 0.1 0.5 1 2 10 100
gr_setscheme, refscheme    // required so that .color.new works
mata: S = ColrSpace()
mata: S.palette("s2")
mata: st_local("s2names", S.names())
foreach i of local intensity {
    local Test
    local space
    foreach c of local s2names {
        .mycolor = .color.new , style(`c'*`i')
        local Test `"`Test'`space'"`.mycolor.setting'""'
        local space " "
    }
    mata: S.palette("s2")
    mata: S.intensify(`i')
    mata: assert(S.colors()==st_local("Test"))
    mata: st_local("tmp", S.colors())
}

/*----------------------------------------------------------------------------*/
// comparison to some results from https://gka.github.io/chroma.js/

// chroma.mix()
mata:
S = ColrSpace()
S.rgb_gamma(2) // lrgb: chroma.js uses simple gamma correction with gamma=2
S.colors("Red Blue"); S.mix("lRGB");           assert(S.get("HEX")=="#b400b4")
S.colors("Red Blue"); S.mix("lRGB",(.75,.25)); assert(S.get("HEX")=="#dd0080")
S.colors("Red Blue"); S.mix("lRGB",(.25,.75)); assert(S.get("HEX")=="#8000dd")
S = ColrSpace()
S.colors("Red Blue"); S.mix("RGB"); assert(S.get("HEX")=="#800080")
S.colors("Red Blue"); S.mix("HSL"); assert(S.get("HEX")=="#ff00ff")
S.colors("Red Blue"); S.mix("Lab"); assert(S.get("HEX")=="#ca0088")
S.colors("Red Blue"); S.mix("LCh"); assert(S.get("HEX")=="#fa0080")
end

// comparison to chroma.average()
mata:
S = ColrSpace()
S.rgb_gamma(2) // lrgb: chroma.js uses simple gamma correction with gamma=2
S.colors("#ddd Yellow Red Teal"); S.mix("lrgb"); assert(S.get("HEX")=="#d3b480")
S = ColrSpace()
S.colors("#ddd Yellow Red Teal"); S.mix("lab"); assert(S.get("HEX")=="#d3a96a")
S.colors("#ddd Yellow Red Teal"); S.mix("lch"); assert(S.get("HEX")=="#ef9e4e")
S = ColrSpace()
S.rgb_gamma(2) // lrgb: chroma.js uses simple gamma correction with gamma=2
S.Colors("red" \ "rgba 0 0 0 .5"); S.mix("lrgb"); assert(S.get("rgba")==(180,0,0,0.75))
end


capture noisily log close
exit



