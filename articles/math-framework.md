# Mathematical Framework

## Introduction and Motivation

Single cohort cost-effectiveness models are routinely used in the
decision making of Health Technology Assessment (HTA) bodies, and are
widely published in the scientific literature.(Espinosa et al. 2024;
Enright et al. 2025; Do et al. 2021) Despite their utility, such models
have been criticised as overly limited in scope, omitting important
elements of value(Breslau et al. 2023; Shafrin et al. 2024)\] and health
equity(Avanceña and Prosser 2021). Anticipated pricing dynamics are
routinely ignored, meaning that the long run opportunity cost for drugs
may be misrepresented,(Neumann et al. 2022) and single cohort modeling
is criticized as not tailored to properly inform decision-making that
will impact future cohorts of patients(Hoyle and Anderson 2010). Case
studies have shown how modeling pricing and uptake as dynamic can have
substantial effects on reported Incremental Cost-Effectiveness Ratio
(ICER) values. Without accounting for these effects, ICERs are
overstated and unrepresentative.(Schöttler et al. 2023; Whittington et
al. 2025; Moreno and Ray 2016)

In a recent review, Puls et al listed four challenges in modeling life
cycle drug pricing and offered some proposals.(Puls et al. 2024) Pricing
changes before Loss of Exclusivity (LoE) events are ‘usually small’ but
local pricing data can be informative, whereas after LoE, changes to
pricing ‘should be informed by country-specific and historical estimates
of average price reductions’, such as may be found in recent
reviews.(Lin et al. 2025; Jofre-Bonet et al. 2025; Serra-Burriel et al.
2024; Laube et al. 2024) Following earlier recommendations by by Hoyle
and Anderson, cost-effectiveness evaluations should include future
incident cohorts in addition to the present, prevalent cohort,(Hoyle and
Anderson 2010) though assumptions may need to be simplified to
facilitate calculation. Reporting should include individual and multiple
cohorts, assuming uniform or utilization-informed weightings.(Puls et
al. 2024)

There are now a growing number of publications of cost-effectiveness
evaluations with dynamic pricing and uptake.(Puls et al. 2024; Schöttler
et al. 2023; Whittington et al. 2025; Shafrin et al. 2024; Moreno and
Ray 2016) The purpose of this R package is to provide a simple tool to
conduct calculations of present values that allow for dynamic pricing
and dynamic uptake. The mathematical framework presented in this
vignette formalizes what others have developed and applied,(Hoyle and
Anderson 2010; Shafrin et al. 2024) and provides the technical basis of
the calculations within the `dynamicpv` package. Other vignettes cover
calculations of Net Present Values, and illustrate how
cost-effectiveness and budget impact models can account for dynamic
pricing and uptake. The present scope of the package is models in
discrete time only.

## What are dynamic pricing and dynamic uptake?

**Dynamic pricing** is pricing of a resource (e.g. acquisition cost of a
medicine, wages of a professional) that changes in time. The opposite of
dynamic pricing is static pricing. We may assume prices are static in
nominal terms - they are constant and do not change value in time at
all; or we may assume prices are static in real terms, in which case,
were it not for price inflation, prices would be constant.
Alternatively, pricing can be expected to be quite irregular - such as
when drug prices dramatically reduce after branded products lose
exclusivity. Reflecting these dynamics complicates calculations of Net
Present Value, but is more realistic.

**Dynamic uptake** refers to the modeling of multiple series of
payoffs/cashflows over time, rather than the modeling of just one series
of payoffs/cashflows at a time. This may arise, for example, in
considering the treatment costs of multiple cohorts of patients
beginning their treatment courses at different times, leading to the
term ‘stacked cohorts’. There are also analogies to ‘run-off triangles’
used by insurance actuaries to model the emergence of insurance claims
over time following claim events. This is already commonly a
consideration in budget impact models in healthcare, but also relevant
to cost-effectiveness.(Sullivan et al. 2014)

## Framework

The framework for these calculations is centered around the idea of
costs and outcomes accruing to patients as they receive treatment, or
more generally experience the consequences of an intervention. Time may
be partitioned therefore between the time to begin treatment and the
time since starting treatment.

More formally, suppose \\j=1, ..., J\\ indexes the time at which the
patient begins treatment (e.g. a new intervention or Standard of Care,
SoC). Suppose \\k=1, ..., K\\ indexes time since initiating treatment.
Time is \\t=j+k-1\\, and we are interested in \\t=1,...,T\\, where \\T\\
is the time horizon of the decision-maker.

This can be illustrated through an example. Suppose then we are
considering a cashflow in timestep \\t=3\\. This will comprise:

- patients who are in the third timestep of treatment that began in
  timestep 1, \\(j,k) = (1, 3)\\;
- patients who are in the second timestep of treatment that began in
  timestep 2, \\(j,k) = (2, 2)\\; and
- patients who are in the first timestep of treatment that began in
  timestep 3, \\(j,k) = (3, 1)\\.

The Present Value of a cashflow \\p_k\\ for the \\u_j\\ patients who
began treatment at time \\j\\ and who are in their \\k\\th timestep of
treatment is as follows

\\ PV(j,k) = u_j \cdot p_k \cdot R\_{j+k-1} \cdot (1+i)^{2-j-k} \\

where \\i\\ is the risk-free discount rate per timestep, and \\p_k\\ is
the cashflow amount in today’s money, and \\p_k \cdot R\_{j+k-1}\\ is
the nominal amount of the cashflow at the time it is incurred.

The total present value is therefore the sum over all \\j\\ and \\k\\
within the time horizon \\T\\. The full function used by the package
allows for additional offsetting of the price uprating factor \\R\\ by
time \\l\\. This can be useful for calculating present values at
different present times.

\\ TPV(l) = \sum\_{j=1}^{T} \sum\_{k=1}^{T-j+1} PV(j, k, l) =
\sum\_{j=1}^{T} \sum\_{k=1}^{T-j+1} u_j \cdot p_k \cdot R\_{j+k+l-1}
\cdot (1+i)^{2-j-k} \\

## Overview of package

The
[`dynamicpv::dynpv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/dynpv.md)
function operationalizes the formula above. It produces output of the
class ‘dynpv’, to which the following methods may be applied.

| Method                                                                             | Description                                                       | Value                                                                                                                                                                                  |
|------------------------------------------------------------------------------------|-------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`mean()`](https://rdrr.io/r/base/mean.html)                                       | Mean present value per uptaking patient                           | \\TPV(l) / \sum\_{j=1}^{T} u_j =\\ [`total()`](https://MSDLLCpapers.github.io/dynamicpv/reference/total.md)/[`uptake()`](https://MSDLLCpapers.github.io/dynamicpv/reference/uptake.md) |
| [`ncoh()`](https://MSDLLCpapers.github.io/dynamicpv/reference/ncoh.md)             | Number of cohorts of uptaking patients                            | \\n({u_j})\\                                                                                                                                                                           |
| [`ntimes()`](https://MSDLLCpapers.github.io/dynamicpv/reference/ntimes.md)         | Number of times at which present value calculations are performed | \\n({l})\\                                                                                                                                                                             |
| [`sum_by_coh()`](https://MSDLLCpapers.github.io/dynamicpv/reference/sum_by_coh.md) | Present value for each uptake cohort `j` and calculation time `l` | \\\sum\_{k=1}^{T-j+1} PV(j,k,l)\\                                                                                                                                                      |
| [`summary()`](https://rdrr.io/r/base/summary.html)                                 | Summarize a `dynpv` object                                        | Text                                                                                                                                                                                   |
| [`total()`](https://MSDLLCpapers.github.io/dynamicpv/reference/total.md)           | Total present value                                               | \\TPV(l)\\                                                                                                                                                                             |
| [`uptake()`](https://MSDLLCpapers.github.io/dynamicpv/reference/uptake.md)         | Total number of uptaking patients                                 | \\\sum\_{j=1}^{T} u_j\\                                                                                                                                                                |

Also, methods `+` and `-` can be used to add and subtract two `dynpv`
objects. It is important to note when interpreting the
[`mean()`](https://rdrr.io/r/base/mean.html) that the arithmetic
operations add/subtract the
[`total()`](https://MSDLLCpapers.github.io/dynamicpv/reference/total.md)
and
[`uptake()`](https://MSDLLCpapers.github.io/dynamicpv/reference/uptake.md)
values of the objects.

The
[`dynamicpv::futurepv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/futurepv.md)
function calculates the present value of a series of payoffs for a
single given cohort, entering at given future time, allowing for dynamic
pricing. This function is a wrapper for
[`dynpv()`](https://MSDLLCpapers.github.io/dynamicpv/reference/dynpv.md)
restricted to evaluation of a single cohort.

## References

Avanceña, Anton L. V., and Lisa A. Prosser. 2021. “Examining Equity
Effects of Health Interventions in Cost-Effectiveness Analysis: A
Systematic Review.” *Value in Health* 24 (1): 136–43.
<https://doi.org/10.1016/j.jval.2020.10.010>.

Breslau, Rachel Milstein, Joshua T. Cohen, Jose Diaz, Bill Malcolm, and
Peter J. Neumann. 2023. “A Review of HTA Guidelines on Societal and
Novel Value Elements.” *International Journal of Technology Assessment
in Health Care* 39 (1): e31.
<https://doi.org/10.1017/S026646232300017X>.

Do, Lauren A, Patricia G Synnott, Siyu Ma, and Daniel A Ollendorf. 2021.
“Bridging the Gap: Aligning Economic Research with Disease Burden.” *BMJ
Global Health* 6 (6): e005673.
<https://doi.org/10.1136/bmjgh-2021-005673>.

Enright, Daniel E., Emma G. van Duijnhoven, Daniel A. Ollendorf, and
James D. Chambers. 2025. “Use of Health Technology Assessments in
Specialty Drug Coverage Decisions by US Commercial Health Plans.”
*Journal of Managed Care & Specialty Pharmacy* 31 (3): 289–95.
<https://www.jmcp.org/doi/10.18553/jmcp.2025.31.3.289>.

Espinosa, Oscar, Paul Rodríguez-Lesmes, Giancarlo Romano, Esteban
Orozco, Sergio Basto, Diego Ávila, Lorena Mesa, and Hernán Enríquez.
2024. “Use of Cost-Effectiveness Thresholds in Healthcare Public Policy:
Progress and Challenges.” *Applied Health Economics and Health Policy*
22 (6): 797–804. <https://doi.org/10.1007/s40258-024-00900-5>.

Hoyle, Martin, and Rob Anderson. 2010. “Whose Costs and Benefits? Why
Economic Evaluations Should Simulate Both Prevalent and All Future
Incident Patient Cohorts.” *Medical Decision Making* 30 (4): 426–37.
<https://doi.org/10.1177/0272989X09353946>.

Jofre-Bonet, Mireia, Alistair McGuire, Victoria Dayer, Joshua A. Roth,
and Sean D. Sullivan. 2025. “The Price Effects of Biosimilars in the
United States.” *Value in Health* 28 (March): 742–50.
<https://doi.org/10.1016/j.jval.2025.02.008>.

Laube, Y., M. Serra-Burriel, C. C. E. G. Glaus, and K. N. Vokinger.
2024. “Launch and Postlaunch Price Developments of New Drugs in the US,
Germany, and Switzerland.” *JAMA Health Forum* 5 (11): e244461.
<https://doi.org/10.1001/jamahealthforum.2024.4461>.

Lin, Ching-Hsuan, Jonathan D. Campbell, James Motyka, and Joshua T.
Cohen. 2025. “US Drug Pricing Patterns Before Loss of Exclusivity.”
*Value in Health* 28 (6): 907–14.
<https://doi.org/10.1016/j.jval.2025.03.008>.

Moreno, Santiago G, and Joshua A Ray. 2016. “The Value of Innovation
Under Value-Based Pricing.” *Journal of Market Access and Health Policy*
7 (4). <https://doi.org/10.3402/jmahp.v4.30754>.

Neumann, Peter J., Meghan I. Podolsky, Anirban Basu, Daniel A.
Ollendorf, and Joshua T. Cohen. 2022. “Do Cost-Effectiveness Analyses
Account for Drug Genericization? A Literature Review and Assessment of
Implications.” *Value in Health* 25 (1): 59–68.
<https://doi.org/10.1016/j.jval.2021.06.014>.

Puls, Mathilde, James Horscroft, Benjamin Kearns, Daniel Gladwell,
Edward Church, Kasper Johannesen, Bill Malcolm, and John Borrill. 2024.
“Challenges of Incorporating Life Cycle Drug Pricing in
Cost-Effectiveness Models: A Review of Methods and Modeling
Suggestions.” *Value in Health* 27 (7): 978–85.
<https://doi.org/10.1016/j.jval.2024.03.006>.

Schöttler, Marcel H., Friso B. Coerts, Maarten J. Postma, Cornelis
Boersma, and Mark H. Rozenbaum. 2023. “The Effect of the Drug Life Cycle
Price on Cost-Effectiveness: Case Studies Using Real-World Pricing
Data.” *Value in Health* 26 (1): 91–98.
<https://doi.org/10.1016/j.jval.2022.06.007>.

Serra-Burriel, M., N. Martin-Bassols, G. Perényi, and K. N. Vokinger.
2024. “Drug Prices After Patent Expirations in High-Income Countries and
Implications for Cost-Effectiveness Analyses.” *JAMA Health Forum* 5
(8): e242530. <https://doi.org/10.1001/jamahealthforum.2024.2530>.

Shafrin, Jason, Jaehong Kim, Joshua T. Cohen, Louis P. Garrison, Dana A.
Goldman, Jalpa A. Doshi, Joshua Krieger, et al. 2024. “Valuing the
Societal Impact of Medicines and Other Health Technologies: A User Guide
to Current Best Practices.” *Forum for Health Economics & Policy* 27
(1): 29–116. <https://doi.org/10.1515/fhep-2024-0014>.

Sullivan, Sean D., Josephine A. Mauskopf, Federico Augustovski, J. Jaime
Caro, Karen M. Lee, Mark Minchin, Ewa Orlewska, Pete Penna, Jose-Manuel
Rodriguez Barrios, and Wen-Yi Shau. 2014. “Budget Impact
Analysis—Principles of Good Practice: Report of the ISPOR 2012 Budget
Impact Analysis Good Practice II Task Force.” *Value in Health* 17 (1):
5–14. <https://doi.org/10.1016/j.jval.2013.08.2291>.

Whittington, Melanie D., Joshua T. Cohen, Peter J. Neumann, Tyler D.
Wagner, and Jonathan D. Campbell. 2025. “Identifying the Influential
Dynamic Inputs in Cost-Effectiveness Analyses.” *Value in Health*,
April, S1098301525022867. <https://doi.org/10.1016/j.jval.2025.03.016>.
