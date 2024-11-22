
module binder;
import clang, std::io;

// Entry point
fn RetCode main(String[] args) 
{
  File out_file_handle;
  String in_file_name;
  
  if (catch exc = command_args::parseCommandArgs(args, &out_file_handle, &in_file_name)) {
    return faults::retcodeFromFault(exc);
  }

  defer (void) out_file_handle.close();
  
  if (catch exc = trans::transFile(in_file_name, &out_file_handle)) {
    return faults::retcodeFromFault(exc);
  }

  return 0;
}


