@author M.Millard
@date 4 April 2023

Quick start:
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

After going through the code in these two examples (the comments will direct you to the relevant sections) you will be able to calculate the location of the fbos model in your own data.
