This is a work that replicated paper "Machine learning model for predicting Major Depressive Disorder using RNA-Seq data: optimization of classification approach"  Verma, Pragya and Shakya, Madhvi (2022).

This repo includes a paper, a poster and working folders.

Replicated flow 
- Prepare data & tools
  
  Download Homo_sapiens.GRCh37.dna.primary_assembly.fa and Homo_sapiens.GRCh37.87.gff3: https://ftp.ensembl.org/pub/grch37/release-104/
 
  Install NCBI download tool:  https://github.com/ncbi/sra-tools

  Download project data from NIH BioSample: https://www.ncbi.nlm.nih.gov/biosample?LinkName=bioproject_biosample_all&from_uid=394722

- Quantification

    files: contains all 59 sample for doing classification of CON / MDD / MDD-S

    In preprocessing folder, run command: `cat files | xargs -L ./process.sh`

    It will generate an estimate gene expression level for each sample (.h5 files)

- DGE and PCE

    In PCA_DGE_analysis folder, it contains R files for applying DGE and PCA to generate most significant transcripts from .h5 abundance files

- ML Analysis 
    
    In ML_analysis folder

    log2_transformed_1197_raw_transcripts.csv: 1197 raw transcripts

    top_1000_transcripts_adjusted_tpm: 1000 DGE transcripts (which we only use top 99 for ML Classification)

    Jupyter Notebook: ml_analysis.ipynb

