import sys


def convert(input, output, error):
    try:
        for line in input:
            output.write(line)
    except IOError as e:
        error.write(f"Error processing file: {str(e)}\n")
    except Exception as e:
        error.write(f"Unexpected error: {str(e)}\n")


def main():
    convert(sys.stdin, sys.stdout, sys.stderr)


if __name__ == '__main__':
    main()
