
This repository contains analysis code and pre-processed data for the figures associated with the paper:

'Event structure sculpts neural population dynamics in the lateral entorhinal cortex'

Kanter et al., Science XXX, XXX (2025) [DOI: XXX]

The repository contains:
- Code to plot main and supplementary figures of the paper.
- Pre-processed data required to generate those figures.

Note that the data provided here is intended only for reproducing the paper figures.
The full dataset of neural and behavioral recordings is available in NWB format here: https://doi.org/10.25493/GTVB-FQR

The folder structure is as follows:
- data: pre-processed data required to generate figures, organized by behavioral task
- figures: code used to generate figures, organized by figure in the paper
- helpers: extra code dependencies

In the main folder there is also an Excel spreadsheet listing all recording sessions.

To get started, change the MATLAB directory to the root directory of this library (where this README file is located).
Next, edit and run the script update_directory.m.
This changes all references to file directories within the repository to reflect where the code is actually stored on your computer.

To generate the main figures, choose a subdirectory within the figures folder, e.g. drift.
Inside the folder is a make file that will generate all panels for that main figure.
To generate the supplementary figures, go one level further to the folder called supp and find the function of interest by name.

Any questions should be sent to the corresponding author of the paper, Benjamin R. Kanter (benjamin.kanter@ntnu.no).