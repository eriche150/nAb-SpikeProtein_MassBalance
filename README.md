# nAb-SpikeProtein_MassBalance
Project: The evaluation of dosing for immunotherapies indicated for SARS-CoV-2 infection through mass balance analysis 

#Background
Convalescent serum taken from patients three-weeks after complete resolution of symptoms reveals there is a ratio of 1000-100,000 antibody:spike protein, and only 5% of endogenous antibodies produced specifically for spike protein are capable of neutralization. (https://doi.org/10.7554/elife.57264) This implies that an innate clearance of COVID-19 infection requires an astounding number of neutralizing antibodies relative to the number of active virions. 
This project focuses on several monoclonal antibodies approved under emergency use authorization (EUA) to treat acute COVID-19 infection: bamlanivimab, etesivimab. The motive for this project stems from two key biological findings: 
  1. SARS-CoV-2 virions use its spike protein to attach itself onto ACE-2 receptors expresseed on the surface of epithelial cells that line human respiratory airways. Therefore, the lungs are the major site of viral proliferation and harbor the highest concentration of viral load. 
  2. Monoclonal antibodies' physicochemical properties (molecular size, charge, among others) present as barriers of entry for its distribution into the peripherary and proximal organs (https://doi.org/10.4161/mabs.23684).
The PK data submitted as evidence to the FDA for the selected mAbs reviewed in this project all report either steady-state plasma concentrations or plasma concentrations plotted over time. We intend to evaluate the dosing of these mAbs by building a PK/PD + Viral Dynamics model to assess the number of active drug molecules within the lungs, and comparing that result to the number of viral antigens present.


##Model Structure
Inital estimates for model extracted from exploratory data analysis, literature.
Two-compartment monotherapy PK/PD model + viral dynamics model simulated with exponential growth/decay. 


If this disparity between number of antibodies to spike protein is true, then we should observe a similar ratio in monoclonal_Abx:spike protein, which implies that the number of Ab molecules >>>>> # spike protein 
Per results from clinical trials for EUA-monoclonal antibodies, there doesn't seem to be high enough concentration of therapy, or there is an observed lessened amount of Abx:SPIKE PROTEIN, not Abx:viron count. In order to explain the resolution of Sx, there must be an undiscovered additional MoA from these antibodies (which can explain resolution of Sx), or the dosing of the aforementioned mAb therapy is lower than optimal and can be improved to reduce treatment duration. 
