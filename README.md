# Description

This is a collection of Matlab scripts that will demonstrate how to compute the location of a functional-base-of-support (FBOS) model given either plug-in-gait or an IOR marker data. In addition, there is an example that shows you how to construct your own FBOS model using example data. The FBOS is described in these papers:

  - Sloot LH, Millard M, Werner C and Mombaur K (2020) Slow but Steady: Similar Sit-to-Stand Balance at Seat-Off in Older vs. Younger Adults. Front. Sports Act. Living 2:548174. doi: 10.3389/fspor.2020.548174

  - Sloot LH, Gerhardy T, Mombaur K, and Millard M (2024) The basis of balance analysis: the functional base of support provided by the human foot. (in preparation)

# Quick start
1. Make sure that the data folder contains:

    Data_PiG_IOR_Static.mat  
    normBosModelIorShod.csv  
    normBosModelPigShod.csv
    normBosModelIorBare.csv  
    normBosModelPigBare.csv

2. Run main_testPiGFunctionalBosModel.m

3. You should see a plot that contains:

  a. The markers from 'Data_PiG_IOR_Static.mat' 
  b. The foot frame location for the Ior marker set (dashed lines) and the Pig marker set (solid lines)
  c. The functional bos model for the Ior marker set (dashed blue) and the Pig marker set (solid magenta)

4. For an example of how to apply the functional base of support model to your own work, please run and carefully read the following example files:

  a. main_iorBosExample.m
  b. main_pigBosExample.m

After going through the code in these two examples (the comments will direct you to the relevant sections) you will be able to calculate the location of the FBOS model in your own data.

5. For an example of how to create a FBOS model from data try running main_bosModelConstructionExample.m. If you are interested in creating your own FBOS model you will need to undertake the 