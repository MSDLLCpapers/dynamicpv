# Package index

## Key functions and datasets

- [`dynpv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/dynpv.md)
  : Present values with dynamic pricing and dynamic uptake
- [`futurepv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/futurepv.md)
  : Calculate present value for a payoff in a single cohort with dynamic
  pricing across multiple timepoints
- [`oncpsm`](https://MSDLLCpapers.github.io/dynamicpv/reference/oncpsm.md)
  : Heemod cost-effectiveness model example

## Methods to apply to dynpv S3 objects

- [`` `+`( ``*`<dynpv>`*`)`](https://MSDLLCpapers.github.io/dynamicpv/reference/plus-.dynpv.md)
  : Method to add two dynpv objects together
- [`` `-`( ``*`<dynpv>`*`)`](https://MSDLLCpapers.github.io/dynamicpv/reference/dot-dynpv.md)
  : Method to subtract one dynpv object from another
- [`mean(`*`<dynpv>`*`)`](https://MSDLLCpapers.github.io/dynamicpv/reference/mean.dynpv.md)
  : Mean present value per uptaking patient
- [`ncoh()`](https://MSDLLCpapers.github.io/dynamicpv/reference/ncoh.md)
  : Number of cohorts of uptaking patients
- [`ntimes()`](https://MSDLLCpapers.github.io/dynamicpv/reference/ntimes.md)
  : Number of times at which present value calculations are performed
- [`sum_by_coh()`](https://MSDLLCpapers.github.io/dynamicpv/reference/sum_by_coh.md)
  : Present value for each uptake cohort and calculation time
- [`summary(`*`<dynpv>`*`)`](https://MSDLLCpapers.github.io/dynamicpv/reference/summary.dynpv.md)
  : Summarize a dynpv object
- [`total()`](https://MSDLLCpapers.github.io/dynamicpv/reference/total.md)
  : Total present value
- [`uptake()`](https://MSDLLCpapers.github.io/dynamicpv/reference/uptake.md)
  : Total number of uptaking patients

## Helper functions

- [`addprod()`](https://MSDLLCpapers.github.io/dynamicpv/reference/addprod.md)
  : Method to add two dynpv objects together
- [`get_dynfields()`](https://MSDLLCpapers.github.io/dynamicpv/reference/get_dynfields.md)
  : Helper function to get a tibble of the relevant fields from heemod
  output
- [`get_param_value()`](https://MSDLLCpapers.github.io/dynamicpv/reference/get_param_value.md)
  : Obtain parameter value(s) from a heemod output
- [`trim_vec()`](https://MSDLLCpapers.github.io/dynamicpv/reference/trim_vec.md)
  : Trim the tailing zeroes from a long vector
