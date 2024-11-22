
module binder::trans::visitor;
import binder::trans::clexer;
import std::io, clang;

struct CursorVisitData {
  int a;
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

  CXFile file;
  CUInt offset;
  CXSourceLocation name_loc = clang::getCursorLocation(cursor);
  clang::getExpansionLocation(name_loc, &file, null, null, &offset);
 
  // Can't find file - return
  if (file == null) return clang::CHILD_VISIT_RECURSE;

  CXString cx_filename = clang::getFileName(file); 
  defer clang::disposeString(cx_filename);
  String filename = clang::getCString(cx_filename).str_view();

  io::eprintfn("(%s) '%s'", cursor_kind_name, cursor_name);
  
  if (cursor_kind == clang::CURSOR_MACRO_DEFINITION) 
  {
    String! macro_body = clexer::readMacroBody(filename, offset);
    if (catch exc = macro_body) 
    {
      io::eprintfn("Error '%s' occured while getting macro body", exc);
    }
    else
    {
      defer macro_body.free();
      io::eprintfn("\t> Macro body: '%s'", macro_body);
    }
  }

  return clang::CHILD_VISIT_RECURSE;
}
