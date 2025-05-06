version 1.0

workflow gap_counter {
    input {
        File assembly_file
    }
    call count_gaps {
        input: assembly=assembly_file
    }
    output {
        Int gap_length = count_gaps.total_gaps
    }
}
task count_gaps {
    input {
        File assembly
    }
    command {
    gzip -cd "~{assembly}" | grep -v "^>" | grep -o -i 'N' | wc -l
    }
    output {
        Int total_gaps = read_int(stdout())
    }
    runtime {
        docker: "ubuntu:22.04"
        preemptible: 3
        memory: "1 GB"
        cpu: 1
    }
}
