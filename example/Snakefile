configfile: "config.yml"

import acanthophis
acanthophis.populate_metadata(config)


include: acanthophis.rules.base
include: acanthophis.rules.reads
include: acanthophis.rules.align
include: acanthophis.rules.varcall
include: acanthophis.rules.multiqc
include: acanthophis.rules.kraken
include: acanthophis.rules.variantannotation

rule all:
    input:
        rules.reads.input,
        rules.align.input,
        rules.varcall.input,
        rules.multiqc.input,
        rules.all_kraken.input,
        rules.all_snpeff.input,
