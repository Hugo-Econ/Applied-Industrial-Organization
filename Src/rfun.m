function ER = rfun(r,x_hat,Draws)
%calculate the expected revenue 
    sumtab = AscendAuc(r,x_hat,Draws);
    ER = -sumtab(1);
end
