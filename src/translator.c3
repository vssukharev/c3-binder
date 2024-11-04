
module binder;
import std::io, clang, utils::err;

/**
 * Translates 'in_filename' and writes 
 * result to 'out_file_ptr'
 */
fn void! transFile(
  String in_filename,
  File* out_file_ptr)
{
  CXIndex index = clang::createIndex(0, 0);
  defer clang::disposeIndex(index);

  CXTranslationUnit tu = clang::parseTranslationUnit(
    index,
    (ZString) in_filename,
    null, 0,
    null, 0,
    clang::TRANSLATION_UNIT_NONE
  );

  if (tu == null) {
    io::eprintfn("Failed to parse %s", in_filename);
    return ProgramErr.PARSE_ERROR?;
  }

  io::eprintn("--- Running diagnostics ---");
  runDiagnostics(tu);
  io::eprintn("--- Stopping diagnostics ---");

  

}

