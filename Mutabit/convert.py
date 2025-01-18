from typing import TextIO
import sys


def convert(input: TextIO, output: TextIO, error: TextIO) -> None:
    try:
        for line in input:
            output.write(line)
    except IOError as e:
        error.write(f"Error processing file: {str(e)}\n")
    except Exception as e:
        error.write(f"Unexpected error: {str(e)}\n")


def main() -> None:
    convert(sys.stdin, sys.stdout, sys.stderr)


if __name__ == '__main__':
    main()
