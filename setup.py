from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize([
        "module/screenshot.pyx", 
        "module/server.pyx",
        "module/ext.pyx"
    ])
)