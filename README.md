# invs_remap
A repo collecting scripts and information for our read remapping procedure for better detection of inversions ~200bp - 1kbp 

## Approach
<img src="https://github.com/WHops/invs_remap/blob/main/flowchart.png?raw=true">

## Usage

To calculate the coverage AND the 'matchrate' in 100bp bins, run: 

```bash
bash scripts/calc_cov_and_matchrate.sh in_reads.bam in_ref.fa output_cov_mismatch.tsv
```

in our case, this could be e.g: 

```bash
mkdir res
bash scripts/calc_cov_and_matchrate.sh data/simulated/run2/coverage_100250_11000-12000_minimap_sorted.bam data/simulated/ref.fa res/cov_mismatch.tsv

```


## Next steps

pysamtools seems to be quite slow with a larger bam file. We need to find a way around this. 