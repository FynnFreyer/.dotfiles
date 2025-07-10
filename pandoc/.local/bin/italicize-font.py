#!/usr/bin/env -S fontforge -lang=py

import sys

from math import radians

import fontforge as ff
from psMat import skew


def slant_font(font: ff.font, slant_angle: int | float = 12) -> ff.font:
    """
    Add slant to a font. Positive values slant right,negative values slant left.

    :param slant_angle: Degrees of slant to apply to glyphs.
    :returns: The slanted font.
    """
    # Calculate the angle in radians
    angle = radians(slant_angle)
    # Generate a shear matrix
    slant_mat = skew(angle)
    # Select all glyphs for transformation
    font.selection.all()
    # Apply slant to selected glyphs
    return font.transform(slant_mat)


def patch_font(font_file: str) -> None:
    # Open the font file
    font = fontforge.open(font_file)

    # Apply slant
    font = slant_font(font)

    # Replacements
    regular = ("Regular", "Italic")
    bold = ("Bold", "BoldItalic")

    # Get the base_name and style for outputting later
    base_name, style = font_file.rsplit('-', 1)

    # Make name replacements
    for prev, repl in [regular, bold]:
        # Update the font's name to indicate it's italicized
        font.fullname = font.fullname.replace(prev, repl)
        font.fontname = font.fontname.replace(prev, repl)
        style = style.replace(prev, repl)

    # Set output file name
    output_file = f"{base_name}-{style}"

    # Save the slanted font
    font.generate(output_file)

    # Close the font
    font.close()


def main():
    # Get the input file name from the command-line arguments
    regular, bold, *_ = sys.argv[1:]

    # Patch font files
    patch_font(regular)
    patch_font(bold)


if __name__ == '__main__':
    main()
