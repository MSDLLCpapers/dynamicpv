# Budget Impact Applications

## Introduction

Our objective is to evaluate the budget impact of introducing a new
intervention, assuming static or dynamic pricing. Uptake in budget
impact models is already modeled in a dynamic fashion.

## Methods and Assumptions

### General assumptions

Budget impact models conventionally have no discounting and a shorter
time horizon than cost-effectiveness models, so we will use a time
horizon of 5 years here and a discount rate of 0%. We will compute a
budget impact model using current pricing (per convention) as well as by
using dynamic pricing according to the assumptions previously set.

### Dynamic pricing

To recap, we had the following assumptions concerning pricing, with a
date of calculation of 2025-09-01.

- Costs are assumed to increases in line with general inflation (2.5%
  per year), except for effects on drug acquisition costs due to LoEs.
- The LoE for the SoC is assumed to occur first, at 2028-01-01, after
  which there is anticipated to be a 70% reduction in prices over one
  year.
- The new intervention has an LoE occuring three years later, at
  2031-01-01, after which there would be a 50% reduction in prices over
  one year.

### Dynamic uptake

We had the following assumptions concerning patient uptake.

- Only newly incident patients with the cancer being modeled would be
  eligible for the new treatment. Existing/prevalent patients with the
  condition would not be eligible.
- The disease incidence is 1 patient per week.
- Among these patients, were the new intervention to be made available,
  uptake of the new intervention would be expected to rise linearly from
  0% to 100% after 2 years.

## Implementation

### Set-up

First we load the packages necessary for this vignette.

``` r
library(dplyr)
library(lubridate)
library(heemod)
library(dynamicpv)
```

The underlying health economic model is built as described in
[`vignette("cost-effectiveness-applications")`](https://MSDLLCpapers.github.io/dynamicpv/articles/cost-effectiveness-applications.md).
We require additional coding for the budget impact evaluation.

``` r
# BIM settings
bi_horizon_yrs <- 5
bi_horizon_wks <- round(bi_horizon_yrs / cycle_years)
bi_discount <- 0

# Newly eligible patients
newly_eligible <- rep(1, Ncycles)

# Time for uptake to occur
uptake_years <- 2
uptake_weeks <- round(uptake_years / cycle_years)

# Market share of new intervention
share_multi <- c((1:uptake_weeks)/uptake_weeks, rep(1, Ncycles-uptake_weeks))

# Newly eligible patients receiving each intervention, "world with"
uptake_new <- newly_eligible * share_multi
uptake_soc <- newly_eligible - uptake_new
```

## Results

### Scenario 1: No dynamic uptake or pricing

This scenario assumes static uptake, i.e. that uptake is immediate and
100% of eligible patients. This is an unconventional approach for a
budget impact analysis. The analysis also assumes static prices, i.e. we
assume the prices of existing resources remain unchanged from now in the
horizon of the budget impact model. First we calculate costs with the
SoC, in the ‘world without’ the new intervention.

``` r
# World without new intervention

# SoC, drug acquisition costs
wout1_soc_daqcost <- dynpv(
    uptakes = newly_eligible,
    payoffs = hemout_soc$cost_daq_soc_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# SoC, other costs
wout1_soc_othcost <- dynpv(
    uptakes = newly_eligible,
    payoffs = hemout_soc$cost_nondaq_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# Total budgetary costs
budget_wout1_soc <- wout1_soc_daqcost + wout1_soc_othcost
budget_wout1_new <- 0
budget_wout1 <- budget_wout1_soc
```

The total budgetary costs in the world without are \$12,923,366 in
respect of 522 patients.

Next we calculate costs with the new treatment, in the ‘world with’ the
new intervention.

``` r
# World with: SoC are zero

# New intervention, drug acquisition costs
with1_new_daqcost <- dynpv(
    uptakes = newly_eligible,
    payoffs = hemout_new$cost_daq_new_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# New intervention, other costs
with1_new_othcost <- dynpv(
    uptakes = newly_eligible,
    payoffs = hemout_new$cost_nondaq_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# Total
budget_with1_soc <- 0
budget_with1_new <- with1_new_daqcost + with1_new_othcost
budget_with1 <- budget_with1_new
```

The budgetary costs in the world with the new intervention are
\\32,381,279\\. Finally, we derive the budget impact as the difference
in costs.

``` r
# Budget impact
bi1 <- budget_with1 - budget_wout1
summary(bi1)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             261 
#>      Number of times:               1 
#>      Total uptake:                  0 
#>      Total present value:           19457914 
#>      Mean present value:            Inf
```

The total budget impact is \$19,457,914, representing an increase of
151%.

### Scenario 2: Dynamic pricing, no dynamic uptake

Scenario 2 adjusts scenario 1 by assuming instead dynamic pricing of the
new intervention and SoC. Uptake remains modeled in the unconventional
static manner. As before, we first calculate the costs of the SoC in the
‘world without’ the new intervention.

``` r
# World without new intervention

# SoC, drug acquisition costs
wout2_soc_daqcost <- dynpv(
    uptakes = newly_eligible,
    payoffs = hemout_soc$cost_daq_soc_rup,
    horizon = bi_horizon_wks,
    prices = prices_dyn_soc,
    discrate = bi_discount
    )

# SoC, other costs
wout2_soc_othcost <- wout1_soc_othcost

# Total budgetary costs
budget_wout2_soc <- wout2_soc_daqcost + wout2_soc_othcost
budget_wout2_new <- 0
budget_wout2 <- budget_wout2_soc
```

The total budgetary costs in the world without are \$11,516,132 in
respect of 522 patients.

Next we derive the costs of the new intervention, in the ‘world with’
the new intervention.

``` r
# World with: SoC are zero

# New intervention, drug acquisition costs
with2_new_daqcost <- dynpv(
    uptakes = newly_eligible,
    payoffs = hemout_new$cost_daq_new_rup,
    horizon = bi_horizon_wks,
    prices = prices_dyn_new,
    discrate = bi_discount
    )

# New intervention, other costs
with2_new_othcost <- with1_new_othcost

# Total
budget_with2_soc <- 0
budget_with2_new <- with2_new_daqcost + with2_new_othcost
budget_with2 <- budget_with2_new
```

The budgetary costs in the world with the new intervention are
\\34,359,885\\. Finally again, we derive budget impact as the
difference.

``` r
# Budget impact
bi2 <- budget_with2 - budget_wout2
summary(bi2)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             261 
#>      Number of times:               1 
#>      Total uptake:                  0 
#>      Total present value:           22843753 
#>      Mean present value:            Inf
```

The total budget impact is \$22,843,753, representing an increase of
198%.

### Scenario 3: Dynamic uptake, not dynamic pricing

This scenario includes dynamic uptake, which is conventional in budget
impact analysis, but assumes static prices, i.e. we assume the prices of
existing resources remain unchanged from now in the horizon of the
budget impact model. Let us use that function to calculate budgetary
costs for the world without the new intervention.

``` r
# World without new intervention
# SoC, drug acquisition costs
wout3_soc_daqcost <- wout1_soc_daqcost
# SoC, other costs
wout3_soc_othcost <- wout1_soc_othcost
# Total budgetary costs
budget_wout3 <- budget_wout3_soc <- wout3_soc_daqcost + wout3_soc_othcost
```

The total budgetary costs in the world without are \$12,923,366 in
respect of 522 patients.

Let us now calculate the budgetary costs in the world with the new
intervention.

``` r
# World with

# SoC, drug acquisition costs
with3_soc_daqcost <- dynpv(
    uptakes = uptake_soc,
    payoffs = hemout_soc$cost_daq_soc_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# SoC, other costs
with3_soc_othcost <- dynpv(
    uptakes = uptake_soc,
    payoffs = hemout_soc$cost_nondaq_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# New intervention, drug acquisition costs
with3_new_daqcost <- dynpv(
    uptakes = uptake_new,
    payoffs = hemout_new$cost_daq_new_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# New intervention, other costs
with3_new_othcost <- dynpv(
    uptakes = uptake_new,
    payoffs = hemout_new$cost_nondaq_rup,
    horizon = bi_horizon_wks,
    prices = prices_static,
    discrate = bi_discount
    )

# Total
budget_with3_soc <- with3_soc_daqcost + with3_soc_othcost
budget_with3_new <- with3_new_daqcost + with3_new_othcost
budget_with3 <- budget_with3_soc + budget_with3_new
#> Warning in addprod(e1, e2, mult = 1): Uptake vectors differ in length
```

Note the warning provided by `dynamicpv`. This is because the uptake
vector for SoC, when trimmed of zeroes after uptake stops, has a
different (shorter) length than the uptake vector for the new
intervention. The calculation is still correct. However, the function is
flagging for the user the different uptake vectors being used for
different present value calculations.

``` r
# The uptake vector for the new intervention is long
length(trim_vec(uptake_new))
#> [1] 1044

# The uptake vector for the SoC is short, once trimmed of excess zeros
length(trim_vec(uptake_soc))
#> [1] 103
```

The budgetary costs in the world with the new intervention are
\$26,964,789, comprising \$3,508,178 in respect of the costs of 103
patients being treated with the SoC, and \$23,456,610 in respect of the
costs of 419 patients being treated with the SoC.

``` r
# Budget impact
bi3_soc <- budget_with3_soc - budget_wout3_soc
#> Warning in addprod(e1, e2, mult = -1): Uptake vectors differ in length
bi3_new <- budget_with3_new
bi3 <- budget_with3 - budget_wout3

summary(bi3)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             261 
#>      Number of times:               1 
#>      Total uptake:                  0 
#>      Total present value:           14041423 
#>      Mean present value:            Inf
```

The total budget impact is \$14,041,423, representing an increase of
109%.

### Scenario 4: Dynamic pricing and uptake

Now let us recalculate the budget impact, assuming dynamic pricing in
drug acquisition costs. This is simple with `dynamicpv()::dynpv()`
because we just change the `prices` argument from `prices_static` to
either `prices_dyn_soc` or `prices_dyn_new` for the drug acquisition
costs. We will keep other costs unchanged.

``` r
# World without new intervention

# SoC, drug acquisition costs
wout4_soc_daqcost <- dynpv(
    uptakes = newly_eligible,
    payoffs = hemout_soc$cost_daq_soc_rup,
    horizon = bi_horizon_wks,
    prices = prices_dyn_soc,
    discrate = bi_discount
    )

# SoC, other costs - unchanged from static calculations
wout4_soc_othcost <- wout3_soc_othcost

# Total budgetary costs
budget_wout4 <- budget_wout4_soc <- wout4_soc_daqcost + wout4_soc_othcost
```

The total budgetary costs in the world without are \$11,516,132 in
respect of 522 patients.

Let us now calculate the budgetary costs in the world with the new
intervention.

``` r
# World with

# SoC, drug acquisition costs
with4_soc_daqcost <- dynpv(
    uptakes = uptake_soc,
    payoffs = hemout_soc$cost_daq_soc_rup,
    horizon = bi_horizon_wks,
    prices = prices_dyn_soc,
    discrate = bi_discount
    )

# SoC, other costs
with4_soc_othcost <- with3_soc_othcost

# New intervention, drug acquisition costs
with4_new_daqcost <- dynpv(
    uptakes = uptake_new,
    payoffs = hemout_new$cost_daq_new_rup,
    horizon = bi_horizon_wks,
    prices = prices_dyn_new,
    discrate = bi_discount
    )

# New intervention, other costs
with4_new_othcost <- with3_new_othcost

# Total
budget_with4_soc <- with4_soc_daqcost + with4_soc_othcost
budget_with4_new <- with4_new_daqcost + with4_new_othcost
budget_with4 <- budget_with4_soc + budget_with4_new
#> Warning in addprod(e1, e2, mult = 1): Uptake vectors differ in length
```

Notice that there is a similar warning as earlier. The budgetary costs
in the world with the new intervention are \$28,535,724, comprising
\$3,460,107 in respect of the costs of 103 patients being treated with
the SoC, and \$34,359,885 in respect of the costs of 419 patients being
treated with the new treatment.

``` r
# Budget impact
bi4_soc <- budget_with4_soc - budget_wout4_soc
#> Warning in addprod(e1, e2, mult = -1): Uptake vectors differ in length
bi4_new <- budget_with4_new
bi4 <- budget_with4 - budget_wout4

summary(bi4)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             261 
#>      Number of times:               1 
#>      Total uptake:                  0 
#>      Total present value:           17019592 
#>      Mean present value:            Inf
```

The total budget impact is \$17,019,592, representing an increase of
148%.

### Summary

|                                |                     | Scenario 1  | Scenario 2  | Scenario 3 | Scenario 4 |
|:-------------------------------|:--------------------|-------------|-------------|------------|------------|
| Dynamic pricing?               |                     | No          | Yes         | No         | Yes        |
| Dynamic uptake?                |                     | No          | No          | Yes        | Yes        |
| World without new intervention |                     |             |             |            |            |
|                                | Standard of Care    | 12,923,366  | 11,516,132  | 12,923,366 | 11,516,132 |
|                                | New intervention    | 0           | 0           | 0          | 0          |
|                                | Total               | 12,923,366  | 11,516,132  | 12,923,366 | 11,516,132 |
| World with new intervention    |                     |             |             |            |            |
|                                | Standard of Care    | 0           | 0           | 3,508,178  | 3,460,107  |
|                                | New intervention    | 32,381,279  | 34,359,885  | 23,456,610 | 25,075,617 |
|                                | Total               | 32,381,279  | 34,359,885  | 26,964,789 | 25,075,617 |
| Budget impact                  |                     |             |             |            |            |
|                                | Standard of Care    | -12,923,366 | -11,516,132 | -9,415,187 | -8,056,025 |
|                                | New intervention    | 32,381,279  | 34,359,885  | 23,456,610 | 25,075,617 |
|                                | Absolute impact     | 19,457,914  | 22,843,753  | 14,041,423 | 17,019,592 |
|                                | Relative impact (%) | 151%        | 198%        | 109%       | 148%       |

Budget Impact model result by scenario

## Discussion

- In both cases, the budget impact is large, with budgetary costs more
  than doubling with the introduction of the new intervention, over the
  time horizon of interest (5 years).
- Dynamic pricing leads to greater anticipated costs of the new
  intervention and lower expected budgetary costs of the SoC, over the
  time horizon of interest. Accordingly, in this example, the budget
  impact is greater in the dynamic pricing scenario.
- Further stratification of the results, by intervention received, time
  period, cost component etc may reveal further insights. These are
  possible from the results calculated and presented by
  [`dynamicpv::dynpv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/dynpv.md)
  but not shown in this simple illustration.
