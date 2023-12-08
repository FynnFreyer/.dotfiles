import argparse


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument('rows', nargs='?', type=int, default=3)
    parser.add_argument('cols', nargs='?', type=int, default=3)

    parser.add_argument('--var', default='x')
    parser.add_argument('--unindexed', action='store_true')
    parser.add_argument('--uncursored', action='store_true')
    parser.add_argument('--unindented', action='store_true')
    parser.add_argument('--inline', action='store_true')

    return parser.parse_args()


def generate_rows(row_count, col_count, var, index, cursor):
    rows = []
    for i in range(row_count):
        row = []
        for j in range(col_count):
            if row_count > 1 and col_count > 1:
                index_str = f'{{{i+1}, {j+1}}}'
            else:
                index_str = f'{max(i+1, j+1)}'
            cell = f'{var}_{index_str}' if index else var
            row.append(cell)
        rows.append(row)

    if cursor:
        # add cursor jump to first cell
        rows[0][0] = rows[0][0] + '$|$'

    return rows


def generate_body(rows, indent, inline):
    row_delim = r' \\ ' if inline else ' \\\\\n'
    row_strings = []
    for row in rows:
        row_string = ' & '.join(row) + row_delim
        row_strings.append(row_string)

    if not inline and indent:
        row_strings = [f'    {row}' for row in row_strings]
    elif inline:
        row_strings = row_strings[:-1] + [row_strings[-1].rstrip(r'\ ')]

    return ''.join(row_strings)


if __name__ == '__main__':
    args = parse_args()

    row_count, col_count = args.rows, args.cols
    var = args.var
    index = not args.unindexed
    cursor = not args.uncursored
    indent = not args.unindented
    inline = args.inline

    rows = generate_rows(row_count, col_count, var, index, cursor)
    body = generate_body(rows, indent, inline)

    print(body)

