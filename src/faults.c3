
module binder::err;
import std::io;

fn int retcodeFromFault(
  anyfault f) 
{
  int rc;
  switch (f) 
  {
    case ProgramErr.NO_INPUT_FILE: rc = 2;
    case ProgramErr.FILE_MISSING: rc = 3;
    case ProgramErr.PARSE_ERROR: rc = 4;
    case ProgramErr.DIAGNOSTICS: rc = 5;
    case ProgramErr.COMPILE_COMMANDS_MISSING: rc = 6;
    case TranslatorErr.FILE_MISSING: rc = 7;
    default: rc = 1;
  }
  return rc;
}

fault ProgramErr 
{
  UNKNOWN,
  NO_INPUT_FILE,
  FILE_MISSING,
  PARSE_ERROR,
  DIAGNOSTICS,
  COMPILE_COMMANDS_MISSING,
}

fault TranslatorErr 
{
  FILE_MISSING 
}


