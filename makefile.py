"""
Operation recipes for managing the projects and execution environment.

This file is part of Enasis Network software eco-system. Distribution is
permitted, for more information consult the project license file.

This file is present within multiple projects, simplifying dependencies.
"""



from glob import glob
from os import environ
from pathlib import Path
from re import MULTILINE
from re import findall as re_findall
from re import sub as re_sub
from sys import stdout
from typing import Optional



PROJECT = Path(__file__).parent

VERSION = '0.1.0'

COLOR = environ.get('COLOR', 7)



def printc(
    source: str,
) -> None:
    """
    Print the ANSI colorized string to standard output.

    :param source: String processed using inline color directives.
    """

    source = (
        source
        .replace('<cD>', f'<c3{COLOR}>')
        .replace('<cL>', f'<c9{COLOR}>')
        .replace('<cZ>', '<c0>'))

    pattern = r'\<c([\d\;]+)\>'
    replace = r'\033[0;\1m'

    stdout.write(
        re_sub(pattern, replace, source))



def makefile(
    source: str = 'Makefile',
) -> None:
    """
    Print the Makefile summary in human friendly format.

    :param source: Complete or relative filesystem path for enumeration.
    """

    contents = Path(source).read_text(encoding='utf-8')

    pattern = (
        r'^(\S+):(\s+[\.\S+\-]+)?\n'
        r'\s+\@\#\#\s+([^\n]+)$')

    matches = re_findall(pattern, contents, MULTILINE)

    for match in matches:

        printc(
            f'  <c9{COLOR}>{match[0]}'
            f'  <c0>{match[2]}\n')



def children() -> None:
    """
    Locate and enumerate Makefiles from recipe directories.
    """

    recipes = sorted(
        glob('Recipes/*/*.mk')
        + glob('Recipes/*.mk'))


    def _value(
        key: str,
    ) -> Optional[str]:
        pattern = rf'^{key} \+?= ([^\n]+)'
        matches = re_findall(pattern, contents, MULTILINE)
        assert len(matches) in [0, 1]
        return matches[0] if matches else None


    def _print(
        recipe: str,
        about: str,
    ) -> None:
        printc(f'  <c9{COLOR}>{recipe} <c0>{about}\n')


    for recipe in recipes:
        contents = Path(recipe).read_text(encoding='utf-8')
        pkey = _value('WKSP_PROJKEY')
        base = _value(f'WKSP_{pkey}_BASE')
        path = _value(f'WKSP_{pkey}_PATH')
        make = _value('WKSP_MEXTEND')
        gitr = _value(f'WKSP_{pkey}_GITR')
        gitb = _value(f'WKSP_{pkey}_GITB')

        printc(f'\n <c90>{base}/<c37>{path}<cZ>\n')

        if make == pkey:
            _print(
                f'{path}-make',
                'Interact with the makefile recipes')

        if gitr is not None:
            _print(
                f'{path}-clone',
                'Clone the project Git repository')

        if gitr or gitb:
            _print(
                f'{path}-git',
                'Manage the project Git repository')

        if gitr is not None:
            _print(
                f'{path}-remove',
                'Remove the project Git repository')

        makefile(recipe)



if __name__ == '__main__':

    printc(
        f' <c97>{PROJECT.name}/<c0>'
        f'<c37>{VERSION}<c0>'
        f' <c90>Makefile<c0>\n\n')

    makefile()

    if Path('workspace.mk').exists():
        makefile('workspace.mk')

    children()
