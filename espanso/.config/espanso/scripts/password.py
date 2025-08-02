from argparse import ArgumentParser, Namespace
from string import ascii_letters, digits, punctuation
from random import choices


def default_int(arg: str) -> int:
    if arg:
        return int(arg)
    return 16


def parse_args(argv: list[str] | None = None) -> Namespace:
    parser = ArgumentParser(description="generate a random password")

    parser.add_argument("length", type=default_int, default=16, nargs="?", help="length of the password")

    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    k = args.length
    
    # generate and print password
    alph = ascii_letters + digits + punctuation
    pw = "".join(choices(alph, k=k))
    print(pw)
    
    return 0


if __name__ == "__main__":
    exit(main())

