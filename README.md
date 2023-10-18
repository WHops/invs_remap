# invs_remap
A repo collecting scripts and information for our read remapping procedure for better detection of inversions ~50bp - 1kbp 

## Approach
<img src="https://github.com/WHops/invs_remap/blob/main/flowchart.png?raw=true">

## First step

1) Calculate the coverage AND the 'matchrate' in 50bp bins

## Second Step

2) Select the regions that have a high mismatch rate and for which mismatched bps cover at least 10% of the total mismatches.

## Third Step

3) Remove the overlapping SD and centromeric regions

## Fourth Step

4) Remap these regions with NGMLR

## Fifth Step

5) Call SVs on the remapped regions with Delly



