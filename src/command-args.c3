
module binder;

/**
 * Processes command-line arguments and returns 
 * one of the Retcode
 *
 * @param args "Command-line arguments"
 * @param [&out] out_ptr "Reference to output File"
 * @param [&out] in_name_ptr "Reference to input file name"
 */
fn Retcode processCommandArgs(String[] args, File* out_ptr, String* in_name_ptr)
{
  if (args.len == 1) {
    io::eprintn("No input file provided - aborting");
    return Retcode.NO_INPUT_FILE;
  }

  String in_name = args[1];
  if (!file::is_file(in_name)) {
    io::eprintfn("No such input file %s", in_name);
    return Retcode.FILE_MISSING; 
  }

  *in_name_ptr = in_name;

  if (args.len == 2) {
    io::eprintn("No output file provided - writing to stdout");
    *out_ptr = *io::stdout();
  } 

  else {
    String out_name = args[2];
    File! open_res = file::open(out_name, "w");

    if (catch exc = open_res) {
      case IoError.FILE_NOT_FOUND:
        io::eprintfn("No such output file %s", out_name);
        return Retcode.FILE_MISSING;
      default:
        io::eprintfn("Unknown error occured while opening file %s", out_name);
        return Retcode.UNKNOWN;
    }
    
    *out_ptr = open_res;
  }

  return Retcode.OK;
}

