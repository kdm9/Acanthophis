configfile: "config.yml"

import acantophis
acantophis.populate_metadata(config)


include: acantophis.rules.base
include: acantophis.rules.reads
include: acantophis.rules.align
include: acantophis.rules.varcall

rule all:
    input:
        rules.reads.input,
        rules.align.input,
        rules.varcall.input,
