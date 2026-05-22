"""
Operation recipes for managing the projects and execution environment.

This file is part of Enasis Network software eco-system. Distribution
is permitted, for more information consult the project license file.

This file is present within multiple projects, simplifying dependency.
"""



from glob import glob
from pathlib import Path
from re import MULTILINE
from re import findall as re_findall
from re import sub as re_sub
from typing import Optional

from enbasics import makefile
from enbasics import makeout
from enbasics import makeread



def workspace(
    color: Optional[int] = 7,
) -> None:
    """
    Locate and enumerate Makefiles from recipe directories.

    :param color: Optional color override default ANSI gray.
    """

    custom = Path('workspace.mk')

    if not custom.exists():
        return None

    makeout(
        '\n <c90>Workspace/'
        f'<c37>{custom.name}<c0>')

    makefile(custom, color=color)



def children(  # noqa: CFQ001
    color: Optional[int] = 7,
) -> None:
    """
    Locate and enumerate Makefiles from recipe directories.

    :param color: Optional color override default ANSI gray.
    """

    makefiles = sorted(
        glob('Recipes/*/*.mk')
        + glob('Recipes/*.mk')
        + glob('workspace.mk'))


    def _value(
        key: str,
    ) -> Optional[str]:

        pattern = (
            rf'^{key}\s*\+?=\s*'
            r'([^\n]+(?:\n[ \t]+'
            r'[^\n]+)*)')

        matches = re_findall(
            pattern, content,
            MULTILINE)

        if not matches:
            return None

        newline = r'\\\n'
        spaced = ' '

        return (
            str(matches[-1])
            .replace(newline, spaced)
            .strip())


    def _print(
        recipe: str,
        about: str,
    ) -> None:

        makeout(
            f'  <c9{color}>'
            f'{recipe}'
            f'  <c0>{about}')


    def _keys(
        keys: str,
    ) -> list[str]:

        spaces = r'\s{2,}'
        spaced = ' '

        return (
            re_sub(spaces, spaced, keys)
            .split(' '))


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
            makefile(file, color=color)
