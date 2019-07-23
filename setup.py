
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [Extension("pyfaac",
                     ["src/pyfaac.pyx"],
                     language='c',
                     #include_dirs=[r'./src'],
                     #library_dirs=[r'./lib'],
                     libraries=['faac']
                     )]

setup(
    name = 'PyFaac',
    version = '1.1',
    description = 'A fast sound encoder',
    cmdclass = {'build_ext': build_ext},
    ext_modules = ext_modules
)
