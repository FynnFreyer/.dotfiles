import argparse


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument('rows', nargs='?', type=int, default=3)
    parser.add_argument('cols', nargs='?', type=int, default=3)

    parser.add_argument('--var', default='x')
    parser.add_argument('--unindexed', action='store_true')
    parser.add_argument('--uncursored', action='store_true')
    parser.add_argument('--unindented', action='store_true')

    return parser.parse_args()


def generate_rows(row_count, col_count, var, index, cursor):
    rows = []
    for i in range(row_count):
        row = []
        for j in range(col_count):
            cell = f'{var}_{{{i}, {j}}}' if index else var
            row.append(cell)
        rows.append(row)

    if cursor:
        # add cursor jump to first cell
        rows[0][0] = rows[0][0] + '$|$'

    return rows


def generate_body(rows, indent):
    row_strings = []
    for row in rows:
        row_string = '    ' + ' & '.join(row) + r' \\'
        if not indent:
            row_string = row_string.strip()
        row_strings.append(row_string)
    body = '\n'.join(row_strings) + '\n'
    return body


if __name__ == '__main__':
    args = parse_args()

    row_count, col_count = args.rows, args.cols
    var = args.var
    index = not args.unindexed
    cursor = not args.uncursored
    indent = not args.unindented

    rows = generate_rows(row_count, col_count, var, index, cursor)
    body = generate_body(rows, indent)

    print(body)

