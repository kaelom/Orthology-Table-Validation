#!/bin/bash
#SBATCH --partition=production # partition to submit to
#SBATCH --job-name="orth_sort1" # Job name
#SBATCH --nodes=1 # single node, anything more than 1 will not run
#SBATCH --ntasks=7 # equivalent to cpus, stick to around 20 max on gc64, or gc128 nodes
#SBATCH --mem=10000 # in MB, memory pool all cores, default is 2GB per cpu
#SBATCH --time=72:00:00  # expected time of completion in hours, minutes, seconds, default 1-day
#SBATCH --output=orthsort1.out # STDOUT
#SBATCH --error=orthsort1.err # STDERR
#SBATCH --mail-user=kdlombardo@ucdavis.edu # does not work yet
#SBATCH --mail-type=ALL

#FALL 2018 - Kae Lombardo - Kopp Lab Transcriptome Turnover Project - Preliminary Orthology Table Validation
#check if a gene family is EXACTLY the same across the 4 orthology tables, add identifer for which table(s) the family is found in

cd ~/share/kopplab/kae/orthoproj/programs

rm *_sorted.txt

for all in dump*; do
    filename=$all
    echo $filename
    sortedfile=$filename"_sorted.txt"
    echo $sortedfile
    while read i; do
        echo $i | xargs -n1 | sort | xargs ; done < $all >> $sortedfile; # line -> column -> sort -> line
done

echo '' > completelist.txt
echo '' > finalfile.txt

for tables in *_sorted.txt; do #comparison for each sorted orthology table (sorted)
    echo looking through the following file...$tables
    filename=$tables # make sure it doesn't check the current...
    while read i; do #read each line
        if [[ -n $(grep -x "$i" completelist.txt) ]]; then 
            echo $i has already been analyzed
        else
            count=0
            if [[ $tables = dump.blastp_drosophila_protein.mci.I14_sorted.txt ]]; then
                count=$((count+1))
                echo it has been discovered inside 14
                echo $count
            elif [[ $tables = dump.blastp_drosophila_protein.mci.I20_sorted.txt ]]; then
                count=$((count+10))
                echo it has been discovered inside 20
                echo $count
            elif [[ $tables = dump.blastp_drosophila_protein.mci.I40_sorted.txt ]]; then
                count=$((count+100))
                echo it has been discovered inside 40
                echo $count
            elif [[ $tables = dump.blastp_drosophila_protein.mci.I60_sorted.txt ]]; then
                count=$((count+1000))
                echo it has been discovered inside 60
                echo $count
            fi

            echo $i >> completelist.txt
  for comparisontables in *_sorted.txt; do #assign value to match
                if [[ $filename != $comparisontables ]]; then #ensure it's not checking itself
                    if [[ -n $(grep -x "$i" "$comparisontables") ]];then
                        if [[ $comparisontables = dump.blastp_drosophila_protein.mci.I14_sorted.txt ]]; then
                            count=$((count+1))
                            echo found inside 14
                        elif [[ $comparisontables = dump.blastp_drosophila_protein.mci.I20_sorted.txt ]]; then
                            count=$((count+10))
                            echo found inside 20
                        elif [[ $comparisontables = dump.blastp_drosophila_protein.mci.I40_sorted.txt ]]; then
                           count=$((count+100))
                           echo found inside 40
                        elif [[ $comparisontables = dump.blastp_drosophila_protein.mci.I60_sorted.txt ]]; then
                           count=$((count+1000))
                           echo found inside 60
                        fi
                    fi
                fi
            done
            echo ${i}$'\t'$count >> finalfile.txt
        fi
    done < $tables
done

#sed -i 's/searchforthis/replacewiththis/g'
#sed -i 's/\t/,/g' etc
