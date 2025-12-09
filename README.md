# Homework 7: Model API

This repository contains a Plumber API for the patient no-show prediction model from Homework 4.

## Files
- `HW7_api_server.R` - API server with two endpoints for predictions
- `HW7_client_test.R` - Test script to verify API endpoints work correctly
- `no_show_logistic_model.rds` - Trained logistic regression model
- `threshold_info.rds` - Optimal threshold for binary classification
- `prov_hist.rds` - Provider historical no-show rates
- `pat_hist.rds` - Patient historical no-show rates
- `test_dataset.csv.gz` - Test data for validation

## How to Run

### Step 1: Start the API Server
In RStudio, open `HW7_api_server.R` and run:
```r
library(plumber)
pr <- plumb('HW7_api_server.R')
pr$run(port = 8000)
```

Alternatively, click the "Run API" button at the top of the script in RStudio.

The server will start and display: `Running plumber API at http://127.0.0.1:8000`

### Step 2: Test the API
Open a new R session (Session → New Session in RStudio) and run:
```r
source('HW7_client_test.R')
```

This will test both API endpoints (`/predict_prob` and `/predict_class`) and display the results.

## API Endpoints

### POST /predict_prob
Returns probability of no-show (0-1) for each appointment.

**Input:** JSON object with a data frame containing appointment features  
**Output:** Numeric vector of probabilities

### POST /predict_class
Returns binary prediction (0 or 1) for each appointment, where 1 indicates a no-show.

**Input:** JSON object with a data frame containing appointment features  
**Output:** Integer vector of binary predictions

## Requirements
- R packages: `plumber`, `tidyverse`, `lubridate`, `jsonlite`, `httr`
- All `.rds` files and `test_dataset.csv.gz` must be in the same directory as the R scripts

