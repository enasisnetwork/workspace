"""
Operation recipes for managing the projects and execution environment.

This file is part of Enasis Network software eco-system. Distribution
is permitted, for more information consult the project license file.

This file is present within multiple projects, simplifying dependency.
"""



from glob import glob
from os import environ
from pathlib import Path
from re import MULTILINE
from re import findall as re_findall
from re import sub as re_sub
from sys import stdout
from typing import Literal
from typing import Optional



PROJECT = Path(__file__).parent

VERSION = '1.2.2'

COLOR = environ.get('COLOR', 7)

PREFIX = Literal[
    'text', 'base', 'more']



def makeout(
    string: str,
    prefix: Optional[PREFIX] = None,
) -> None:
    """
    Print the ANSI colorized string to the standard output.

    .. note::
       This function is forgiving due to use with Makefile.

    :param string: String processed using inline directives.
    :param prefix: Determine if and which prefix prepended.
    """

    pattern = r'\<c([\d\;]+)\>'
    replace = r'\033[0;\1m'


    if prefix is not None:

        string = f'{string.lstrip(" ")}'

        padding = 3
        _prefix = ''

        if prefix == 'base':
            padding = 0
            _prefix = '<cL>>>><c0>'

        elif prefix == 'more':
            padding = 2
            _prefix = '<cL>●<c0>'

        string = (
            f'{" " * padding}'
            f'{_prefix} {string}')


    string = (
        f'{string}\n'
        .replace('<cD>', f'<c3{COLOR}>')
        .replace('<cL>', f'<c9{COLOR}>'))

    stdout.write(
        re_sub(pattern, replace, string))



def makeread(
    path: str,
) -> str:
    """
    Return the contents using the provided filesystem path.

    :param path: Complete or relative path to the makefile.
    :returns: Contents using the provided filesystem path.
    """

    return (
        Path(path)
        .read_text(encoding='utf-8'))



def makefile(
    path: str = 'Makefile',
) -> None:
    """
    Print the Makefile summary in the human friendly format.

    :param path: Complete or relative path to the makefile.
    """

    contents = makeread(path)

    pattern = (
        r'\n([a-z]\S+)\:(\s+\\\n)?'
        r'((\s+[^\n]+){1,2})?\n'
        r'\s+\@##\s([^\n]+)?\n')

    matches = re_findall(
        pattern, contents, MULTILINE)

    if len(matches) == 0:
        return

    for match in matches:
        makeout(
            f'  <c9{COLOR}>{match[0]}'
            f'  <c0>{match[4]}')



def children() -> None:
    """
    Locate and enumerate Makefiles from recipe directories.
    """

    makefiles = sorted(
        glob('Recipes/*/*.mk')
        + glob('Recipes/*.mk')
        + glob('workspace.mk'))


    def _value(
        key: str,
    ) -> Optional[str]:

        matches = re_findall(
            rf'^{key} \+?= ([^\n]+)',
            content, MULTILINE)

        if len(matches) == 0:
            return None

        return str(matches[-1])


    def _print(
        recipe: str,
        about: str,
    ) -> None:

        makeout(
            f'  <c9{COLOR}>{recipe}'
            f'  <c0>{about}')


    def _keys(
        keys: str,
    ) -> list[str]:

        keys = re_sub(r'\s{2,}', ' ', keys)

        return keys.split(' ')


    for file in makefiles:
        content = makeread(file)

        base = _value('WKSP_PROJKEY')
        make = _value('WKSP_MEXTEND')

        keys: set[str] = set()

        if base is not None:
            keys.update(_keys(base))

        if make is not None:
            keys.update(_keys(make))

        for key in sorted(keys):

            base = _value(f'WKSP_{key}_BASE')
            path = _value(f'WKSP_{key}_PATH')
            gitr = _value(f'WKSP_{key}_GITR')
            gitb = _value(f'WKSP_{key}_GITB')

            if not base and not path:
                continue

            makeout(
                f'\n <c37>{base}/'
                f'<c90>{path}<c0>')

            if make == key:
                _print(
                    f'{path}-make',
                    'Interact with the'
                    ' makefile recipes')

            if gitr is not None:
                _print(
                    f'{path}-clone',
                    'Clone the project'
                    ' Git repository')

            if gitr or gitb:
                _print(
                    f'{path}-git',
                    'Manage the project'
                    ' Git repository')

            if gitr is not None:
                _print(
                    f'{path}-remove',
                    'Remove the project'
                    ' Git repository')

        if file != 'workspace.mk':
            makefile(file)



if __name__ == '__main__':

    makeout(
        f' <c97>{PROJECT.name}/<c0>'
        f'<c37>{VERSION}<c0>'
        f' <c90>Makefile<c0>\n')

    makefile()

    if Path('workspace.mk').exists():

        makeout(
            '\n <c90>Workspace/'
            '<c37>workspace.mk<c0>')

        makefile('workspace.mk')

    children()
