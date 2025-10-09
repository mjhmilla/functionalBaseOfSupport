# Description

This is a collection of Matlab scripts that will demonstrate how to compute the location of a functional-base-of-support (fBOS) model given either plug-in-gait or an IOR marker data. In addition, there is an example that shows you how to construct your own fBOS model using example data. The fBOS is described in these papers:

  - Sloot LH, Millard M, Werner C and Mombaur K (2020) Slow but Steady: Similar Sit-to-Stand Balance at Seat-Off in Older vs. Younger Adults. Front. Sports Act. Living 2:548174. doi: 10.3389/fspor.2020.548174

  -  Millard M, Sloot LH. A polygon model of the functional base-of-support during standing improves the accuracy of balance analysis. Journal of Biomechanics. 2025 Sep 9:112927. https://doi.org/10.1016/j.jbiomech.2025.112927

  - Sloot LH, Gerhardy T, Mombaur K, Millard M. The size of the functional base of support decreases with age. bioRxiv. 2025:2025-05. https://doi.org/10.1101/2025.05.19.654897 (accepted by Scientific Reports)

All of the code and files in this repository are covered by the license mentioned in the SPDX file header which makes it possible to audit the licenses in this code base using the ```reuse lint``` command from https://api.reuse.software/. A full copy of the license can be found in the LICENSES folder. To keep the reuse tool happy even this file has a license:

 SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>

 SPDX-License-Identifier: MIT

Please note that csv files in the data folder do not have license headers though these files are also offered under the MIT license.

# Quick start
1. Make sure that the repository has the following files:

    - data/staticMarkerData/
        - footMarkersIorPig_Bare.csv
        - footMarkersIorPig_Shod.csv     
    - data/normBosModel/
        - normBosModelIorShod.csv  
        - normBosModelPigShod.csv  
        - normBosModelIorBare.csv  
        - normBosModelPigBare.csv  
    - data/normBosModelsYoungMidageOlderAdults
        - normBosModel_14MidageAdults_Footwear_2Feet_Ior_Sloot2025.csv
        - normBosModel_34OlderAdults_Footwear_2Feet_Ior_Sloot2025.csv
        - normBosModel_38YoungAdults_Footwear_2Feet_Ior_Sloot2025.csv

2. Set the Matlab path to the main location of the local repository (you can see the folders 'code','data' and 'output').

3. Run main_testPiGFunctionalBosModel.m. This function scales and plots the fBOS models and places them in the lab frame using marker data from a quiet standing trial. You should see a plot that contains:

  - The markers from 'footMarkersIorPig_Bare.csv'  
  - The foot frame location for the Ior marker set (blue, red, green dashed lines) and the Pig marker set (solid lines)
  - The functional bos model for the Ior marker set (dashed blue) and the Pig marker set (solid magenta)

4. Run main_plotAgeGroupFunctionalBOSModels.m. This function loads the fbos models from the younger, middle-aged, and older-adult age categories that are described in Sloot et al. (2025). You should see

  - A plot on the left that contains the normalized fBOS models from the younger, middle-aged, and older adults from Sloot 2025.
  - A plot on the right that compares the fBOS models of younger adults in different conditions measured in two different studies: Sloot et al. 2025 and Millard and Sloot 2025
  - This plot will be saved in output/fig_fbos_YoungerMiddleAgedOlderAdults.pdf

5. For an example of how to **apply** the functional base of support model to your own work, please run and carefully read the following example files. Make sure your path is set correctly to the main location of the local repository.

  - main_iorBosExample.m
  - main_pigBosExample.m

After going through the code in these two examples (the comments will direct you to the relevant sections) you will be able to calculate the location of the fBOS model in your own dat6.

6. For an example of how to **create** a fBOS model from data try running main_bosModelConstructionExample.m. If you are interested in creating your own fBOS model you will need to perform the experiments that are described in the publications mentioned in the description.

# Notes

Usually experimental data from motion capture and force plate systems is put into c3d file format. For the purposes of this example the c3d data has been converted to csv data so that the example can be run without any additional dependencies. When you want to apply this to your own data you will probably have to work with the c3d data directly. To do this, it is recommended to use the freely available program ezc3d available on github:

https://github.com/pyomeca/ezc3d