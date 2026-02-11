# shellgame <img src="man/figures/logo.png" align="right" height="139" />

> **The Shell Game**: Swapping the VAR without changing the name or the formula.

## Overview

The `shellgame` package reveals how data quality silently degrades during geographic transformations while variable labels remain unchanged. Like a shell game where the ball gets swapped without anyone noticing, geographic transformations swap **observed data** for **imputed data** while keeping the same column name.

**The key insight**: This error is **agnostic** to:
- **Variable**: Population, median income, vehicle ownership - doesn't matter
- **Tool**: R, Python, Stata, ArcGIS - doesn't matter  
- **Geography**: Hennepin County or anywhere else - doesn't matter

**What matters**: The transformation itself causes the error.

## Installation

```r
# Install from GitHub
# install.packages("devtools")
devtools::install_github("phinnmarkson/shellgame")
```

## Quick Start

```r
library(shellgame)

# Run audit on Hennepin County (example data included)
result <- audit_transformation(
  baseline_data = hennepin_zcta_baseline,
  zip_zcta_map = hennepin_zip_zcta_map,
  hud_crosswalk = hennepin_hud_crosswalk,
  county_fips = "27053",
  variable_name = "pop"
)

# View results
summary(result)
#> Baseline: 1,391,557 (74 ZCTAs, observed from ACS)
#> After transformation: 1,216,874 (recovered via HUD TOT_RATIO)
#> Loss: 174,683 (-12.6%)
#>
#> The shell game: Same column name, different underlying quantity.
```

## The Shell Game Explained

**What's happening:**

1. **Start**: Real measured population (observed data)
2. **Hop 1** (ZCTA→ZIP): Swap in imputed values via association  
3. **Hop 2** (ZIP→County): Swap in more assumptions via TOT_RATIO
4. **End**: Completely imputed values, still labeled "population"

**The cups never announce the swap**, so everyone thinks they're still tracking the original ball.

## Example: Hennepin County

```r
# Visualize the transformation
plot_transformation_loss(result)
```

![Hennepin County transformation loss](man/figures/hennepin_loss.png)

## Key Features

- **Reproducible audit framework** - Quantify error at each transformation hop
- **Variable agnostic** - Works with any ACS variable
- **Tool agnostic** - Demonstrates the transformation is the problem
- **Publication-ready visualizations** - Maps and plots included
- **Pre-loaded example** - Hennepin County data ready to use

## Learn More

- `vignette("hennepin-example")` - Complete worked example
- `vignette("understanding-shell-game")` - Conceptual explanation
- `vignette("data-preparation")` - How to audit your own geography

## Citation

If you use this package in your research, please cite:

```
Markson, P. (2026). shellgame: The Shell Game - Audit Geographic Data 
  Transformations. R package version 0.1.0.
```

## Inspiration

Package structure inspired by the excellent [`areal`](https://chris-prener.github.io/areal/) package by Christopher Prener.

## License

MIT © Phinn Markson
