
module binder;
import std::io, clang;

<*
  Retrieves compile_commands.json from current directory
  returned value shoulds then be freed with clang::dispose_CompileCommands
*>
fn CXCompileCommands! retrieveCompileCommands(String filename = "")
{
  io::eprintfn("Trying to find compile_commands.json in current directory");
  
  CXCompilationDatabase_Error err;
  CXCompilationDatabase database = clang::fromDirectory_CompilationDatabase(".", &err);
  defer clang::dispose_CompilationDatabase(database);

  if (err == clang::COMPILATION_DATABASE_CAN_NOT_LOAD_DATA_BASE) {
    return ProgramErr.COMPILE_COMMANDS_MISSING?;
  }

  if (filename == "") {
    return clang::getAllCompileCommands_CompilationDatabase(database);
  }

  else {
    return clang::getCompileCommands_CompilationDatabase(database, (ZString) filename);
  }
}

