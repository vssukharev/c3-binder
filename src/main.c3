
module binder;
import utils::err, clang, std::io;

// Entry point
fn void! main(String[] args) 
{
  File out;
  String in_name;
  
  parseCommandArgs(args, &out, &in_name)!;
  defer (void) out.close();
  
  transFile(in_name, &out)!;
}


