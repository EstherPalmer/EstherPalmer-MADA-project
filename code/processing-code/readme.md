# processing-code

This folder contains code for processing data.

I loaded several documents containing data for cleaning/processing.

Firstly I have a document containing all the environmental/weather data for the daily 6 months of sampling
This file contains the following variables:
        Day: Numerical count from start of sampling
        Date: Date sample was taken
        Weekday: day of the week sample was taken
        COND: conductivity measurment taken at time of sampling
        TDS: total dissolved solids measurement taken at time of sampling
        SALT: salinity measurement taken at time of sampling
        pH: pH measurement taken at time of sampling
        DO: dissolved oxygen taken at time of sampling
        TEMP: temperature of the water in Degrees celcius taken at time of sampling
        Flow: flow rate of the water I think in m/s? taken at time of sampling (there are 3, need to be averaged)
        DEPTH(cm): depth of water in cm taken at time of sampling
        WIDTH: width of creek in feet/inches taken at time of sampling
        Max Temp: maximum air temperature that day in degrees farenhieght taken from a weather station
        MinTemp: minimum air temperature that day in degrees farenhieght taken from a weather station
        R.H(%): relative humidity taken from a weather station
        2 in soil temp: 2 inch soil temperature taken from a weather station
        4 in soil temp: 4 inch soil temperature taken from a weather station
        8 in soil temp: 8 inch soil temperature taken from a weather station
        Wind Speed: wind speed taken from a weather station
        Total radiation: total radiation (sunshine) taken from a weather station
        Rain (in): Rainfall in inches taken from a weather station
        ET: evapotranspiration? taken from a weather station
        TURBIDITY: turbidity of water measured by the Lipp lab from a sample collected at time of sampling

        
Secondly I have a document containing the CRISPR-SeroSeq data from the same 6 months of sampling
CRISPR-SeroSeq is a techinique that allows us to determine the _Salmonella_ serovar population within a given sample.
We do this by amplifying and sequencing the CRISPR spacers
There's a lot of processing that going into turning raw reads into usable data but the TLDR is that for this project
I have a file containing a matrix of serovars and samples, filled with the proportion of each serovar in a sample