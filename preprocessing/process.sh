file=$1
if [ -d "${file}_output" ]; then
    echo "${file} Folder exists."
else
	file=$1
	SRSID=$(echo $file | grep -oE 'SRS[0-9]+')
	mkdir $SRSID
	prefetch $SRSID --output-directory $SRSID
	fastq-dump `ls $SRSID` && mv `ls $SRSID`.fastq ~/scripts/${file}.fastq
	perl split_pairend.pl ${file}.fastq && kallisto quant -i reference.idx -o ${file}_output  -b 100 -t 8 ${file}_1.fastq ${file}_2.fastq && rm ${file}.fastq ${file}_1.fastq ${file}_2.fastq
	echo "Finish ${file}"
fi
