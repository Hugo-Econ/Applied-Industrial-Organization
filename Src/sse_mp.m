function [obj,s] = sse_mp(P,C,delta,alpha,Own)
%check deviation from FOCs
s = exp(delta-alpha.*P)./(1+sum(exp(delta-alpha.*P)));
Der_j = s - alpha.*s.*(1-s) .* (P-C);
Der_mp_1 =  alpha*s(1)*s(2)* (P(2)-C(2)); %Cross price derivation + (P-C). 
Der_mp_2 = alpha * s(1) * s(2) * (P(1) - C(1));
Spillover= [Der_mp_1;Der_mp_2;0];
Der_spillover = Spillover+Der_j;
%dev_FOC = Own*Der_spillover; %Should be zero at the optima
obj = sum(Der_spillover.^2); % the three FOCs should be zeros. 
% fminunc is know to minimize **obj**.
end
