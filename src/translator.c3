
module binder::trans;
import std::io, clang, binder::utils, binder::diags;

struct CursorVisitData {
  int a;
}

/**
 * Translates 'in_file_name' and writes 
 * result to 'out_file_ptr'
 *
 * @param in_file_name "Name of input file"
 * @param [&out] out_file_ptr "Pointer to output file handle (can be stdout, for example)"
 *
 * @return! ProgramErr.PARSE_ERROR
 */
fn void! transFile(
  String in_file_name,
  File* out_file_ptr)
{
  CXIndex index = clang::createIndex(0, 0);
  defer clang::disposeIndex(index);

  CXTranslationUnit tu = clang::parseTranslationUnit(
    index,
    (ZString) in_file_name,
    null, 0,
    null, 0,
    consts::TRANSLATION_UNIT_PARSE_FLAGS
  );

  if (tu == null) {
    io::eprintfn("Failed to parse %s", in_file_name);
    return ProgramErr.PARSE_ERROR?;
  }

  io::eprintn("--- Run diagnostics ---");
  
  if (diags::run(tu) != 0) {
    io::eprintn("--- Some diagnostics failed ---");
    return ProgramErr.DIAGNOSTICS?;
  }

  io::eprintn("--- Stop diagnostics ---");

  CXCursor cursor = clang::getTranslationUnitCursor(tu);
  CursorVisitData visit_data = {};

  io::eprintn("--- Visiting children ---");
  
  clang::visitChildren(
    cursor,
    &mainVisitor,
    (CXClientData) &visit_data
  );
  
  io::eprintn("--- Stop visiting ---");
}

/**
 * Main visitor
 */
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

  if (clang::isMacroBuiltin_Cursor(cursor)) {
    io::eprintfn("Found builtin macro %s with value %s", cursor_name);
  }

  io::eprintfn(
    "(%s) '%s'", 
    cursor_kind_name,
    cursor_name
  );

  return clang::CHILD_VISIT_RECURSE;
}

