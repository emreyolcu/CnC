#ifndef _parse_hpp_INCLUDED
#define _parse_hpp_INCLUDED

#include <cassert>
#include <vector>

namespace CaDiCaL {

// Factors out common functions for parsing of DIMACS and solution files.

class File;
struct External;
struct Internal;

class Parser {

  Solver * solver;
  Internal * internal;
  External * external;
  File * file;

  void perr (const char * fmt, ...);
  int parse_char ();

  const char * parse_string (const char * str, char prev);
  const char * parse_positive_int (int & ch, int & res, const char * name);
  const char * parse_lit (int & ch, int & lit, int & vars, int strict);
  const char * parse_dimacs_non_profiled (int & vars, int strict);
  const char * parse_solution_non_profiled ();

  bool * incremental;
  vector<int> * cubes;

public:

  Parser (Solver * s, File * f, bool * i, vector<int> * c)
  :
    solver (s),
    internal (s->internal), external (s->external),
    file (f),
    incremental (i),
    cubes (c)
  {
  }

  // Parse a DIMACS CNF or ICNF file.
  //
  // Return zero if successful. Otherwise parse error.
  //
  const char * parse_dimacs (int & vars, int strict);

  // Parse a solution file as used in the SAT competition, e.g., with
  // comment lines 'c ...', a status line 's ...' and value lines 'v ...'.
  // Returns zero if successful. Otherwise a string is returned describing
  // the parse error.  The parsed solution is saved in 'solution' and can be
  // accessed with 'sol (int lit)'.  We use it for checking learned clauses.
  //
  const char * parse_solution ();
};

}

#endif
