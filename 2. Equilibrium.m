% Finding equilibrium prices. 

% A) eqm prices under Bertrand competition 
% each firm max_pj (p_j-c_j)*sales_j -> FOC_j: p_j=c_j+1/(alpha*(1-s_j);
% eqm is where FOC_j = 0 for all j 
% transform it to sum_j FOC_j^2 = 0 so can use fminunc

% B) a firm owns multiple products \max \sum_{j\in Set_j}(p_j-c_j)*sales_j
% P_1 = s_1-alpha*s_1*(1-s_1)* (p_1-p_2) + (p_2-c_2) * alpha*s_1*s_2;
% P_2 symmetric. 
% P_3 No Spillover. 

clear;clc;
Startup % Calls useful functions from the Src directory concisely.  

%% Setting
%Reproductability 
% Choose a seed value
seed = 123;  % You can use any positive integer as the seed

% Set the random number generator to use the specified seed
rng(seed);

J = 3; %number of products
P = cumsum(ones(J,1)); %prices
C = zeros(J,1); %costs

delta = rand(J,1); %vertial differentiation except price. Random vector, aka, need to set seed. 
%delta = ones(J,1); %Homegenous goods (i.e.gasoline).
alpha = 0.2; %price coefficient

%find eqm prices
options = optimset('Display','iter')
%The options parameter is used to set optimization options, such as 
% the display of iteration output.

%% Multiproducts firm with marketpower
Own = [1,1,0;0,0,1]; %ownership matrix, here 1 firm owns products 1 and 2
% % Calculate the number of products owned by the first entity
% products_owned_by_first = floor(2*J/3);
% 
% % Initialize the ownership matrix with zeros
% Own = zeros(2, J);
% 
% % Set the first entity's ownership
% Own(1, 1:products_owned_by_first) = 1;
% 
% % Set the second entity's ownership for the remaining products
% Own(2, products_owned_by_first+1:end) = 1;

P_eqm = fminunc(@(x) sse_mp(x,C,delta,alpha,Own),ones(J,1),options)
%The function fminunc is used to find the prices P_eqm that minimize the 
% objective function obj. It uses an unconstrained optimization algorithm 
% to find the set of prices that bring the sum of squared deviations from the 
% FOCs as close to zero as possible.

% @(x) is substitutating Price in sse(P,C,delta,alpha,Own). 

%The sse function, together with the fminunc optimization, is designed to 
% find the equilibrium prices in a market where firms choose prices to 
% maximize profits, and the market shares depend on those prices through a 
% logit model. The objective is to find the price vector that makes the 
% firms' pricing strategies consistent with the FOCs from their profit 
% maximization problems, indicating that no firm can unilaterally change 
% its price to increase profit.

%eqm market shares 
[obj,mktshare] = sse_mp(P_eqm,C,delta,alpha,Own)

%Consumer Surplus
CS_mp = (1 / alpha) * log(1 + sum(exp(delta - alpha .* P_eqm)))
%Firm profit. Firm 1 owns two products !
Profits_mp = Own*((P_eqm-C).*mktshare)
Total_Profits_mp =sum(Profits_mp);
%social welfare
SS_mp= CS_mp+Total_Profits_mp

%% Competitive market:
P = cumsum(ones(J,1)); %prices
Own1 = eye(J); %no collusion nor multiproduct firm 
P_eqm1 = fminunc(@(x) sse(x,C,delta,alpha,Own1),ones(J,1),options)
%eqm market shares 
[obj1,mktshare1] = sse(P_eqm1,C,delta,alpha,Own1)

%Consumer Surplus
CS_em = (1 / alpha) * log(1 + sum(exp(delta - alpha .* P_eqm1)))
%Firm profit. Firm 1 owns two products !
Profits_em = Own1*((P_eqm1-C).*mktshare1)
Profits_em_quasi2productfirm = Own*((P_eqm1-C).*mktshare1)
Total_Profits_em =sum(Profits_em);
%social welfare
SS_em= CS_em+Total_Profits_em

%% compare consumer surplus, firm profit and social welfare
%Consumer Surplus
CS_delta = CS_em-CS_mp
%Firm profit. Profit loss!
Total_Profits_delta = Total_Profits_em-Total_Profits_mp
Delta_ownership= Profits_em_quasi2productfirm -Profits_mp
%social welfare (gain)
SS_delta= SS_em-SS_mp