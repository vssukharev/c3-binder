
module binder::faults;
import std::io;

fault ProgramErr {
  NO_INPUT_FILE,
  FILE_MISSING,
  PARSE_ERROR,
  DIAGNOSTICS,
  UNKNOWN,
}


