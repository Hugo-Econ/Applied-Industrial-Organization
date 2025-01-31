function [obj,s] = sse(P,C,delta,alpha,Own)
%check deviation from FOCs
s = exp(delta-alpha.*P)./(1+sum(exp(delta-alpha.*P)));
Der_j = s - alpha.*s.*(1-s) .* (P-C);
dev_FOC = Own*Der_j; %Should be zero at the optima
obj = sum(dev_FOC.^2); %Squared error function (should be zero). 
% fminunc is know to minimize **obj**.
end