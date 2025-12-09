# HW7 API Server

library(plumber)
library(tidyverse)
library(lubridate)
library(jsonlite)

# Load model + supporting data
model = readRDS("no_show_logistic_model.rds")
threshold_info = readRDS("threshold_info.rds")
prov_hist = readRDS("prov_hist.rds")
pat_hist = readRDS("pat_hist.rds")

# Helper function to preprocess input data
preprocess_data = function(df) {
  # Convert datetime columns
  df = df %>%
    mutate(
      appt_time = as_datetime(appt_time),
      appt_made = as_datetime(appt_made),
      lead_time_days = as.numeric(difftime(appt_time, appt_made, units = "days")),
      appt_hour = hour(appt_time),
      dow = wday(appt_time, label = TRUE, abbr = TRUE),
      is_weekend = if_else(dow %in% c("Sat", "Sun"), 1, 0),
      is_evening = if_else(appt_hour >= 17, 1, 0)
    )
  
  # Join historical no-show rates
  df = df %>%
    left_join(pat_hist, by = "id") %>%
    left_join(prov_hist, by = "provider_id") %>%
    mutate(
      across(c(patient_no_show_rate, provider_no_show_rate), ~coalesce(., 0)),
      provider_id = factor(provider_id),
      specialty = factor(specialty),
      dow = factor(dow),
      address = factor(address)
    )
  
  return(df)
}

#* @apiTitle No-Show Prediction API
#* @apiDescription API for predicting patient appointment no-shows

#* Predict probability of no-show
#* @param req The request object
#* @post /predict_prob
#* @serializer unboxedJSON
function(req) {
  # Parse the JSON body
  df = jsonlite::fromJSON(req$postBody)$df
  df = as.data.frame(df)
  
  # Preprocess the input data
  processed_df = preprocess_data(df)
  
  # Generate predictions
  predictions = predict(model, newdata = processed_df, type = "response")
  
  # Return as numeric vector
  return(as.numeric(predictions))
}

#* Predict class (0 or 1) of no-show
#* @param req The request object
#* @post /predict_class
#* @serializer unboxedJSON
function(req) {
  # Parse the JSON body
  df = jsonlite::fromJSON(req$postBody)$df
  df = as.data.frame(df)
  
  # Preprocess the input data
  processed_df = preprocess_data(df)
  
  # Generate probability predictions
  predictions = predict(model, newdata = processed_df, type = "response")
  
  # Convert to binary class using threshold
  threshold = threshold_info$threshold
  class_predictions = as.numeric(predictions >= threshold)
  
  # Return as binary vector
  return(as.integer(class_predictions))
}