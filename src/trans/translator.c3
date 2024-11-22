
module binder::trans;
import binder::diags, binder::defs;
import std::io, clang;

<*
  Translates 'in_file_name' and writes 
  result to 'out_file_ptr'
  
  @param in_file_name "Name of input file"
  @param [&out] out_file_ptr "Pointer to output file handle (can be stdout, for example)"
  
  @return! ProgramErr.PARSE_ERROR
*>
fn void! transFile(
  String in_file_name,
  File* out_file_ptr)
{
  CXIndex index = clang::createIndex(0, 0);
  defer clang::disposeIndex(index);

  CXTranslationUnit tu = clang::parseTranslationUnit(index, (ZString)in_file_name, null, 0, null, 0, defs::TRANSLATION_UNIT_PARSE_FLAGS);

  if (tu == null) 
  {
    io::eprintfn("Failed to parse %s", in_file_name);
    return ProgramErr.PARSE_ERROR?;
  }

  io::eprintn("--- Run diagnostics ---");
  if (diags::runDiags(tu) > 0)
  {
    io::eprintn("--- Several problems occured while running diagnostics ---");
  }
  else
  {
    io::eprintn("--- Diagnosing finished successfully ---");
  }

  io::eprintn("--- Visiting children ---");
  CursorVisitData visit_data;
  CXCursor cursor = clang::getTranslationUnitCursor(tu);
  clang::visitChildren(cursor, &visitor::mainVisitor, (CXClientData)&visit_data);
  io::eprintn("--- Stop visiting ---");
}


