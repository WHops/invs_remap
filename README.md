# invs_remap
A repo collecting scripts and information for our read remapping procedure for better detection of inversions ~50bp - 1kbp 

## Approach
<img src="https://github.com/WHops/invs_remap/blob/main/flowchart.png?raw=true">

## First step

1) Calculate the coverage AND the 'matchrate' in 50bp bins

## Second Step

2) Select the regions that have a mismatchrate of ~20% and for which mismatches cover at least 10%

## Third Step

3) Remove the overlapping SD regions

## Fourth Step

4) Remap these regions with NGMLR

## Fifth Step

5) Call SVs on the remapped regions with Delly



