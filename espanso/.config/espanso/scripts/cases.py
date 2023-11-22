import argparse


def case_count(arg):
    if arg:
        return int(arg)
    return 2


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument('cases', nargs='?', type=case_count)

    parser.add_argument('--var', default='x')
    parser.add_argument('--unindented', action='store_true')
    parser.add_argument('--unaligned', action='store_true')
    parser.add_argument('--uncursored', action='store_true')

    return parser.parse_args()


def generate_cases(case_count, indent, align, cursor):
    cases = []
    for i in range(case_count):
        case_indent = '    ' if indent else ''
        case_align = ' & ' if align else ' '
        case_cursor = '$|$' if cursor and i == 0 else ''

        case_str = rf'{case_indent}{case_cursor},{case_align}\text{{}} \\'
        cases.append(case_str)

    body = '\n'.join(cases) + '\n'
    return body


if __name__ == '__main__':
    args = parse_args()

    case_count = args.cases
    indent = not args.unindented
    align = not args.unaligned
    cursor = not args.uncursored

    cases = generate_cases(case_count, indent, align, cursor)

    print(cases)

