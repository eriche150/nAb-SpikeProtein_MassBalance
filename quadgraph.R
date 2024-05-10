#Plot four curves on one graph: number of Ab in plasma & lungs, VL after Rx admin, VL placebo. 

#df containing number of BAM in plasma and lungs, and VL after Rx admin 
bam_vd_trial_df_lungs #per Rx_logVD.rmd
names(bam_vd_trial_df_lungs)

#Convert concentration to number of molecules in plasma and lungs
bam_df <- bam_vd_trial_df_lungs %>% 
        mutate(molecules_plasma = conc_A1_nM * (1/146000) * (6.022e23),
               molecules_lungs = BAM_lungs * (1/146000) * (6.022e23)) %>% 
        select("time","conc_A1_nM","molecules_plasma","BAM_lungs","molecules_lungs","logV") %>% 
        rename("TIME" = "time")
bam_df1 <- bam_df %>% 
        mutate(VL_mAb = (10^logV)*1000, #multiply by 1000 to convert from RNA copies/mL to RNA copies
               R_rx = VL_mAb*30)
#Since the efficacy of the mAbs are estimated to completely eliminate the virus,we will try to compare the molecules_mAb with 
#VL placebo instead of VL experimental arm

#Extract baseline VL from logfit_run1's predicted viral load from viral dynamics model 
placebo_VL <- logfit_run1 %>% 
        group_by(TIME) %>%
        slice(1) %>% 
        ungroup() %>% 
        select(TIME, PRED) %>% 
        arrange(TIME) %>%
        mutate(VL_no_mAb = (10^PRED)*1000,
               R = VL_no_mAb*30) 

                
#Consolidate the two df's into one 
trigraphdf <- left_join(bam_df1, placebo_VL,
                        by="TIME") %>% 
        arrange(TIME)

#Plot 
trigraph <- trigraphdf %>% 
        ggplot()+
        geom_line(aes(x = TIME, y = molecules_plasma, color = "nmol BAM Plasma"))+
        geom_line(aes(x = TIME, y = molecules_lungs, color = "nmol BAM Lung"))+
        geom_line(aes(x=TIME, y=R, color="nmol Viral Spike Protein"))+
        geom_line(aes(x=TIME, y=R_rx,color = "nmol Viral Spike Protein after mAb administration"))+
        geom_hline(yintercept = 1, linetype="dashed", color = "blue")+
        xlab("Time (days)")+
        ylab("Number of molecules")+
        labs(title="Molecule count and total viral receptors available for binding upon administration of 700 mg bamlanivimab")+
        scale_y_log10(breaks=c(1e0,1e4,1e21,1e22))+
        scale_x_continuous(breaks=c(0,1,2,3,7,10,14,21,25,28))+
        theme_bw()
trigraph

#Save the plot
ggsave("trigraph.png",plot=trigraph,width=10,height=6,units="in",dpi=600)

#Calculate Ratio of nAb:spike protein by lowest nmol (in lungs) x Vmax (placebo VL)
min(trigraphdf$molecules_lungs) #1.308001e+20
max(trigraphdf$R,na.rm=TRUE)  #4.355500e+08
1.308001e+20/4.355500e+08 #3.003102e+11

min(trigraphdf_ete$molecules_lungs) #5.891281e+20
max(trigraphdf_ete$R,na.rm=TRUE) #4.355500e+08
5.891281e+20/4.355500e+08 #1.352102e+12

#Conduct identical 1:1 analysis to ETE 
ete_vd_trial_df_lungs #per Rx_logVD.rmd
names(ete_vd_trial_df_lungs)

#Convert concentration to number of molecules in plasma and lungs
ete_df <- ete_vd_trial_df_lungs %>% 
        mutate(molecules_plasma = conc_A1_nM_lungs * (1/145000) * (6.022e23),
               molecules_lungs = ETE_lungs * (1/145000) * (6.022e23)) %>% 
        select("time","conc_A1_nM_lungs","molecules_plasma","ETE_lungs","molecules_lungs","logV") %>% 
        rename("TIME" = "time")
ete_df1 <- ete_df %>% 
        mutate(VL_mAb = (10^logV)*1000,
               R_rx = VL_mAb*30)
trigraphdf_ete <- left_join(ete_df1, placebo_VL,
                        by="TIME") %>% 
        arrange(TIME)
#Extract nmol ETE lung & plasma from trigraphdf_ete and insert into trigraphdf
# Merge BAM and ETE dataframes by TIME
quadgraphdf <- left_join(trigraphdf, trigraphdf_ete, by = "TIME")
# Clean up the names to distinguish between BAM and ETE values
quadgraphdf <- quadgraphdf %>%
        rename(
                molecules_plasma_BAM = molecules_plasma.x,
                molecules_lungs_BAM = molecules_lungs.x,
                molecules_plasma_ETE = molecules_plasma.y,
                molecules_lungs_ETE = molecules_lungs.y,
                R_BAM = R_rx.x,
                R_ETE = R_rx.y,
                R = R.x,
        ) %>%
        select(-(R.y))  #some col. offer redudant info like R.x/R.y
# Select only the relevant columns for plotting
quadgraphdf_1 <- quadgraphdf %>%
        select(
                TIME,
                molecules_plasma_BAM, molecules_lungs_BAM,
                molecules_plasma_ETE, molecules_lungs_ETE,
                R, R_BAM, R_ETE
        )
names(quadgraphdf_1)
#Plot
quadgraph <- quadgraphdf_1 %>% 
        ggplot() +
        geom_line(aes(x = TIME, y = molecules_plasma_ETE, color = "nmol ETE Plasma", linetype = "ETE Plasma")) +
        geom_line(aes(x = TIME, y = molecules_lungs_ETE, color = "nmol ETE Lung", linetype = "ETE Lung")) +
        geom_line(aes(x = TIME, y = molecules_plasma_BAM, color = "nmol BAM Plasma", linetype = "BAM Plasma")) +
        geom_line(aes(x = TIME, y = molecules_lungs_BAM, color = "nmol BAM Lung", linetype = "BAM Lung")) +
        geom_line(aes(x = TIME, y = R, color = "nmol Spike Protein", linetype = "Spike Protein")) +
        geom_line(aes(x = TIME, y = R_BAM, color = "nmol Spike Protein after BAM administration", linetype = "Spike Protein BAM")) +
        geom_line(aes(x = TIME, y = R_ETE, color = "nmol Spike Protein after ETE administration", linetype = "Spike Protein ETE")) +
        geom_hline(yintercept = 1, linetype = "dashed", color = "blue") +
        xlab("Time (days)") +
        ylab("Number of molecules") +
        labs(title = "Molecule count and total spike protein available for binding before and after administration of 700 mg bamlanivimab or 1400 mg etesevimab") +
        scale_y_log10(breaks = c(1e0, 1e4, 1e21, 1e22)) +
        scale_x_continuous(breaks = c(0, 1, 2, 3, 7, 10, 14, 21, 25, 28)) +
        theme_bw() +
        scale_color_manual(values = c(
                "nmol ETE Plasma" = "lightblue",
                "nmol ETE Lung" = "darkblue",
                "nmol BAM Plasma" = "lightcoral",
                "nmol BAM Lung" = "darkred",
                "nmol Spike Protein" = "gray",
                "nmol Spike Protein after BAM administration" = "darkmagenta",
                "nmol Spike Protein after ETE administration" = "darkorchid"
        )) +
        scale_linetype_manual(values = c(
                "ETE Plasma" = "solid",
                "ETE Lung" = "twodash",
                "BAM Plasma" = "solid",
                "BAM Lung" = "twodash",
                "Spike Protein" = "solid",
                "Spike Protein BAM" = "solid",
                "Spike Protein ETE" = "solid"
        ))

quadgraph

quadgraph <- ggplot() +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_plasma_ETE, color = "nmol ETE Plasma"), linetype = "solid") +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_lungs_ETE, color = "nmol ETE Lung"), linetype = "twodash") +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_plasma_BAM, color = "nmol BAM Plasma"), linetype = "solid") +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_lungs_BAM, color = "nmol BAM Lung"), linetype = "twodash") +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = R, color = "nmol Spike Protein"), linetype = "solid") +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = R_BAM, color = "nmol Spike Protein after BAM administration"), linetype = "solid") +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = R_ETE, color = "nmol Spike Protein after ETE administration"), linetype = "solid") +
        scale_color_manual(
                name = "Legend",
                values = c(
                        "nmol ETE Plasma" = "lightblue",
                        "nmol ETE Lung" = "darkblue",
                        "nmol BAM Plasma" = "lightcoral",
                        "nmol BAM Lung" = "darkred",
                        "nmol Spike Protein" = "grey",
                        "nmol Spike Protein after BAM administration" = "darkorchid",
                        "nmol Spike Protein after ETE administration" = "deeppink1"
                ),
                labels = c(
                        "ETE Plasma" = "ETE Plasma (nmol)",
                        "ETE Lung" = "ETE Lung (nmol)",
                        "BAM Plasma" = "BAM Plasma (nmol)",
                        "BAM Lung" = "BAM Lung (nmol)",
                        "Spike Protein" = "Spike Protein (nmol)",
                        "Spike Protein after BAM administration" = "Spike Protein after BAM (nmol)",
                        "Spike Protein after ETE administration" = "Spike Protein after ETE (nmol)"
                )
        ) +
        scale_linetype_manual(
                name = "Guide name",
                values = c(
                        "ETE Plasma" = "solid",
                        "ETE Lung" = "twodash",
                        "BAM Plasma" = "solid",
                        "BAM Lung" = "twodash",
                        "Spike Protein" = "solid",
                        "Spike Protein BAM" = "solid",
                        "Spike Protein ETE" = "solid"
                )
        ) +
        labs(
                title = "Molecule count and total spike protein available for binding before and after administration of 700 mg bamlanivimab or 1400 mg etesevimab",
                y = "Number of molecules",
                x = "Time (days)",
                color = "Guide name",
                linetype = "Guide name"
        ) +
        theme_bw() +
        theme(legend.position = "right")

print(quadgraph)


quadgraph_log <- ggplot() +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_plasma_ETE, color = "nmol ETE Plasma"), linetype = "solid", size = 1.25) +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_lungs_ETE, color = "nmol ETE Lung"), linetype = "twodash", size = 1.25) +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_plasma_BAM, color = "nmol BAM Plasma"), linetype = "solid", size = 1.25) +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = molecules_lungs_BAM, color = "nmol BAM Lung"), linetype = "twodash", size = 1.25) +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = R, color = "nmol Spike Protein"), linetype = "solid", size = 1.25) +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = R_BAM, color = "nmol Spike Protein after BAM administration"), linetype = "solid", size = 1.25) +
        geom_line(data = quadgraphdf_1, aes(x = TIME, y = R_ETE, color = "nmol Spike Protein after ETE administration"), linetype = "solid", size = 1.25) +
        geom_hline(yintercept = 1e1, linetype="dashed", color = "blue") + # LLOQ, keep the default size
        scale_color_manual(
                name = "Legend",
                values = c(
                        "nmol ETE Plasma" = "lightblue",
                        "nmol ETE Lung" = "darkblue",
                        "nmol BAM Plasma" = "lightcoral",
                        "nmol BAM Lung" = "darkred",
                        "nmol Spike Protein" = "grey",
                        "nmol Spike Protein after BAM administration" = "darkorchid",
                        "nmol Spike Protein after ETE administration" = "deeppink1"
                ),
                labels = c(
                        "ETE Plasma" = "ETE Plasma (nmol)",
                        "ETE Lung" = "ETE Lung (nmol)",
                        "BAM Plasma" = "BAM Plasma (nmol)",
                        "BAM Lung" = "BAM Lung (nmol)",
                        "Spike Protein" = "Spike Protein (nmol)",
                        "Spike Protein after BAM administration" = "Spike Protein after BAM (nmol)",
                        "Spike Protein after ETE administration" = "Spike Protein after ETE (nmol)"
                )
        ) +
        scale_linetype_manual(
                name = "Legend",
                values = c(
                        "ETE Plasma" = "solid",
                        "ETE Lung" = "twodash",
                        "BAM Plasma" = "solid",
                        "BAM Lung" = "twodash",
                        "Spike Protein" = "solid",
                        "Spike Protein BAM" = "solid",
                        "Spike Protein ETE" = "solid"
                )
        ) +
        scale_y_log10(breaks = c(1e-4, 1e1, 1e8,1e10, 1e20,1e22),limits=c(1e-1,1e24)) +
        labs(
                title = "Molecule count and total spike protein available for binding before and after administration of 700 mg bamlanivimab or 1400 mg etesevimab",
                y = "Number of molecules",
                x = "Time (days)",
                color = "Guide name",
                linetype = "Guide name"
        ) +
        theme_bw() +
        theme(legend.position = c(0.8,0.5),
              legend.background=element_rect(fill="white", colour="black"),
              legend.title=element_text(size=18),#graph title size 
              axis.text=element_text(size=15),#tickmark sizes
              axis.title=element_text(size=16)) #x/y title size

print(quadgraph_log)

ggsave("quadgraph.png",plot=quadgraph_log,width=13,height=8,units="in",dpi=600)

