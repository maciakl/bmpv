#!/usr/bin/env python3

# This script takes two arguments: a file path and a value that is major, minor
# or patch. It searches the file for a version string in the format
# "major.minor.patch" and increments the specified part of the version.

import os
import re
import sys
import termcolor

VERSION = "0.1.8"


def msg(text, color='green'):
    print(termcolor.colored(text, color))


def err(text):
    sys.stderr.write(termcolor.colored(text + '\n', 'red'))


# check the version string in the file
def check(file_path):

    with open(file_path, 'r') as file:
        content = file.read()

    version_pattern = r'(\d+)\.(\d+)\.(\d+)'
    match = re.search(version_pattern, content)

    if not match:
        err("No version string found in the file.")
        sys.exit(1)

    file = os.path.basename(file_path)

    major, minor, patch = map(int, match.groups())
    msg(f"{file} --> v{major}.{minor}.{patch}")


def increment_version(file_path, part):

    # check if file_path exists and exit if it doesn't
    if not os.path.isfile(file_path):
        err(f"File {file_path} does not exist.")
        sys.exit(1)

    with open(file_path, 'r') as file:
        content = file.read()

    version_pattern = r'(\d+)\.(\d+)\.(\d+)'
    match = re.search(version_pattern, content)

    if not match:
        err("No version string found in the file.")
        sys.exit(1)

    major, minor, patch = map(int, match.groups())

    if part == 'major':
        major += 1
        minor = 0
        patch = 0
    elif part == 'minor':
        minor += 1
        patch = 0
    elif part == 'patch':
        patch += 1
    else:
        err("Invalid part specified. Use major, minor, or patch.")
        sys.exit(1)

    new_version = f"{major}.{minor}.{patch}"
    new_content = re.sub(version_pattern, new_version, content, count=1)

    with open(file_path, 'w') as file:
        file.write(new_content)

    msg(f"{file_path} bumped to version {new_version}")


def usage():
    msg(f"bmp v{VERSION}")
    msg("Usage:")
    msg("\tbmpv <file> [part]\n")
    msg("\t <file>\tPath to the file containing the version string.")
    msg("\t <part>\tPart to increment: major, minor, or patch.\n")
    msg("Options:")
    msg("\t-v, --version\tShow version information")
    msg("\t-h, --help\tShow this help message")
    msg("\nIf no part is specified, file's current version will be displayed.")


def main():
    if (len(sys.argv) == 2):

        if sys.argv[1] in ['-v', '--version']:
            print(f"{VERSION}")
            sys.exit(0)

        if sys.argv[1] in ['-h', '--help']:
            usage()
            sys.exit(0)

        else:
            try:
                check(sys.argv[1])
                sys.exit(0)
            except Exception as e:
                err(f"Error: {e.strerror}")
                sys.exit(1)

    if len(sys.argv) != 3:
        usage()
        sys.exit(0)
    else:
        if sys.argv[1] in ['-v', '--version']:
            msg(f"bmpv v{VERSION}")
            sys.exit(0)
        else:
            try:
                increment_version(sys.argv[1], sys.argv[2])
                sys.exit(0)
            except Exception as e:
                err(f"Error: {e.strerror}")
                sys.exit(1)


if __name__ == "__main__":
    main()
