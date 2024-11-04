
module utils;

enum Retcode : int (int val) {
  OK = 0,
  NO_INPUT_FILE = 1,
  FILE_MISSING = 2,
  PARSE_ERROR = 3,
  UNKNOWN = 100,
}


