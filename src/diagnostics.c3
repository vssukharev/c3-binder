
module binder::diags;
import std::io, clang;

<*
  Runs diagnostics and log them
  if some errors occured
 
  @param tu "Translation unit to be diagnosed"
 
  @return "Quantity of errors occured"
*>
fn uint runDiags(CXTranslationUnit tu)
{
  uint errors_count;
  
  CXDiagnosticSet diag_set = clang::getDiagnosticSetFromTU(tu);
  defer clang::disposeDiagnosticSet(diag_set);
  uint diag_set_len = clang::getNumDiagnosticsInSet(diag_set);

  for (uint i = 0; i < diag_set_len; ++i) {
    CXDiagnostic diag = clang::getDiagnosticInSet(diag_set, i);

    if (clang::getDiagnosticSeverity(diag) >= clang::DIAGNOSTIC_ERROR) {
      CXSourceLocation loc = clang::getDiagnosticLocation(diag);
      CXFile file; uint line, column;

      CXString spelling = clang::getDiagnosticSpelling(diag);
      defer clang::disposeString(spelling);
      
      clang::getExpansionLocation(loc, &file, &line, null, null);

      CXString filename = clang::getFileName(file);
      defer clang::disposeString(filename);

      io::eprintfn("(%s) %s: %s", clang::getCString(filename), line, clang::getCString(spelling));
      ++errors_count;
    }
  }

  return errors_count;
}

