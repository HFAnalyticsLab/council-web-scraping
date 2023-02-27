## Use outscraper outputs to add pdfs to s3
library(aws.s3)

source('setup.R') ## bucket locations (not shared)

for (i in 34:nrow(outscraper_pdf_results_relevant)){
  
  download.file(outscraper_pdf_results_relevant$link[i],
                destfile = paste0(outscraper_pdf_results_relevant$title[i], '.pdf'),
                method = 'libcurl')
  
  put_object(paste0(outscraper_pdf_results_relevant$title[i], '.pdf'),
             object = paste0('fair_costs_of_care/', outscraper_pdf_results_relevant$title[i], '.pdf'),
             bucket = thf_bucket)
  
  unlink(paste0(outscraper_pdf_results_relevant$title[i], '.pdf'))

}
