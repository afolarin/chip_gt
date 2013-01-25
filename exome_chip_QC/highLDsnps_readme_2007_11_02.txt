To extract all "highLD" SNPs from a BIM file (all features in Table 1 of inversions paper), call:

cat yourdata.bim | awk -f /research/labs/goldsteinlab/Mike/Docs/EIGENSOFTplus/ver10/highLDregions4bim_b35.awk > yourHighLDsnps.txt
plink --bfile yourdata --exclude yourHighLDsnps.txt --make-bed --out yourdataNoHighLD