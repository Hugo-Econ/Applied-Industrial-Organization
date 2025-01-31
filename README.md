# Applied Industrial Organization
If you are new to the consulting world or simply want to learn the essential tools for solving economic problems, this is for you. This repository contains some of the most useful code from a course I TAed, with modifications and clarifications for better understanding.  

In short: **Simple** Demand and Supply Estimation, and an Introduction to Empirical Auctions. 

## Src
Stores all MATLAB functions.

## Data
Stores datasets.
  
## 1. Optimization
This MATLAB script optimizes a firm's profit by determining the optimal price for a product while considering competition in a logit demand model. It also visualizes profit and market share as functions of price and then numerically optimizes the firm's pricing decision using _fminunc_.

Summary: 
- Defines a two-product market with logit demand.
- Computes firm profit based on the logit demand model.
- Simulates profit and market share across a range of prices.
- Optimizes price to maximize firm profit using fminunc.
- (Homework) compares economic outcomes like consumer surplus and social welfare.
_Hint:_

Consumer Surplus (CS) → Using the logit model formula
Firm Profit (π) → Using the optimized price
Social Welfare (SW) → The sum of CS + π

## 2. Equilibrium
This MATLAB script computes equilibrium prices under Bertrand competition in a logit demand model. It solves for profit-maximizing prices, considering both competitive and multi-product firm settings.

Summary:
- Solves Bertrand equilibrium using first-order conditions (FOCs).
- Models multi-product firms, where firms internalize pricing spillovers.
- Computes economic outcomes:
- Market shares (logit model)
- Consumer surplus (CS)
- Firm profits (with and without market power)
- Social welfare (CS + total profits)
- Compares competitive vs. market power scenarios, analyzing the impact on prices, welfare, and firm profits.

## 3. Ascending Auction
This MATLAB script estimates bidders' private value distribution using moment matching in an ascending (English) auction. It simulates bidding behavior and explores the effect of reserve prices on seller revenue.

Summary:
- Estimates private value distribution from observed winning bids using moment matching.
- Simulates ascending auctions with bidders drawing values from a uniform or beta distribution.
- Computes economic outcomes:
    Winning bids (second-highest valuation).
    Expected seller revenue at different reserve prices.
    Optimal reserve price maximizing seller profits.
- Counterfactual analysis:
    Simulates revenue implications of different reserve price policies.
    Numerically optimizes the reserve price.
- Compares revenue outcomes across reserve price settings, analyzing the trade-off between auction participation and revenue maximization.


