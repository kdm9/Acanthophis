# Copyright 2016-2022 Kevin Murray/Gekkonid Consulting
#
# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/.

import csv
from collections import defaultdict
from glob import glob
from os.path import basename, splitext
import os
from sys import stderr
from math import log, inf
from functools import partial

try:
    from ._version import version
    __version__ = version
except ImportError:
    pass


HERE = os.path.abspath(os.path.dirname(__file__))

profiles = {}
for profiledir in glob(f"{HERE}/template/workflow/profiles/*"):
    profile = basename(profiledir)
    profiles[profile] = profiledir


def get_resource(file):
    return f"{HERE}/{file}"
