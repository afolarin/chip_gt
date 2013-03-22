Filters from the CHARGE consortium -- untested..

To use the *.flt files will need to be placed in
C:\Users\<username>\AppData\Roaming\Illumina\GenomeStudio

Then go to the SNPTable view in GenomeStudio (funnel shaped button)
select from the dropdown the filter to apply
select load
select ok.



** QUESTION:
Should the subcolumn filters have ALL or ANY Columns as the primary variable?
Think this might be a problem in the SNP Review Filter


#--- CHARGE Filtering Protocol -----
# see CHARGE Consortium CHARGE_ExomeChip_Best_Practices_V6.pdf
# at http://web.chargeconsortium.com/main/Consortium-Documents

Filters for Steps in this protocol are provided here.


9) Apply filter criteria to the project based on the following conditions and visually
inspect and manually re-cluster autosomal SNPs when possible (exclude X, Y,
XY and MT loci since all were reviewed in step 8 above). Do not zero out SNPs.

* Use Filter: CHARGE_SNP_Review_Criteria.flt
 

11) Visually inspect SNPs with the following criteria and re-cluster those that look
recoverable.

* Use Filter: CHARGE_SNP_Flag_Criteria.flt


24) Exclude (zero out) SNPs based on the following criteria (applicable to all cohorts
in project):

* Use Filter: CHARGE_SNP_Exclusion_Criteria.flt


