# Web-scraping of council web pages to find Fair Cost of Care reports

#### Project Status: [In progress]

## Project Description and data sources

This code is intented to help find various Fair Cost of Care reports hosted online on council pages. It recursively searches for PDF files using Google Search, and then filters through the results to extract the relevant files.

In the future, we will write code to download each report and automatically extract tables from it.

### Requirements

These scripts were written in R version 4.0.2 and RStudio Version 1.1.383. 
The following R packages (available on CRAN) are needed:

* [**tidyverse**]
* [**searcher**]
* [**rvest**]

In addition, we also use the web-scraping tool Outscraper which is a private service with a small fee per process.

## Authors

* Sebastien Peytrignet - [Twitter](https://twitter.com/sebastienpeytr2) - [GitHub](sg-peytrignet)
* Jay Hughes  - [GitHub](Jay-ops256)

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
