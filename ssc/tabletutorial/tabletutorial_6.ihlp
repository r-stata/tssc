        matrix X = 1                        /*the constant*/
        foreach v of varlist weight mpg  {  /*reverse order*/
            summarize `v'
            matrix X = r(mean), X
        }
        matrix b = e(b)'
        matrix Y = X * b
        display Y[1,1]
