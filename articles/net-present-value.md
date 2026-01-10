# Net Present Value

## Introduction

This vignette describes how to use the `dynamicpv` package to derive
(Net) Present Values (NPVs) that account for dynamic (or static)
pricing, and dynamic (or static) uptake. We consider:

- NPV with static pricing and static uptake
- NPV with dynamic pricing and static uptake, with prices increasing
  regularly and irregularly
- NPV with static pricing and dynamic uptake, with constant and variable
  uptake over time
- NPV with both dynamic pricing and dynamic uptake

First let us load the packages we will use for this vignette.

``` r
library(dynamicpv)
```

## NPV with static pricing and static uptake

The NPV of a cashflow \\c_t\\ in \\t\\ years time, assuming prices
constant in real terms and an annual discount rate of \\i\_{real}\\ is
calculated as follows:

\\NPV = \frac{c_t}{(1+i\_{real})^{t}}\\

It is overkill rather to use `dynamicpv` to calculate the NPV of a
cashflow that is constant in real terms, since there are simpler routes
to doing this. Nevertheless, let us start there, since it helps
understand functionality. We use a simple cashflow and \\i=3\\\\.

``` r
# A simple cashflow
cashflow <- c(110, 120, 130, 140, 150)

# (Real) discount rate of 3\% per timestep (year)
disc <- 0.03
vt1 <- (1 + disc)^(-1 * (0:4))
```

The calculation can be presented in a table as follows.

| Time  | Cashflow | Discount factor       | Product |
|-------|----------|-----------------------|---------|
| \\t\\ | \\c_t\\  | \\v^t = (1+i)^{1-t}\\ |         |
| 1     | 110      | 1                     | 110     |
| 2     | 120      | 0.971                 | 117     |
| 3     | 130      | 0.943                 | 123     |
| 4     | 140      | 0.915                 | 128     |
| 5     | 150      | 0.888                 | 133     |
| Total | 650      |                       | 610     |

Calculation of NPV from a simple cashflow and given discount rate

``` r
# Run dynpv calculation with full output
pv1 <- dynpv(payoffs=cashflow, discrate=disc)

summary(pv1)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             5 
#>      Number of times:               1 
#>      Total uptake:                  1 
#>      Total present value:           610.4352 
#>      Mean present value:            610.4352
```

The present value of this cashflow is 610. The same result could have
been found more easily than invoking this package.

``` r
sum(vt1 * cashflow)
#> [1] 610.4352
```

## NPV with dynamic pricing and static uptake

Cashflows may not in general be expected to be constant in real terms.
Accordingly it can be preferable to explicitly estimate the cashflow in
nominal terms, \\c'\_t = c_t \cdot R_t\\, and discount with a nominal
discount rate that includes expected inflation.

\\ 1+i\_{nom} = (1+i\_{real})(1+r_g) \\ \\NPV =
\frac{c'\_t}{(1+i\_{nom})^t} = \frac{c_t \cdot R_t}{(1+i\_{nom})^t} \\

### Prices that increase regularly

In this example, let us assume that prices of the resource underlying
the cashflow increases at 1 % per year, but that general price inflation
is 2.5 % per year. The real discount rate is unchanged at 3 % per year,
so the nominal discount rate is therefore approximately 5.5 % per year.

First, we derive a price index to handle the changing price of the
resource underlying the cashflow. Then we derive the nominal discount
rate, incorporating the general rate of price inflation in the economy.
We then combine these inputs with
[`dynpv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/dynpv.md)
to calculate the NPV.

``` r
# Set up price index
pinfl <- 0.01
pindex <- (1+pinfl)^(0:4)
pindex
#> [1] 1.000000 1.010000 1.020100 1.030301 1.040604

# Nominal discount rate
nomdisc <- (1+disc)*1.025-1

# Calculate present value
pv2 <- dynpv(payoffs=cashflow, prices=pindex, discrate=nomdisc)

summary(pv2)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             5 
#>      Number of times:               1 
#>      Total uptake:                  1 
#>      Total present value:           591.9954 
#>      Mean present value:            591.9954
```

The NPV of 592 could still have been calculated using base R functions.

``` r
# Compare with more base calculations
vt2 <- (1+nomdisc)^(-1 * (0:4))
sum(vt2 * cashflow * pindex)
#> [1] 591.9954
```

### Prices that increase irregularly

Where `dynamicpv` is most relevant is when the price index is more
irregular, more dynamic. For example, one might anticipate a sudden
future change in a price of a certain resource (e.g. drug price
reduction on loss of exclusivity). This can be accommodated in the price
index. In this simple example, let us assume that the underlying price
of the resource reduces to half its original value from the fourth year.

``` r
# Revise the price index to be 0.5 from year 4
pindex[4:5] <- 0.5
pindex
#> [1] 1.0000 1.0100 1.0201 0.5000 0.5000

# Calculate present value
pv3 <- dynpv(payoffs=cashflow, prices=pindex, discrate=nomdisc)

summary(pv3)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             5 
#>      Number of times:               1 
#>      Total uptake:                  1 
#>      Total present value:           463.6326 
#>      Mean present value:            463.6326
```

With this dynamic pricing change, the NPV has reduced by 128, from 592
to 464. The corresponding base R code is shown below.

``` r
# Compare with more base calculations
sum(vt2 * cashflow * pindex)
#> [1] 463.6326
```

## NPV with static pricing and dynamic uptake

### Uptake is constant over time

Suppose we have one new patient each year, and we wish to calculate the
total NPV in a time horizon of 5 years. Now we have a payoff triangle as
follows.

| Time  | Cashflow 1 | Cashflow 2   | Cashflow 3   | Cashflow 4   | Cashflow 5   | Cashflow Sum | Discount factor       | Product |
|-------|------------|--------------|--------------|--------------|--------------|--------------|-----------------------|---------|
| \\t\\ | \\c_t\\    | \\c\_{t-1}\\ | \\c\_{t-2}\\ | \\c\_{t-3}\\ | \\c\_{t-4}\\ |              | \\v^t = (1+i)^{1-t}\\ |         |
| 1     | 110        | \-           | \-           | \-           | \-           | 110          | 1                     | 110     |
| 2     | 120        | 110          | \-           | \-           | \-           | 230          | 0.971                 | 223     |
| 3     | 130        | 120          | 110          | \-           | \-           | 360          | 0.943                 | 339     |
| 4     | 140        | 130          | 120          | 110          | \-           | 500          | 0.915                 | 458     |
| 5     | 150        | 140          | 130          | 120          | 110          | 650          | 0.888                 | 578     |
| Total | 650        |              |              |              |              |              |                       | 1,708   |

Calculation of NPV from a simple cashflow and given discount rate

With
[`dynamicpv::dynpv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/dynpv.md),
we just update the `uptakes` argument.

``` r
# Uptake vector is (1, 1, 1, 1, 1)
uptakes1 <- rep(1, 5)

# NPV calculation
pv4 <- dynpv(payoffs=cashflow, uptakes=uptakes1, discrate=disc)

summary(pv4)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             5 
#>      Number of times:               1 
#>      Total uptake:                  5 
#>      Total present value:           1707.723 
#>      Mean present value:            341.5446
```

There are 5 patients with a total NPV of 1,708, which equates to 342 on
average per patient. This can also be calculated in base R.

``` r
sum(vt1 * cumsum(cashflow))
#> [1] 1707.723
```

### Uptake varies over time

In general, uptake will not be constant in time. Due to factors such as
varying epidemiology (prevalence and incidence), prior treatment
pathways (patient testing, patient diagnostics, prior treatment usage),
as well as the specific uptake of the treatment of interest (patient
share), uptake will also be highly variable over time. In this setting,
the total and mean NPVs must reflect weightings applicable to each
cashflow.

For example, suppose the number of patients receiving treatment
increases by one each year. The weighting given to cashflow 1 would then
be \\1/(1+2+3+4+5)=6.67\\ %.

``` r
# Uptake vector is (1, 2, 3, 4, 5)
uptakes2 <- 1:5

# NPV calculation
pv5 <- dynpv(payoffs=cashflow, uptakes=uptakes2, discrate=disc)

summary(pv5)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             5 
#>      Number of times:               1 
#>      Total uptake:                  15 
#>      Total present value:           3841.785 
#>      Mean present value:            256.119
```

There are 15 patients with a total NPV of 3,842, which equates to 256 on
average per patient. Verifying this result in base R also becomes more
complicated.

``` r
# Verifying total NPV is now more complicated
checkpv <- rep(0, 5)
for (i in 1:5) {
  checkpv[i] <- sum(cashflow[1:i] * uptakes2[i:1] * vt1[i])
}
sum(checkpv)
#> [1] 3841.785
```

## NPV with dynamic pricing and dynamic uptake

The package becomes most powerful when considering both dynamic uptake
and dynamic pricing. A simple call to
[`dynamicpv::dynpv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/dynpv.md)
replaces what would be rather more complicated with base functions, even
in this toy example.

``` r
# NPV calculation
pv6 <- dynpv(payoffs=cashflow, uptakes=uptakes2, prices=pindex, discrate=nomdisc)

# Calculation results
pv6
#> # A tibble: 15 × 9
#>        j     k     l     t    uj    pk     R     v    pv
#>    <int> <int> <dbl> <dbl> <int> <dbl> <dbl> <dbl> <dbl>
#>  1     1     1     0     1     1   110  1    1     110  
#>  2     1     2     0     2     1   120  1.01 0.947 115. 
#>  3     1     3     0     3     1   130  1.02 0.897 119. 
#>  4     1     4     0     4     1   140  0.5  0.850  59.5
#>  5     1     5     0     5     1   150  0.5  0.805  60.4
#>  6     2     1     0     2     2   110  1.01 0.947 210. 
#>  7     2     2     0     3     2   120  1.02 0.897 220. 
#>  8     2     3     0     4     2   130  0.5  0.850 110. 
#>  9     2     4     0     5     2   140  0.5  0.805 113. 
#> 10     3     1     0     3     3   110  1.02 0.897 302. 
#> 11     3     2     0     4     3   120  0.5  0.850 153. 
#> 12     3     3     0     5     3   130  0.5  0.805 157. 
#> 13     4     1     0     4     4   110  0.5  0.850 187. 
#> 14     4     2     0     5     4   120  0.5  0.805 193. 
#> 15     5     1     0     5     5   110  0.5  0.805 221.

# Total present value = sum of the pv column
sum(pv6$pv)
#> [1] 2330.349

summary(pv6)
#> Summary of Dynamic Pricing and Uptake
#>      Number of cohorts:             5 
#>      Number of times:               1 
#>      Total uptake:                  15 
#>      Total present value:           2330.349 
#>      Mean present value:            155.3566
```

There are 15 patients with a total NPV of 2,330, which equates to 155 on
average per patient.
