import acantophis

configfile: "config.yml"

acantophis.populate_metadata(config)

print(config)

include: acantophis.rules.base

include: acantophis.rules.reads

include: acantophis.rules.align


rule all:
    input:
        rules.reads.input,
        rules.align.input,
