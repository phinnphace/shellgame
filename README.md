# shellgame <img src="man/figures/logo.png" align="right" height="139" />

> **The Shell Game**: Swapping the VAR without changing the name or the formula.

## Overview

Welcome to the `shellgame`. The shellgame package reveals how data quality silently degrades during geographic transformations while variable labels remain unchanged; this wrapper works with geoDeltaAudit. Just like a shell game where the ball(sample) gets moved around under identical containers (VAR), geographic transformations swap **observed data** for **imputed data** while keeping the same column name. 

##  Why does this matter?
We are no longer measuring the sample of interest but the imputed data from the crosswalk we chose. 

## The crosswalk 
Is built with assumptions about population distribution, time period, and allocation ratio making this instrument an active agent in the data. The crosswalk does indeed transform the data, through its assumptions and the result is no longer the original sample population but a new population treated as the original. The original population did not have these crosswalk assumptions about distribution, time period, and allocation ratio because it was an observation, and now it is an imputed data treated as the former. 

##  shellgame 
Provides a package for you to audit crosswalks to quantify the perturbation of data transformation through administrative boundaries and make an informed choice for your use case, and goals. A crosswalk designed for population allocation may be inappropriate for income, employment, or housing variables, yet analysts routinely apply the same crosswalk across diverse analytic contexts. The shellgame package is designed to forefront this rather than footnote our assumptions. The example case in the Vignette work_flow is Hennepin County, MN because in 2025/26 I want us to see what unexamined workflows look like with real people because data are people. 

**The key insight**: This error is **agnostic** to:
- **Variable**: Population, median income, vehicle ownership - doesn't matter
- **Tool**: currently R (future goals: STATA, SAS, Python, etc)
- **Geography**: Hennepin County or anywhere else - doesn't matter

**What matters**: The transformation and crosswalk deserve a closer look

**A note on data and png's**
All data is preloaded in this package and will "display" graphics. This choice was made for ease and simplicity for folks. Not everyone wants to run tidycensus. And if this year has taught folks anything, not all data is available. Even standard census data. Additionally, not everyone is comfortable or has access to a census API and I am a huge fan of lighter and easier because I need that too. The full data from U.S. Census and the HUD crosswalk, plus R script are in the `data-raw` folder if you are feeling froggy.
  
The variable selected for the example; TOT_POP is easily communicated to a wide audience and not relegated to professional data, or population science jockeys. 

## Installation

```r
# Install from GitHub
# install.packages("remotes")
remotes::install_github("phinnphace/shellgame")
```

## Quick Start

```r
library(shellgame)

# Run audit on Hennepin County (example data included)
result <- evaluate_transformation(
  data = hennepin_zcta_baseline,
  zip_zcta_map = hennepin_zip_zcta_map,
  hud_crosswalk = hennepin_hud_crosswalk,
  geo_col = "zcta",
  var_col = "pop"
)

# View results
summary(result)
#> Baseline: 1,391,557 (74 ZCTAs, observed from ACS)
#> After transformation: 1,216,874 (recovered via HUD TOT_RATIO)
#> Perturbation: 174,683 (-12.6%)
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
plot_transformation_perturbation(result)
```

![Hennepin County transformation perturbation](man/figures/hennepin_loss.png)

## Key Features

- **Reproducible audit framework** - Quantify perturbation at each transformation hop
- **Variable agnostic** - Works with any variable. If it is not the variable, perhaps the tools need a closer look? 
- **Tool agnostic** - (Future goals. Currently only in R) 
- **visualizations** - Maps and plots included
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
