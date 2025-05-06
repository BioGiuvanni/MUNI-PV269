version 1.0

workflow gap_count {
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
    gzip -cd ${assembly} | grep -v "^>" | tr -d '\n' | grep -o -i 'n' | wc -l > gaps.txt
    }
    output {
        Int total_gaps = read_int("gaps.txt")
    }
    runtime {
        docker: "debian:bullseye"
        preemptible: 2
    }
}