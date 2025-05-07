version 1.0

workflow gap_count {
    input {
        File assembly_file
    }
    call split_assembly {
        input: input_assembly = assembly_file
    }
    scatter (seq_file in split_assembly.sequences) {
        call count_gaps {
            input: sequence = seq_file
        }
    }
    call summa_gaps {
        input: gap_counts = count_gaps.total_gaps
    }
    output {
        Int total_gap_count = summa_gaps.summa_hiatuum
    }
}

task split_assembly {
    input {
        File input_assembly
    }
    command <<<
        mkdir sequences_folder
        seqkit split -i -O sequences_folder "~{input_assembly}"
        find sequences_folder -type f > file_list.txt
    >>>
    output {
        Array[File] sequences = read_lines("file_list.txt")
    }
    runtime {
        docker: "quay.io/biocontainers/seqkit:2.10.0--h9ee0642_0"
        preemptible: 2
    }
}
task count_gaps {
    input {
        File sequence
    }
    command <<<
        if [[ "~{sequence}" == *.gz ]]; then
            gzip -cd "~{sequence}" | grep -v "^>" | tr -d -c 'Nn' | grep -o -i 'N' | wc -l
        else
            cat "~{sequence}" | grep -v "^>" | tr -d -c 'Nn' | grep -o -i 'N' | wc -l
        fi
    >>>
    output {
        Int total_gaps = read_int(stdout())
    }
    runtime {
        docker: "debian:bullseye"
        preemptible: 2
    }
}
task summa_gaps {
    input {
        Array[Int] gap_counts
    }
    command <<<
        printf '~{sep=" " gap_counts}' | awk '{tot=0; for(i=1;i<=NF;i++) tot+=$i; print tot}'
    >>>
    output {
        Int summa_hiatuum = read_int(stdout())
    }
    runtime {
        docker: "ubuntu:20.04"
    }
}
