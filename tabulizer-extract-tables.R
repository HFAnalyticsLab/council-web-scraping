##### Install packages if needed

#install.packages("devtools")
#devtools::install_github("ropensci/rJava")
#devtools::install_github("ropensci/tabulizer")

##### Load packages

library(tidyverse)
library(readxl)
library(aws.s3)
library(pdftools)
library(data.table)
#library(tabulizer)
#library(xlsx)

#####  Setup

#Clear the working environment
rm(list = ls()) 

#Directories
source('setup.R') ## bucket locations (not shared)
git_directory <- dirname(rstudioapi::getSourceEditorContext()$path)

#####  Import Outscraper results (again)

outscraper_pdf_results <- read_excel(paste0(git_directory,"/Outscraper outputs/20230222161745961f-search-results.xlsx"))

outscraper_pdf_results_relevant <- outscraper_pdf_results %>%
  filter(str_detect(tolower(title),"cost of care")) %>%
  mutate(council_name=str_extract_all(link,"(?<=https://www.).+(?=.gov.uk/)") %>% unlist()) %>%
  select(council_name,title,link)

#####  Read in tables in PDFs

#Try-catch versions of pdf_text and extract_table, so that the loop keeps going if a link is broken or there are no tables in the PDF
try_pdf_text <- function(link){
  tryCatch(
    {
      return(pdf_text(link))
    },
    error=function(e) {
      message('An Error Occurred')
      return(NA)
    },
    warning=function(w) {
      message('A Warning Occurred')
      return(NA)
    }
  )
}
try_extract_table <- function(link,pagenums){
  tryCatch(
    {
      return(tabulizer::extract_tables(link,pages=pagenums))
    },
    error=function(e) {
      message('An Error Occurred')
      return(list())
    },
    warning=function(w) {
      message('A Warning Occurred')
      return(list())
    }
  )
}

#Initialize empty list
output_list <- list()

#Populate list with tables from reports in a loop
#outscraper_pdf_results_relevant <- outscraper_pdf_results_relevant[1:10,]

for (i in 1:nrow(outscraper_pdf_results_relevant)){
  #Progress bar
  print(paste0(round(i/nrow(outscraper_pdf_results_relevant)*100,0),"%"))
  
  #Find pages inside PDF that include £ sign
  read_text_aux <- try_pdf_text(outscraper_pdf_results_relevant$link[i])
  pages_with_table <- which(str_detect(read_text_aux,"£"))
  
  #Extract tables from those pages
  tables_aux <- try_extract_table(outscraper_pdf_results_relevant$link[i],pages_with_table)
  
  #If any found, append them to results list
  if(length(tables_aux)>0){
    names(tables_aux) <- paste(outscraper_pdf_results_relevant$council_name[i],
                               paste0("table ",1:length(tables_aux)),
                               outscraper_pdf_results_relevant$title[i],sep=" ")
    
    if(i==1){output_list <- tables_aux} else{output_list <- append(output_list,tables_aux)}
    #output_list[[(length(output_list)+1):(length(output_list)+length(tables_aux))]] <- tables_aux
  }
    else{}
}


#Save output (and read back in)
saveRDS(output_list, file=paste0(git_directory,"/Tabulizer outputs/tabulizer-output-list.Rdata"))
tabulizer_output_list <- readRDS(paste0(git_directory,"/Tabulizer outputs/tabulizer-output-list.Rdata"))

#Cover spreadsheet with title of extracts

cover_sheet <- data.frame(`name`=names(tabulizer_output_list),
                          `sheet index`=1:length(tabulizer_output_list))

fwrite(cover_sheet,paste0(git_directory,"/Tabulizer outputs/tabulizer-cover-sheet.csv"))

#Append tables to spreadsheet

# wb <- createWorkbook()
# datas <- list(USArrests, USArrests * 2)
# sheetnames <- paste0("Sheet", seq_along(output_list)) # or names(datas) if provided
# sheets <- lapply(sheetnames, createSheet, wb = wb)
# void <- Map(addDataFrame, datas, sheets)
# saveWorkbook(wb, file = paste0(git_directory,"/council-web-scraping-output.xlsx"))