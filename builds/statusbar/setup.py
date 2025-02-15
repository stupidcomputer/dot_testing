from setuptools import setup, find_packages

setup(
    name = 'pystatus',
    version = '1.0.0',
    author = 'stupidcomputer',
    author_email = 'ryan@beepboop.systems',
    url = 'https://github.com/stupidcomputer/dot_testing',
    description = 'simple statusbar content program',
    license = 'GPLv3',
    entry_points = {
        'console_scripts': [
            'statusbar = statusbar.statusbar:main'
        ]
    },
    classifiers = (
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Operating System :: POSIX :: Linux",
        "Environment :: Console"
    ),
    zip_safe = False
)
