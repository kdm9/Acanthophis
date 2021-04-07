import acanthophis
import argparse
import shutil
from sys import stdin, stdout, stderr, exit
import os.path
from glob import glob

CLIDOC="""
This command currenly just copies the config file, snakefile, and conda
environment file from Acanthophis's example workflow to some directory ($PWD by
default). These files should then be manually edited to suit one's own analysis.
"""

def prompt_yn(message, default=False):
    if default:
        yn = "[Yn]"
    else:
        yn = "[yN]"
    res = default
    try:
        strres = input(f"{message} {yn}").lower()
        if strres.strip() == "":
            res = default
        elif strres in {"y", "yes"}:
            res = True
        elif strres in {"n", "no"}:
            res = False
        else:
            print(f"Invalid yes/no response '{strres}', assuming No.", file=stderr)
            res = False
    except EOFError:
        pass
    return res

def init():
    """acanthophis-init command entry point"""
    ap = argparse.ArgumentParser(description="Initialise an Acanthophis analysis directory", epilog=CLIDOC)
    ap.add_argument("--dryrun", "-n", action="store_true",
            help="Simply print what will be done without performing any action.")
    ap.add_argument("--force", action="store_true",
            help="Overwite output files if they exist, rather than warning.")
    ap.add_argument("--list-available-profiles", action="store_true",
            help="List available cluster profiles and stop. See --cluster-profile")
    ap.add_argument("--cluster-profile", "-c", type=str, default=[], action="append",
            help="Which, if any, cluster profile should be installed too?")
    ap.add_argument("destdir", default=".", nargs="?")
    args = ap.parse_args()

    if args.list_available_profiles:
        print("The following profiles are available:", file=stderr)
        for prof in acanthophis.profiles:
            print("    -", prof)
        exit(0)

    template_dir = acanthophis.get_resource("template/")
    for file in glob(f"{template_dir}/*"):
        if args.dryrun:
            print(f"cp {file} {args.destdir}")
            continue
        outf = os.path.join(args.destdir, os.path.basename(file))
        if args.force or prompt_yn(f"copy {os.path.basename(file)} -> {outf}?"):
            if not os.path.exists(outf) or args.force: 
                shutil.copyfile(file, outf)
            else:
                print(f"WARNING: {outf} exists, not copying. Remove it or use --force.", file=stderr)


    for profile in args.cluster_profile:
        if profile not in acanthophis.profiles:
            print(f"ERROR: unknown profile '{profile}'. see --list-available-profiles", file=stderr)
            exit(1)
        src = acanthophis.profiles[profile]
        dst = os.path.join(args.destdir, profile)
        if args.dryrun:
            print(f"cp -r {src} {dst}")
            continue
        if args.force or prompt_yn(f"copy {src} -> {dst}?"):
            shutil.copytree(src, dst)


if __name__ == "__main__":
    init()
