# jpl_eph

   Details at http://www.projectpluto.com/jpl_eph.htm .

This code provides various utilities and functions to read,  use,  and manipulate JPL
DE ephemeris data.  The core functions were based on Piotr Dybczynski's C source code :

ftp://ftp.astro.amu.edu.pl/pub/jpleph/

   though this version has been so heavily changed as to bear only a passing resemblance
to the original,  and a variety of utilities have been added.  This version can :

  -- deal with JPL ephemerides in either byte order;
  -- handles all JPL ephemeris versions,  without recompiling;
  -- handles errors gracefully;
  -- can be compiled and used on DOS/Windows,  Linux,  OS/X,  with various compilers;
  -- includes some optimizations for speed
  
  This code has been under development for some years and is essentially "complete",
except that one may expect JPL to produce further ephemerides and that they may add
new features requiring some changes to this code.
