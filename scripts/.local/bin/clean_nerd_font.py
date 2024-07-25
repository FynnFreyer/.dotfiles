#!/usr/bin/env python

from sys import argv
from fontforge import open as font_open

ttf_file = argv[1]
font = font_open(ttf_file)

def clean(s):
    return s.replace("NF-", "-").replace("NF ", " ").replace(" Nerd Font", "")

font.fontname = clean(font.fontname)
font.familyname = clean(font.familyname)
font.fullname = clean(font.fullname)

font.generate(ttf_file)

