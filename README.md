# shellgame <img src="man/figures/logo.png" align="right" height="139" />

[![CRAN status](https://www.r-pkg.org/badges/version/shellgame)](https://CRAN.R-project.org/package=shellgame)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18634426.svg)](https://doi.org/10.5281/zenodo.18634426)

> The column name stays the same. What it holds does not.

## Overview

Current practice in geographic data transformation suffers from three interrelated deficiencies. First, transformation error is rarely quantified. Researchers report that they "used HUD crosswalk Q3 2024" without acknowledging that this choice—among crosswalk source, time period, and allocation ratio—constitutes a methodological decision affecting results. Second, error is treated as incidental rather than structural. The prevailing assumption holds that crosswalks are neutral utilities, when in fact they encode assumptions about how population distributes across space that may not hold for the variable being studied. Third, equity implications remain unexamined. The differential impact of transformation choices on boundary communities and small populations is rarely discussed in published research.

The `shellgame` framework addresses these deficiencies. It provides a reproducible audit pipeline that quantifies transformation-induced error at each geographic "hop" and documents the hidden methodological decisions that directly affect research outcomes. The conceptual framework, implemented through the [`geoDeltaAudit`](https://CRAN.R-project.org/package=geoDeltaAudit) R package, enables researchers to transparently report transformation-induced uncertainty in population health studies. By making visible the assumptions embedded in standard transformation workflows, the framework supports more rigorous and equitable research practices.

## The Framework

The `shellgame` framework is built on the premise that geographic transformation is not a neutral operation but a sequence of decisions that alter the underlying data-generating process. The framework identifies two critical decision points that are typically left implicit in applied work.

**Decision 1: Membership Definition.** Researchers must choose whether to define geographic membership by administrative linkage (relationship-based, as used in ACS tabulations) or by geometric contact (spatial intersection).

**Decision 2: Crosswalk Selection.** When allocating ZIP-level data to counties, researchers must select among allocation ratios. The HUD ZIP-County crosswalk provides TOT_RATIO (total addresses), RES_RATIO (residential addresses only), BUS_RATIO (business addresses), and OTH_RATIO (other addresses). Each ratio embodies different assumptions about how population distributes across addresses that may not hold uniformly across urban, suburban, and rural contexts.

The framework quantifies delta_x(VAR), defined as the change in the value of a variable induced solely by geographic transformation and allocation choices, holding the underlying data source constant:

```
delta_x(VAR) = VAR₁ − VAR₀
```

Where VAR₀ is the baseline value at geography A, and VAR₁ is the post-transformation value. delta_x(VAR) does not imply directionality of truth — which representation is "correct" — nor that zero delta is inherently desirable. It states only that the variable is not invariant under this transformation.

Much like diagnostic formulation, where sensitivity and specificity must be balanced, geographic transformations operate within a similar trade-off space. A method that maximizes coverage may reduce geographic precision, while a method that preserves tight geographic alignment may shed or distort counts. Crosswalks, allocation rules, and lookup tables implicitly select a point along this trade-off. The audit makes that selection visible.

## The Hennepin County Case Study

Using 2022 ACS 5-year estimates for Hennepin County, Minnesota (n=74 ZCTAs, baseline population 1,391,557):

- **Pre-allocation expansion**: The ZCTA → ZIP hop alone increased the number of spatial units by 32.4% (74 → 98), before any weighting or allocation occurred. The analytical surface had already shifted.
- **Total transformation perturbation**: Following ZIP → County aggregation via HUD TOT_RATIO, the recovered population was 1,216,874 — a perturbation of **174,683 individuals (-12.6%)**.
- **Geographic redistribution**: The 174,683 not recovered in Hennepin County were allocated to five neighboring counties through crosswalk ratio weighting — made visible by the audit framework.

This perturbation is not an anomaly. It is a systematic consequence of transformation choices that researchers routinely make without quantifying.

## Installation

```r
install.packages("shellgame")
```

## Quick Start

```r
library(shellgame)

# Run audit on Hennepin County (pre-loaded example data)
result <- audit_transformation(
  baseline_data  = hennepin_zcta_baseline,
  zip_zcta_map   = hennepin_zip_zcta_map,
  hud_crosswalk  = hennepin_hud_crosswalk,
  county_fips    = "27053",
  variable_name  = "population"
)

summary(result)
#> === The Shell Game: Transformation Audit ===
#>
#> Variable: population
#> Target County: 27053
#>
#> --- Baseline (Observed Data) ---
#>   Units: 74 ZCTAs
#>   Total: 1,391,557
#>
#> --- After Transformation (Imputed Data) ---
#>   Intermediate: 98 ZIPs
#>   Recovered: 1,216,874
#>
#> --- The Shell Game Result ---
#>   Perturbation: -174,683 (-12.6%)
#>
#>   Same column name.
#>   Different underlying quantity.
#>   That's the shell game.

# Visualize
plot_transformation_perturbation(result)
```

## Equity Implications

The consequences of unquantified transformation perturbation are not distributed equally across communities. Communities located near administrative boundaries are systematically under- or over-represented depending on membership definitions. Small populations, including many racially and ethnically minoritized communities, are disproportionately affected by allocation assumptions that smooth heterogeneous distributions into uniform proxies. Historical undercounting in administrative data is amplified through successive transformations that treat imputed values as empirical measurements. When an analyst applies a crosswalk without auditing its effects, these distributional consequences remain invisible — buried in the methodological black box of geographic transformation.

## Related Package

[`geoDeltaAudit`](https://CRAN.R-project.org/package=geoDeltaAudit) is the operationalized implementation of the `shellgame` framework in R, providing the composable audit pipeline, step functions, and diagnostic output.

```r
install.packages(c("shellgame", "geoDeltaAudit"))
```

## Learn More

- `vignette("hennepin-example")` — Complete worked example
- `vignette("understanding-shell-game")` — Conceptual explanation
- `vignette("data-preparation", package = "geoDeltaAudit")` — How to audit your own geography

## Citation

```
Markson, P. (2026). shellgame: The Shell Game - Audit Geographic Data
  Transformations. R package version 0.1.1.
  https://CRAN.R-project.org/package=shellgame
```

## Inspiration

Package structure inspired by the excellent [`areal`](https://chris-prener.github.io/areal/) package by Christopher Prener.

## License

MIT © Phinn Markson
