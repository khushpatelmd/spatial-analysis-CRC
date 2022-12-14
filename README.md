# Spatial analysis of county-level Colorectal Cancer incidence in Texas and Bayesian analysis of association with county-level smoking and education demographic data

**Author**
[Khush Patel, MD](https://khushpatelmd.github.io/)

<hr />

**Background**: Colorectal cancer (CRC) is the third most common cancer[1, 2] in both males and females in the United States of America. Potentially modifiable behavior which are risk factors include smoking, unhealthy diet and obesity[3]. Other important factor is CRC screening rate. CRC screening has been significantly linked to education level in past studies[4, 5]. Relatively few studies have been conducted to examine how county level smoking status, education level and race information affects the geographic distribution of colorectal cancer incidence, and no study has been conducted to investigate this at the county level in the state of Texas. Identification of geographic patterns of colorectal cancer incidence could provide impetus to conduct further investigations and target health resources for prevention and treatment in specific geographic areas.

**Methods**: County level colorectal cancer incidence data for Texas were obtained for the years 2009 to 2018 were obtained from the Texas Cancer Registry, Cancer Epidemiology and Surveillance Branch, Texas Department of State Health Services. Corresponding years demographic data at county level was obtained for smoking, bachelor’s degree as a proxy to colorectal cancer screening awareness and race. Exploratory analysis using Moran’s I at global and local level was performed. Bayesian Poisson Model, Bayesian non-spatial model (iid model with non-spatial random effects) and Bayesian Spatial model (Conditional autoregressive (ICAR) model with spatial and non-spatial random effects) were fitted. We also developed a unique, novel statistical imputation method for suppressed cancer data not used before in any other spatial studies.

**Results**: We found local Moran’s I to have positive spatial autocorrelation with value of +0.16 with p value <0.01. We found Conditional autoregressive (ICAR) model with spatial and non-spatial random effects fitted in INLA to be the model with lowest WAIC. All the models showed county level smoking data to be significantly associated with colorectal cancer incidence.

**Conclusion**: Colorectal cancer incidence showed significant autocorrelation amongst the county. County smoking data was significantly associated with Colorectal cancer incidence. 

<hr />

# Table Of Contents
-  [Research paper](#Paper)
-  [Requirements](#Requirements)
-  [Code structure](#Code-structure)
-  [Sample plots](#Sample-plots)
-  [How to cite](#How-to-cite)

<hr />

# Manuscript

[Full manuscript](images/Spatial_Analysis_Khush_Patel.pdf)


<hr />

# Requirements

```
classInt 0.4-8
dplyr 1.0.10
grid 4.2.1
gridExtra 2.3
INLA 22.05.07
maptools 1.1-4
RColorBrewer 1.1-3
rgdal 1.5-32
readxl 1.4.1
rgeos 0.5-9
tidyverse 1.3.2
spdep 1.2-7
spgwr 0.6-35
tmap 3.3-3
```

<hr />

# Code structure
```
├──  Main code
│    └── code_spatial_analysis.R - R script for complete analysis
│
├──  data  
     └── unimputed_data.csv - County level colorectal cancer incidence data for Texas were obtained for the years 2009 to 2018 were obtained from the Texas Cancer     Registry, Cancer Epidemiology and Surveillance Branch, Texas Department of State Health Services 
     └── dataset_for_modeling_imputed.csv - Imputed, cleaned dataset. Data imputation using machine learning model based on bayesian ridge regression
     └──shapefiles for plotting - .dbf, .prj, .shp, .shx

```

<hr />

# Sample plots (Refer to full paper for the description)

![Standardized Incidence Ratio](images/SIR.png)

![Rook vs Queen neighbor links](images/rook.png)

![Moran scatterplot](images/Moran.png)

![Moran statistic mapped at county level](images/local_Moran.png)

![LISA](images/LISA.png)

![Relative Risk](images/relative_risk.png)

<hr />

# How to cite 
This repository is a research work in progress. Please contact author (drpatelkhush@gmail.com) for details on reuse of code.

# References

1. Colorectal Cancer Statistics | How Common Is Colorectal Cancer? https://www.cancer.org/cancer/colon-rectal-cancer/about/key-statistics.html. Accessed 2 May 2021.

2. Colorectal Cancer, United States—2007–2016 | CDC. 2020. https://www.cdc.gov/cancer/uscs/about/data-briefs/no16-colorectal-cancer-2007-2016.htm. Accessed 17 Mar 2021.

3. Doubeni CA, Major JM, Laiyemo AO, Schootman M, Zauber AG, Hollenbeck AR, et al. Contribution of behavioral risk factors and obesity to socioeconomic differences in colorectal cancer incidence. J Natl Cancer Inst. 2012;104:1353–62.

4. Rodriguez N, Smith J. The Association Between Education and Colorectal Cancer Screening among United States Veterans Aged 50-75 Years Old: 286. Off J Am Coll Gastroenterol ACG. 2016;111:S134.

5. Crookes DM, Njoku O, Rodriguez MC, Mendez EI, Jandorf L. Promoting colorectal cancer screening through group education in community-based settings. J Cancer Educ Off J Am Assoc Cancer Educ. 2014;29:296–303.




