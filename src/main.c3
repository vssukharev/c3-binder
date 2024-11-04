
module binder;
import utils, clang, std::io;

// Entry point
fn int main(String[] args) 
{
  Retcode last_retcode;
  File out;
  String in_name;
  
  last_retcode = processCommandArgs(args, &out, &in_name);
  if (last_retcode != OK) return last_retcode.val;

  return Retcode.OK.val;
}


