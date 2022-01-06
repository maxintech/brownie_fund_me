#!/bin/bash

set -e

top=$(dirname $0)
python3 -m venv ${top}/venv

${top}/venv/bin/python3 ${top}/venv/bin/pip install --upgrade "pip>=19.3" -r ${top}/requirements.txt