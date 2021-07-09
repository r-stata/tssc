
help hrimvol
                                                                                                                                               
>-----------------------------------  

Title

hrimvol -- A simple option implied volatility caculator


Syntax

        hrimvol <s0> <k> <time> <r> <d> <C>

Description

We use bisection algorithm to compute the European call option implied volatility. If you want to compute put option volatility, you can use 
call-put parity to compute the corresponding call price.

There are 6 parameters in our codes, s0 denotes current price, k denotes strike price, time denotes maturity, r denotes risk-free rate, d detones 
dividend, C denotes the trading price of call option. 


Examples

if we want to compute the implied volatility of a call option. 

s0=49.55,k=53,time=0.046,r=0.047,d=0.02,C=0.6

the corresponding codes to compute the implied volatility should be:

hrimvol 49.55 53 0.046 0.047 0.02 0.6
    

Authors
        
        Zhiyong Li
        University of International Business and Economics
        Beijing,China
        lizhiyong618@foxmail.com

Acknowledgement

Special thanks to HR, she is really an amazing and attractive girl. Wish her happy everyday.
