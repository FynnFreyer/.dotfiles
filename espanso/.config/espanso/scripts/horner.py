import argparse
from os import getenv
from textwrap import dedent


def parse_args():
    parser = argparse.ArgumentParser(description="Produce a preformatted LaTeX template to do synthetic division of polynomes.")

    parser.add_argument('degree', nargs='?', type=int, default=3, help="degree of the polynomial to typeset")
    parser.add_argument('root', nargs='?', default=getenv('ESPANSO_ROOT', 'x_0'), help="root of the polynomial")

    parser.add_argument('--indexed', action='store_true', help="whether to add placeholders for coefficients")
    parser.add_argument('--var', default='x', help="placeholder symbol for coefficients, defaults to x")
    parser.add_argument('--uncursored', action='store_true')

    return parser.parse_args()


def intersperse(delimiter, iterable):
    it = iter(iterable)
    yield next(it)
    for x in it:
        yield delimiter
        yield x


def generate_rows(degree: int, root: str, indexed: bool = False, var: str = "", cursored: bool = False) -> list[list[str]]:
    # TODO implement indexed and cursored
    spacers = ["&"] * (degree + 1)
    coefficient_row = [*spacers, r"\\"]
    divisor_row = [root, *spacers, r"\\"]
    ruler_row = [r"\hline"]
    result_row = spacers[:]

    # pad the leading entries with root length
    padding = " " * (len(root) + 1)
    coefficient_row[0] = padding + coefficient_row[0]
    result_row[0] = padding + result_row[0]

    return [coefficient_row, divisor_row, ruler_row, result_row]


def generate_body(body_rows: list[list[str]]):
    coeff_spec = "c" * len(body_rows[-1])  # result_row
    # combine rows internally and prepend padding
    row_strings = ['    ' + ' '.join(row) for row in rows]
    # combine rows with oneanother and add moar padding
    body_string = '\n    '.join(row_strings)
    
    body = rf"""
    \begin{{array}}{{c|{coeff_spec}}}
    {body_string}
    \end{{array}}
    """[1:].rstrip()  # drop first and last newline

    return dedent(body)


if __name__ == '__main__':
    args = parse_args()

    degree, root = args.degree, args.root
    var = args.var
    index = args.indexed
    cursor = not args.uncursored

    rows = generate_rows(degree, root, index, var, cursor)
    body = generate_body(rows)

    print((body))

