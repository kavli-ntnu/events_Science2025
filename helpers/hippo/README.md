# Hippo
 
### Introduction

Hippo is a MATLAB toolbox which adds functionality to the Behavioural Neurology Toolbox (BNT, created by Vadim Frolov, available at https://github.com/brkanter/BNT). It sits on top of BNT, therefore while BNT can be used without Hippo, Hippo requires installation of BNT. Hippo is updated shortly after BNT to ensure the two remain compatible.

The main purpose of this toolbox is to improve analysis efficiency at the level of the user. If exploring and analyzing data becomes faster and easier to do, it will be done more often and more exciting results will be uncovered. 

To achieve this goal, the toolbox does the following:

1) automates routine procedures (e.g. BNT input files)
2) increases user interaction
3) performs batch analysis of large datasets
4) stores data in an easily accessible format
5) provides intuitive filtering to extract useful information quickly
 
### Installation

Clone or download from here: https://github.com/brkanter/hippo
 
### Toolbox contents

+calc: specific analyses (e.g. spike width, object responses, theta phase)

+examples: examples and instructions (probably very outdated)

+extract: extracting data of interest

+meta: analyzing multiple recording sessions or entire projects

+minions: helper functions

+plt: plotting functions

Extras: various things from MathWorks File Exchange, and some modifications/additions to BNT functions

### Parameters

Many functions in Hippo and BNT require parameters (e.g. spatial bin width). Hippo uses a global structure called hippoGlobe to store default parameters which are made available to its functions. Very few parameters are hard-coded in Hippo; the functions either prompt the user for input, or use the defaults from hippoGlobe. 

The values in hippoGlobe are initially set using a MATLAB startup file (startup.m). See examples.startupExample to see how to make one, and make sure this file is above BNT on your path, otherwise it will not be used. You must have hippoGlobe to use Hippo (though you do not need to use a startup file to create it).

### Getting started

Ensure that your parameters are correct by typing hippoGlobe at the command line. If you get an error, run your startup file to initialize hippoGlobe. 

Type exploreDataBNT at the command line and select a recording session where you have already cut some clusters. The data will be loaded by BNT, and you should see a plot with the path of the animal and a list of all the clusters that were found. Note that you did not have to explicitly make a BNT input file; it was created automatically for you by Hippo. Now that the data is loaded, you can use any BNT functions you like to explore your data (e.g. data.getPositions, data.getSpikeTimes, analyses.map). Try combining BNT and Hippo functions like this:   calc.ISI(data.getSpikeTimes([2 1]),1);

Penguin is a graphical user interface for analyzing data from a single recording session. Type penguin at the command line to get started. There should be no instructions needed, as the interface is designed to be intuitive and user-friendly. Simply load data by clicking Video folder or MClust. The latter loads data directly from an open MClust session and will include all clusters exported to the MClust main window, even if they are not yet saved.

Perhaps the highlight of Hippo is its meta analysis capabilities. Preprocess all of your data from an experiment (or more than one) using emperorPenguin, which outputs an Excel file of your results. You could stop here and look at the data in Excel, but at this point you don’t have access to things like rate maps. When you’re ready to look at many experiments together, follow the steps provided in examples.metaAnalysisWorkflow to get your data back into MATLAB. Soon you will have all of your data in a single neat MATLAB array. See examples.analysisIntro for a full guide explaining how to quickly extract the information you want from this array.

Creator and main developer: Benjamin R. Kanter (brkanter (at) gmail (dot) com)