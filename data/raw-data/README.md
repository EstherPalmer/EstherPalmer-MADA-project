# raw-data

This folder should contain all raw data. As needed add sub-folders.

Currently, as an example, it contains a simple made-up data-set in an Excel file.

The dataset contains the variables `Height`, `Weight` and `Gender` of a few imaginary individuals.

The dataset purposefully contains some faulty entries that need to be cleaned.

Generally, any dataset should contain some meta-data explaining what each variable in the dataset is. (This is often called a **Codebook**.) For this simple example, the codebook is given as a second sheet in the Excel file.

This raw data-set should generally not be edited by hand. It should instead be loaded and processed/cleaned using code.

For my actual project, there are two Raw data files:

The first is a .txt file containing all of the CRISPR-SeroSeq (CSS) data for the daily sampling project. The original CSS files have already been completed, placed into a spreadsheet, normalized using DESeq2 and then averaged across the TT and RV samples. Column 1 contains all the serovars identified in this study, while row 1 lists the day of the project each sample was collected. For example, D1 was collected on Day 1 (which I need to check but I believe is 05/28/2024).
This file is set up for further analysis such as running a Jaccard analysis on this data.

The second file is an excel file containing all the weather and environmental data for the 6 months of the sampling for this project. Sheet 1 lists all the data including weekends, while sheet 2 excludes weekends. Including the weekend data might be important for things like "rain-day-before".

The two datasets will likely need to be merged before modeling.