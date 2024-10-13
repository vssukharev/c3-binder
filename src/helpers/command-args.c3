
module hlp;

import std::io::path;
import c3_binder::cfg;

bitstruct CommandFlags : char {

}

struct CommandArgs {
  Path src_path;
  Path out_path;
  CommandFlags flags;
}

fault CommandArgsErr {
  TOO_FEW_ARGUMENTS,
  INVALID_SRC_FILE,
  INVALID_OUT_FILE,
}


/**
 * Frees memory CommandArgs object allocated
 *
 * @param [out] self
 */
fn void CommandArgs.free(&self)
{
 if (self.src_path.path_string.ptr) self.src_path.free();
 if (self.out_path.path_string.ptr) self.out_path.free();
}

/**
 * Parses command-line arguments
 * 
 * @param [in] args
 * @param [out] res_args
 *
 * @return! CommandArgsErr.TOO_FEW_ARGUMENTS, CommandArgsErr.INVALID_SRC_FILE
 */
fn void! parseCommandArgs(String[] args, CommandArgs* res_args)
{
  *res_args = {};

  if (args.len == 1) {
    hlp::printUserErrN("Too few arguments");
    return CommandArgsErr.TOO_FEW_ARGUMENTS?;
  }

  parseFlagSource(args, &res_args.src_path)!;
  parseFlagOutput(args, &res_args.out_path)!;
}


/**
 * Iterates through args and
 * parses source file path flag/argument
 *
 * @param [in] args
 * @param [out] src_path
 *
 * @return! CommandArgsErr.INVALID_SRC_FILE
 */
fn void! parseFlagSource(String[] args, Path* src_path)
{
  for (usz i = 1; i != args.len; ++i) {
    if (args[i-1][0] != '-') {
      Path tmp_path = path::new(args[i])!;
      *src_path = tmp_path;

      if (!path::is_file(tmp_path)) {
        hlp::printUserErrN("Source file doesn't exist: ", tmp_path);
        return CommandArgsErr.INVALID_SRC_FILE?;
      }

      break;
    }
  }

  if (src_path.path_string.ptr == null) {
    hlp::printUserErrN("Source file expected");
    return CommandArgsErr.INVALID_SRC_FILE?;
  }
}

/**
 * Iterates through args and
 * parses output file path flag
 *
 * @param [in] args
 * @param [out] out_path
 *
 * @return! CommandArgsErr.INVALID_OUT_FILE
 */
fn void! parseFlagOutput(String[] args, Path* out_path)
{
  for (usz i = 0; i != args.len; ++i) {
    if (args[i] == "-o") {
      if (args.len < i+2) {
        hlp::printUserErrN("Argument expected after ", args[i]);
        return CommandArgsErr.INVALID_OUT_FILE?;
      }

      *out_path = path::new(args[i+1])!;
      break;
    }
  }
  
  if (out_path.path_string.ptr == null) {
    *out_path = path::new(cfg::DEFAULT_OUT_FILENAME)!;
  }
}


module c3_binder::tests;
import hlp, std::io;

fn void! checkParseCommandArgs1() @test
{
  CommandArgs res_args;
  String[*] args = { "c3_binder", "./assets/dummy.h", "-o", "./assets/out.c3i" };

  hlp::parseCommandArgs(args[..], &res_args)!;
  res_args.free();
}


fn void! checkParseCommandArgs2() @test
{
  CommandArgs res_args;
  String[*] args = { "c3_binder", "./assets/dummy.h" };

  hlp::parseCommandArgs(args[..], &res_args)!;
  res_args.free();
}

