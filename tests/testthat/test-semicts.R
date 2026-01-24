# Test new semicts calculations

# Example
payoffs <- function(t) {100+50*t}
prices <- function(t) {1.03 ^ (floor(t))}
discrate <- function(t) {0.97 ^ t}

# 1. Full function calls intermediate function ok
test_that("Full function calls intermediate function ok", {
    int <- dynpv_semicts(uptakes=1, payoffs=payoffs, horizon=5, tzero=0, prices=prices, discrate=discrate)
    full <- dynpv(payoffs=payoffs, horizon=5, prices=prices, discrate=discrate)
    expect_equal(int, full)
  }
)





