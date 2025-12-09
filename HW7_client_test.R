# HW7 Client Test

library(httr)
library(jsonlite)
library(tidyverse)

# API base URL
base_url = "http://127.0.0.1:8000"

# Load test data to get valid sample rows
test = read_csv("test_dataset.csv.gz", show_col_types = FALSE)

# Use actual rows from the test set as our sample (up to 3 rows, or however many exist)
n_rows = min(7, nrow(test))
test_data = test %>%
  select(id, provider_id, address, age, specialty, appt_time, appt_made) %>%
  head(n_rows) %>%
  as.data.frame()

# Print test data
cat("Test data:\n")
print(test_data)
cat("\n")

# Test 1: predict_prob endpoint
cat("Testing /predict_prob endpoint...\n")
response_prob = POST(
  url = paste0(base_url, "/predict_prob"),
  body = list(df = test_data),
  encode = "json",
  content_type_json()
)

# Check response status
if (status_code(response_prob) == 200) {
  cat("✓ predict_prob endpoint successful\n")
  
  # Unserialize the response
  prob_predictions = content(response_prob, as = "parsed", type = "application/json")
  
  cat("Probability predictions:\n")
  print(unlist(prob_predictions))
  cat("\n")
  
  # Validate output
  prob_vec = unlist(prob_predictions)
  cat(sprintf("Number of predictions: %d\n", length(prob_vec)))
  cat(sprintf("All values between 0 and 1: %s\n", all(prob_vec >= 0 & prob_vec <= 1)))
  cat(sprintf("Expected length matches input: %s\n\n", length(prob_vec) == nrow(test_data)))
  
} else {
  cat("✗ predict_prob endpoint failed\n")
  cat(sprintf("Status code: %d\n", status_code(response_prob)))
  cat("Response content:\n")
  print(content(response_prob, as = "text"))
  cat("\n")
}

# Test 2: predict_class endpoint
cat("Testing /predict_class endpoint...\n")
response_class = POST(
  url = paste0(base_url, "/predict_class"),
  body = list(df = test_data),
  encode = "json",
  content_type_json()
)

# Check response status
if (status_code(response_class) == 200) {
  cat("✓ predict_class endpoint successful\n")
  
  # Unserialize the response
  class_predictions = content(response_class, as = "parsed", type = "application/json")
  
  cat("Class predictions:\n")
  print(unlist(class_predictions))
  cat("\n")
  
  # Validate output
  class_vec = unlist(class_predictions)
  cat(sprintf("Number of predictions: %d\n", length(class_vec)))
  cat(sprintf("All values are 0 or 1: %s\n", all(class_vec %in% c(0, 1))))
  cat(sprintf("Expected length matches input: %s\n\n", length(class_vec) == nrow(test_data)))
  
} else {
  cat("✗ predict_class endpoint failed\n")
  cat(sprintf("Status code: %d\n", status_code(response_class)))
  cat("Response content:\n")
  print(content(response_class, as = "text"))
  cat("\n")
}

# Summary
cat("=== Test Summary ===\n")
cat(sprintf("predict_prob status: %s\n", 
            ifelse(status_code(response_prob) == 200, "PASS", "FAIL")))
cat(sprintf("predict_class status: %s\n", 
            ifelse(status_code(response_class) == 200, "PASS", "FAIL")))
cat("\n")

cat("Note: To run this test, first start the API server by running:\n")
cat("  library(plumber)\n")
cat("  pr = plumb('HW7_api_server.R')\n")
cat("  pr$run(port = 8000)\n")