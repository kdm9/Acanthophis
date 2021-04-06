import csv
from collections import defaultdict
from glob import glob
from os.path import basename, splitext
import os
from sys import stderr
from math import log, inf
from functools import partial


HERE = os.path.abspath(os.path.dirname(__file__))

class __Rules(object):
    def __init__(self):
        for rulefile in glob(f"{HERE}/rules/*.rules"):
            rule = splitext(basename(rulefile))[0]
            setattr(self, rule, rulefile)

rules = __Rules()

profiles = {}
for profiledir in glob(f"{HERE}/profiles/*"):
    profile = basename(profiledir)
    profiles[profile] = profiledir


def get_resource(file):
    return f"{HERE}/{file}"

def rule_resources(config, rule, **defaults):
    def resource(wildcards, attempt, value, maxvalue):
        return int(min(value * 2^(attempt-1), maxvalue))
    C = config.get("cluster_resources", {})
    maxes = C.get("max_values", {})
    global_defaults = C.get("defaults", {})
    rules = C.get("rules", {})
    
    values = {}
    values.update(global_defaults)
    values.update(defaults)
    values.update(rules.get(rule, {}))
    ret = {}
    for res, val in values.items():
        if isinstance(val, str):
            # the logic below allows restarting with increased resources. If
            # the resource's value is string, you can't double it with each
            # attempt, so just return it as a constant.
            # this is used for things like cluster queues etc.
            ret[res] = val
            if C.get("DEBUG", False):
                print(rule, res, val)
            continue
        maxval = maxes.get(res, inf)
        if C.get("DEBUG", False):
            print(rule, res, val, maxval)
        ret[res] = partial(resource, value=val, maxvalue=maxval)
    return ret


def populate_metadata(config, runlib2samp=None, sample_meta=None, setfile_glob=None):
    try:
        if runlib2samp is None:
            runlib2samp = config["metadata"]["runlib2samp_file"]
        if sample_meta is None:
            sample_meta = config["metadata"]["sample_meta_file"]
        if setfile_glob is None:
            setfile_glob = config["metadata"]["setfile_glob"]
    except KeyError as exc:
        raise ValueError("ERROR: metadata files must be configured in config, or passed to populate_metadata()")
    RL2S, S2RL = make_runlib2samp(runlib2samp)
    config["RUNLIB2SAMP"] = RL2S
    config["SAMP2RUNLIB"] = S2RL
    config["SAMPLESETS"] = make_samplesets(runlib2samp, setfile_glob)
    if "refs" not in config:
        raise RuntimeError("ERROR: reference(s) must be configured in config file")
    config["CHROMS"] = make_chroms(config["refs"])
    if "varcall" in config:
        config["VARCALL_REGIONS"] = {
            vc: make_regions(config["refs"], window=config["varcall"]["chunksize"][vc])
            for vc in config["varcall"]["chunksize"]
        } 


def parsefai(fai):
    with open(fai) as fh:
        for l in fh:
            cname, clen, _, _, _ = l.split()
            clen = int(clen)
            yield cname, clen


def make_regions(rdict, window=1e6, base=1):
    window = int(window)
    ret = {}
    for refname, refbits in rdict.items():
        fai = refbits['fasta']+".fai"
        windows = []
        curwin = []
        curwinlen = 0
        for cname, clen in parsefai(fai):
            for start in range(0, clen, window):
                wlen = min(clen - start, window)
                windows.append("{}:{:09d}-{:09d}".format(cname, start + base, start+wlen))
        ret[refname] = windows
    return ret


def make_chroms(rdict):
    ret = {}
    for refname, refbits in rdict.items():
        fai = refbits['fasta']+".fai"
        ref = dict()
        for cname, clen in parsefai(fai):
            ref[cname] = clen
        ret[refname] = ref
    return ret


def _iter_metadata(s2rl_file):
    with open(s2rl_file) as fh:
        dialect = "excel"
        if s2rl_file.endswith(".tsv"):
            dialect = "excel-tab"
        for samp in csv.DictReader(fh, dialect=dialect):
            yield samp


def make_runlib2samp(s2rl_file):
    rl2s = {}
    s2rl = defaultdict(list)
    for run in _iter_metadata(s2rl_file):
        if not run["library"] or run["library"].lower().startswith("blank"):
            # Skip blanks
            continue
        if run.get("include", "Y") != "Y":
            # Remove non-sequenced ones
            continue
        rl = (run["run"], run["library"])
        samp = run["sample"]
        rl2s[rl] = samp
        s2rl[samp].append(rl)
    return dict(rl2s), dict(s2rl)


def stripext(path, exts=".txt"):
    if isinstance(exts, str):
        exts = [exts,]
    for ext in exts:
        if path.endswith(ext):
            path = path[:-len(ext)]
    return path


def make_samplesets(s2rl_file, setfile_glob):
    ssets = defaultdict(list)
    everything = set()
    for setfile in glob(setfile_glob):
        setname = stripext(basename(setfile), ".txt")
        with open(setfile) as fh:
            samples = [x.strip() for x in fh]
        ssets[setname] = samples
        everything.update(samples)
    ssets["all_samples"] = everything

    if not os.path.exists("data/samplelists"):
        os.makedirs("data/samplelists", exist_ok=True)
    with open("data/samplelists/GENERATED_FILES_DO_NOT_EDIT", "w") as fh:
        print("you're probably looking for", setfile_glob, file=fh)
    for setname, setsamps in ssets.items():
        fname = "data/samplelists/{}.txt".format(setname)
        try:
            with open(fname) as fh:
                currsamps = set([l.strip() for l in fh])
        except IOError:
            currsamps = set()
        if set(setsamps) != currsamps:
            with open(fname, "w") as fh:
                print("WARNING: updating sample sets, this will trigger reruns", setname, file=stderr)
                for s in sorted(setsamps):
                    print(s, file=fh)
    return {n: list(sorted(set(s))) for n, s in ssets.items()}
