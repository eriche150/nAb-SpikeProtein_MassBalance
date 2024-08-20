# nAb-SpikeProtein_MassBalance
Project: The evaluation of dosing for immunotherapies indicated for SARS-CoV-2 infection through mass balance analysis 

# Background
Convalescent serum taken from patients three-weeks after complete resolution of symptoms reveals there is a ratio of 1000-100,000 antibody:spike protein, and only 5% of endogenous antibodies produced specifically for spike protein are capable of neutralization. (https://doi.org/10.7554/elife.57264)   This implies that an innate clearance of COVID-19 infection requires an astounding number of neutralizing antibodies relative to the number of active virions. 
This project focuses on several monoclonal antibodies approved under emergency use authorization (EUA) to treat acute COVID-19 infection: bamlanivimab, etesivimab. The motive for this project stems from two key biological findings: 
  1. SARS-CoV-2 virions use its spike protein to attach itself onto ACE-2 receptors expresseed on the surface of epithelial cells that line human respiratory airways. Therefore, the lungs are the major site of viral proliferation and harbor the highest concentration of viral load. 
  2. Monoclonal antibodies' physicochemical properties (molecular size, charge, among others) present as barriers of entry for its distribution into the peripherary and proximal organs (https://doi.org/10.4161/mabs.23684).
The PK data submitted as evidence to the FDA for the selected mAbs reviewed in this project all report either steady-state plasma concentrations or plasma concentrations plotted over time. We intend to evaluate the dosing of these mAbs by building a PK/PD + Viral Dynamics model to assess the number of active drug molecules within the lungs, and comparing that result to the number of viral antigens present.


# Model Structure
Initial estimates for model extracted from exploratory data analysis from data provided by Young, et. al (https://www.nejm.org/doi/10.1056/NEJMc2001737)
Two-compartment mAb monotherapy PK/PD model + viral dynamics model; COVID-19 life cycle simulated through exponential growth/decay. 
The ordinary differential equations (ODE) used to fit Young data are as follows, 
'''model({
    a = (logVmax - logV0) / tp + eta.a;     # Growth rate calculation with random effect, eta.a
    B = (logVmax - logV0) / (tf - tp) + eta.B; # Decay rate calculation with random effect, eta.b

    # Define growth phase (0 <= t <= tp) and decay phase (t > tp) using a switch-like operation
    growthPhase = (t <= tp);
    decayPhase = (t > tp);

    d/dt(logV) = growthPhase * a - decayPhase * B;  # Combined growth and decay phase on log scale
    logV(0) = -1;
    logV ~ prop(prop.err)                    # Prediction equation with proportional error
  })'''


# Hypotheses
Immunotherapy dosing is considered effective if the model output reveals the ratio between number of active drug molecules:number of virus particles aligns with the previously reported 100-100,000 metric from literature.   If there reveals a disparity between these ratios, and  patients still fully recover from symptoms, then there is an exciting explanation for this phenom such that there may be an additional/hidden mechanism-of-action exhibited by these mAbs that allow for effective viral neutralization. 
