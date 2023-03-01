## Load in data as text from pdfs and clean up
library(pdftools)
library(tidyverse)
library(aws.s3)

get_bucket(thf_bucket, ## get all file paths
           prefix = 'fair_costs_of_care') %>%
           rbindlist() %>%
           select(Key) -> pdf_files

raw_data <- lapply( ## read into a list
  pdf_files$Key,
  function(f) {
    aws.s3::s3read_using(
      FUN = pdf_text,
      object = f,
      bucket = thf_bucket
    ) %>% 
      read_lines() %>%
      str_squish() %>%
      plyr::ldply()
  }
) %>% 
  bind_rows()

## Add cleaning / filtering here



## Alternative method to pre-search pdfs for keywords rather than reading all
library(pdfsearch)

s3read_using(keyword_search,
            keyword = c('measurement'),
            path = TRUE,
            remove_hyphen = FALSE,
            object = pdf_1,
            bucket = thf_bucket)
keyword_search()