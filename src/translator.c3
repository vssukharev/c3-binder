
module binder;
import std::io, clang;

struct CursorVisitData {
  int a;
}

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

  CXTranslationUnit tu = clang::parseTranslationUnit(index, (ZString)in_file_name, null, 0, null, 0, utils::TRANSLATION_UNIT_PARSE_FLAGS);

  if (tu == null) {
    io::eprintfn("Failed to parse %s", in_file_name);
    return ProgramErr.PARSE_ERROR?;
  }

  io::eprintn("--- Retrieve compile_commands.json ---");
  CXCompileCommands comp_commands = retrieveCompileCommands()!;
  io::eprintn("--- Compile commands retrieved successfully ---");

  io::eprintn("--- Run diagnostics ---");
  runDiags(tu)!;
  io::eprintn("--- Diagnosing finished successfully ---");

  io::eprintn("--- Visiting children ---");
  CursorVisitData visit_data;
  CXCursor cursor = clang::getTranslationUnitCursor(tu);
  clang::visitChildren(cursor, &mainVisitor, (CXClientData)&visit_data);
  io::eprintn("--- Stop visiting ---");
}


<*
  Main visitor
*>
fn CXChildVisitResult mainVisitor(
  CXCursor cursor, 
  CXCursor parent, 
  CXClientData client_data)
{
  CursorVisitData* real_data = (CursorVisitData*) client_data;

  CXCursorKind cursor_kind = clang::getCursorKind(cursor);

  CXString cursor_spell = clang::getCursorDisplayName(cursor);
  defer clang::disposeString(cursor_spell);

  CXString cursor_kind_spell = clang::getCursorKindSpelling(cursor_kind);
  defer clang::disposeString(cursor_kind_spell);

  ZString cursor_name = clang::getCString(cursor_spell);
  ZString cursor_kind_name = clang::getCString(cursor_kind_spell);

  if (!isCursorNameSkippable(cursor_name)) {
    io::eprintfn("(%s) '%s'", cursor_kind_name, cursor_name);
  }

  return clang::CHILD_VISIT_RECURSE;
}

<*
  Detects whether cursor name worth to be processe!d
*>
macro bool isCursorNameSkippable(ZString cursor_name) =>
  cursor_name.len() > 2 && cursor_name[0..1] == "__";


