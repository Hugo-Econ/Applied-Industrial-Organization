**Demand Estimation**
// This Stata code establishes the foundation for demand estimation, following the typical IO framework:
// ln(share_i) - ln(share_o) = alpha * price + Beta * Promotion + FEs.
// We explore the importance of brand and time fixed effects for proper estimation and extend to cases where TWFE is insufficient. 

// This is particularly relevant for estimating price elasticity, as price is endogenously determined. To address this, we seek exogenous "shocks" to price—factors outside the firm's profit maximization process. 

// Below, we implement IV estimation to correct for endogeneity and compare elasticity estimates across different approaches.



clear

quietly cd "$base_path"
insheet using "Data/OTC.csv", clear

// Summarize the dataset
sum
list in 1/5  // Display the first 5 rows for an initial check

// Count the number of unique stores
// `nvals` is 1 only for the first occurrence of each store
by store, sort: gen nvals = _n == 1
count if nvals == 1  // Count unique stores
scalar Nstore = r(N)  // Store the count as a scalar
drop nvals  // Drop the temporary variable
// 73 unique stores

// Count the number of unique weeks
by week, sort: gen nvals = _n == 1
count if nvals == 1  // Count unique weeks
scalar Nweek = r(N)  // Store the count as a scalar
drop nvals  // Drop the temporary variable
// 48 unique weeks

// Each store-week combination defines a market, so we have 73 × 48 = 3,504 unique markets

// Generate a unique market ID (each store-week pair is a market)
egen market = group(store week)

// Calculate total sales within each market
by market, sort: egen total_sales = sum(sales_)

// Compute the market share of each brand within a market
gen s_j = sales_ / total_sales

// Define brands 10 and 11 as the outside option
sort market brand 
by market: gen s_0 = s_j[10] + s_j[11]
// We need an outside option to compare against the brands in the market

// Generate the dependent variable for OLS regressions
gen y_j = ln(s_j) - ln(s_0) 

// Analyze the impact of price and promotion on market share
// OLS regression without a constant term
reg y_j price_ prom_ if brand <= 9  
// Brands 10 and 11 are omitted as they form the outside option

// Store the estimated coefficient of price
scalar a1 = _b[price]

// Interpretation:
// - A 1% increase in price leads to a 5% decrease in market share, which is substantial.
// - Promotion increases sales by only 15%.

// Question: What is the issue with this regression?
// - Promotion is likely correlated with unobserved factors like demand shocks.
// - Promotion is more likley to happen on new, unkown products, tah known brands. 


// Solution: control the (currently unobserved) brands. 


// Generate dummy variables for brand and store
tabulate brand, generate(Dbrand)
qui tabulate week, generate(Dweek)

// OLS with brand fixed effects
// Fixed effects control for time-invariant brand characteristics (e.g., Nutella's brand strength)
reg y_j price_ prom_ Dbrand1-Dbrand9 if brand <= 9, noc
scalar a2 = _b[price]

// Interpretation:
// - After controlling for brand fixed effects, promotion increases sales by approximately 40% (more precisely, exp(0.40) > 40%).
// - Price elasticity is even more significant when controlling for brand characteristics. That is likely due because emerging brands have more to gain from promotions. 

// Issue: Promotion is not independent of time. 
// - Are we capturing the effect of promotion, or simply the time when promotions occur?
// - Example: If promotions always happen during the Super Bowl, high sales might be due to the event, not the promotion itself.

// OLS with week fixed effects
// This accounts for time-specific factors that affect all brands similarly
reg y_j price_ prom_ Dweek* if brand <= 9, noc
scalar a3 = _b[price]

// Calculate price elasticity (Price Elasticity of Demand)
// Remember the equation:
// eta= (ds/dp)*p/s, where eta stand for elasticity.
// ds/dp = -alpha*s(1-s), so if you multiply by p/s, we then get:
// (ds/dp)*p/s= -alpha*s*(1-s)*p/s. As s/s is 1 and eta= (ds/dp)*p/s, we thus have:
// eta = -alpha*p*(1-s)
gen eta1 = a1 * price_ * (1 - s_j)
gen eta2 = a2 * price_ * (1 - s_j)
gen eta3 = a3 * price_ * (1 - s_j)

// Summarize elasticity estimates by brand
// That leas us to a brand-specic elasticity, which we print here for each of the three models. 
by brand, sort: sum eta*


// Optional: Recall that market shares in a logit model are determined by the following function:
// s_i = exp(V_i) / sum_k exp(V_k), where V_i represents the indirect utility:
// V_i = X_i * Beta - alpha * p_i. (or whatever you want)

// To compute own-price elasticity, we use the formula:
// eta = (ds/dp) * (p/s). This requires calculating ds_i/dp_i. 

// Try deriving it! Hint: ds_i/dp_i = -alpha * s_i * (1 - s_i).

// For cross-price elasticity (impact of product j's price on product i's demand):
// ds_i/dp_j. Hint: This is crucial in equilibrium analysis in IO models. See SSE_MP, from Equilibrium. 
// If a firm owns multiple products, increasing the price of one product may increase demand for its other products. 

// Consider this next time you see multiple "competing" brands that are actually owned by the same parent company. (P&G). 

***********************************
// IV regression 

// Question: Why instrument prices?
// - Prices may be endogenous: Firms set prices based on expected demand.
// Example: If firms anticipate higher demand, they might increase prices in advance.
// - This simultaneity bias leads to misleading estimates if not accounted for.

// - Instruments must satisfy:
//   - **Relevance:** Costs should be correlated with prices (higher costs → higher prices).
//   - **Exogeneity:** Costs should not be correlated with demand shocks affecting the error term.

// Conceptually, consider a firm purchasing a good at cost q and setting its price through an unknown function f() to maximize profit -- simply assume f() is stricly increasing in q, if you seek rigor. If external factors, such as exchange rate fluctuations (e.g., USD-CAD affecting car prices), shift cost from q to q', the resulting price change is independent of demand. This exogenous variation, which firms do not set to manipulate profits or respond to demand, serves as an Instrumental Variable (IV). We, thus, have random change in prices due to this IV, letting us properly estimate how a change in price cahnge the demand.

// It is always useful to remind ourselves why Two-Stage Least Squares (2SLS) actually works. 

// Let's consider the basic regression model:
// y = alpha * x + e

// The issue arises because x, the endogenous variable, is correlated with the error term (e), leading to biased estimates of alpha. 
// To correct for this, we use an instrumental variable (IV), z, which satisfies two conditions:

// 1. **Relevance**: Cov(x, z) ≠ 0  --> The instrument must be correlated with x; otherwise, it has no predictive power.
// 2. **Exogeneity**: Cov(z, e) = 0  --> The instrument must be uncorrelated with the error term, meaning z influences y only through x.

// A more rigorous way to express exogeneity is: Cov(z, e | X) = 0, but we often simplify it as Cov(z, e) = 0. 
// If these conditions hold, 2SLS provides an unbiased estimate of alpha.

// If we estimate y = alpha * x + e directly, we obtain a biased alpha, since x is chosen to maximize y (e.g., firms set prices strategically). 
// Instead, we isolate only the random part of x by regressing it on z:

// First-stage regression:
// x = Beta * z + chi

// This gives us the predicted values of x: 
// \hat{x} = Beta * z

// Since \hat{x} is predicted using z (which is random), it is exogenous, meaning it no longer contains the endogenous component of x. 
// The second stage regression is then:

// y = alpha * \hat{x} + e

// Here, alpha is now estimated using **only the exogenous variation** in x, allowing us to correctly measure how consumers react to changes in price.

// Lets use cost as an instrument for price

ivregress 2sls y_j (price_ = cost_) prom_ if brand <= 9 
ivregress 2sls y_j (price_ = cost_) prom_ Dbrand1-Dbrand9 if brand <= 9, noc //Weird result. Think why it could be the case. 
ivregress 2sls y_j (price_ = cost_) prom_ Dweek* if brand <= 9, noc 

***********************************

// Generate the sum of brand j's prices across all markets
sort brand 
by brand: egen p_total = sum(price_)

// Compute the total price of a brand in all other markets
gen p_other = p_total - price_

// Compute the mean price of a brand in other markets
// 48 weeks × 73 stores = 3,504 markets
gen p_mean = p_other / (Nstore * Nweek - 1)

// NOTE: The following regressions will generate errors because `p_mean` is not a valid IV
// `p_mean` is likely endogenous because price setting is correlated across markets.
ivregress 2sls y_j (price_ = p_mean) prom_ if brand <= 9  
ivregress 2sls y_j (price_ = p_mean) prom_ Dbrand1-Dbrand9 if brand <= 9, noc 
ivregress 2sls y_j (price_ = p_mean) prom_ Dweek* if brand <= 9, noc
