##### Load packages

library(tidyverse)
library(readxl)
library(searcher)
library(rvest)
library(data.table)
library(rstudioapi)

#####  Setup

#Clear the working environment
rm(list = ls()) 

#Directories
source('setup.R') ## bucket locations (not shared)
git_directory <- dirname(rstudioapi::getSourceEditorContext()$path)

#####  Get list of council websites

#Read page
councils_index <- "https://www.local.gov.uk/our-support/guidance-and-resources/communications-support/digital-councils/social-media/go-further/a-z-councils-online"
councils_index_read <- read_html(councils_index)

#Find URLs
council_pages <- councils_index_read %>%
  html_nodes(xpath="//a[contains(text(),'Council')]/@href") %>%
  html_text()

borough_pages <- councils_index_read %>%
  html_nodes(xpath="//a[contains(text(),'Borough')]/@href") %>%
  html_text()

other_pages_a <- councils_index_read %>%
  html_nodes(xpath="//a[contains(text(),'City of London')]/@href") %>%
  html_text()

other_pages_b <- councils_index_read %>%
  html_nodes(xpath="//a[contains(text(),'Milton Keynes')]/@href") %>%
  html_text()

other_pages_c <- councils_index_read %>%
  html_nodes(xpath="//a[contains(text(),'Isles of Scilly')]/@href") %>%
  html_text()

#Append
index_pages <- c(council_pages,borough_pages,other_pages_a,other_pages_b,other_pages_c)
rm(council_pages,borough_pages,other_pages_a,other_pages_b,other_pages_c)
rm(councils_index,councils_index_read)

#Clean and remove duplicates
index_pages <- index_pages[str_detect(index_pages,"gov.uk")] %>%
  unique(.) %>%
  as.data.frame() %>%
  rename(url=".") %>%
  mutate(council_name=word(url,2,2,sep=fixed('.'))) %>%
  arrange(council_name)

##### Generate search terms

#Create search terms
search_term <- '"fair cost of care"'
council_site <- index_pages$url
search_terms_pdf <- paste0(search_term," ","site:",council_site, " filetype:","pdf") %>%
  as.data.frame()

#Create Google search URL
#westminster_search <- search_google(search_term,rlang = FALSE)
#westminster_search_results <- read_html(westminster_search)

#Export search terms to be used by Outscraper
fwrite(search_terms_pdf,paste0(git_directory,"/Outscraper inputs/search_terms_pdf.csv"),header=FALSE)

##### Import Outscraper results

outscraper_pdf_results <- read_excel(paste0(git_directory,"/Outscraper outputs/20230222161745961f-search-results.xlsx"))

outscraper_pdf_results_relevant <- outscraper_pdf_results %>%
  filter(str_detect(tolower(title),"cost of care")) %>%
  mutate(council_name=str_extract_all(link,"(?<=https://www.).+(?=.gov.uk/)") %>% unlist())