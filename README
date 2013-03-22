#########################################################################
# -- Author: Amos Folarin                                               #
# -- Organisation: KCL/SLaM                                             #
# -- Email: amosfolarin@gmail.com                                       #
#########################################################################


#------------------------------------------------------------------------
# Instructions for running the Genotyping Pipeline
# This will run both Zcall and Opticall on your post GenomeStudio 
# Exome chip data
#------------------------------------------------------------------------

---------------------------------REQUIREMENTS----------------------------

1) Sun Grid Engine
2) Zcall
3) Opticall





-----------------------------RUNNING THE PIPELINE------------------------

1) Read notes (GenomeStudio.SOP.v1.2.docx) on processing the data in GenomeStudio
2) Generate the GenomeStudio Report file (as required for by Zcall, parses this as input for both Zcall and Opticall rare callers):

	i) In GenomeStudio select 'Full Data Table' tab.
	ii) Click on 'Column Chooser' icon.
	iii) In Displayed Columns select 'Name', 'Chr','Position', and all your samples.
	iv) In Displayed Subcolumns select 'GType', 'X' and 'Y'.
	v) Hit OK then click on 'Export displayed data to a file' icon.

3) Copy the template.workflow.sh into a working directory
4) Edit the paths as indicated in this script for your installations of Zcall and Opticall etc.
5) Specify the datapath and basename variables for the GenomeStudio Report generated in step (2)
6) Execute the pipeline bash script.



