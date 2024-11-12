
module binder;
import utils, clang, std::io;

// Entry point
fn void! main(String[] args) 
{
  File out_file_handle;
  String in_file_name;
  
  arg::parseCommandArgs(args, &out_file_handle, &in_file_name)!;
  defer (void) out_file_handle.close();
  
  trans::transFile(in_file_name, &out_file_handle)!;
}


