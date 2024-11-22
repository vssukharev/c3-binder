
module binder::trans::clexer;
import binder::defs;
import std::io, clang;

<*
  Gets macro body of a given cursor
  which should be then cleared with
  String.free()

  @require clang::isPreprocessing(clang::getCursorKind(cursor)) "Cursor must point to preprocessing token"

  @return! IoError.EOF
  @return! TranslatorErr.FILE_MISSING
*>
fn String! getMacroBody(CXCursor cursor)
{
  CXFile file;
  CUInt offset;

  CXSourceLocation name_loc = clang::getCursorLocation(cursor);
  clang::getExpansionLocation(name_loc, &file, null, null, &offset);
  
  if (file == null) return TranslatorErr.FILE_MISSING?;

  CXString cx_filename = clang::getFileName(file); 
  defer clang::disposeString(cx_filename);
  ZString filename = clang::getCString(cx_filename);

  return readMacroBody(filename.str_view(), offset)!;
}

<*
  Reads basic macro body from given file with 
  given offset of beginning of macro declaration
*>
fn String! readMacroBody(
  String filename,
  uint name_offset)
{
  File! file = file::open(filename, "r");
  if (catch file) return "";
  defer (void)file.close();

  file.seek(name_offset)!;
  
  char[64] buffer;
  uint offset;
  file.read(buffer[..])!;

  // Skip until ' '
  {
    bool seek_finish;
    char c;
    while (true)
    {
      c = peekNext(&offset, buffer[..], file);
      if (c == ' ') 
      {
        seek_finish = true;
      }
      else if (seek_finish && c != ' ')
      {
        --offset;
        break;
      }
    }
  }

  @pool()
  {
    DString res;
    res.temp_init(16);

    // Read everything after ' '
    char c;
    while (true)
    {
      c = peekNext(&offset, buffer[..], file);

      switch
      {
        case c == '\\':
          c = peekNext(&offset, buffer[..], file);
          if (c == '\n') 
          {
            continue;
          }
          else
          {
            c = '\\';
            --offset;
          }

        case c == '/':
          c = peekNext(&offset, buffer[..], file);
          switch (c) 
          {
            case '/':
              skipLineComment(&offset, buffer[..], file);
              continue;
            case '*':
              skipBlockComment(&offset, buffer[..], file);
              continue;
            default:
              c = '/';
              --offset;
          }
      }

      if (c == '\n') break;
      res.append_char(c);
    }
    
    return res.copy_str();
  };
}

<*
  Skips line comment and makes offset pointing to 
  first no-comment character. For example:
  #define SomeMacro 2 // This is some macro
                       ^                   ^
      Initial offset   |  Resulting offset |  

  @param [&inout] offset
  @param buffer
  @param file

  @require buffer[*offset] == '/' "Offset must point to the start of a comment"
*>
fn void skipLineComment(
  uint* offset,
  char[] buffer,
  File file)
{
  char c;
  while (true) 
  {
    c = peekNext(offset, buffer, file);

    if (c == '\\')
    {
      c = peekNext(offset, buffer, file);

      if (c == '\n')
      {
        continue;
      }
      else
      {
        c = '\\';
        --*offset;
      }
    }

    if (c == '\n') 
    {
      --*offset;
      break;
    }
  }
}

<*
  Skips block comment and makes offset pointing to 
  first no-comment character. For example:
  #define SomeMacro /* This is some macro */ 2
                     ^                     ^
      Initial offset |    Resulting offset |  

  @param [&inout] offset
  @param buffer
  @param file

  @require buffer[*offset] == '*' "Offset must point to the start of a comment"
*>
fn void skipBlockComment(
  uint* offset,
  char[] buffer,
  File file)
{
  char c;
  int nesting = 1;
  while (nesting > 0)
  {
    c = peekNext(offset, buffer, file);

    if (c == '*')
    {
      c = peekNext(offset, buffer, file);
      if (c == '/') 
      {
        --nesting;
      }
      else
      {
        c = '*';
        --*offset;
      }
    }
  }
}

<*
  Peeks next character and increments offset.
  If offset is longer or equal than buffer, 
  refill the buffer. 
  
  @param [&inout] offset
  @param buffer
  @param file
  @param save_chars "How many characters to save in case of buffer refill"

  @require save_chars < buffer.len/2

  @return "0 if any fault while reading occured"
*>
fn char peekNext(
  uint* offset,
  char[] buffer,
  File file,
  uint save_chars = 1)
{
  ++*offset;
  if (*offset >= buffer.len)
  {
    *offset = save_chars;
    for (usz i = 0; i < save_chars; ++i) buffer[i] = buffer[^(i+1)];
    if (catch file.read(buffer[save_chars..])) return 0;
  }
  return buffer[*offset];
}

<*
  Peeks next character and increments offset.

  @param offset
  @param buffer

  @return "0 if offset is equal to zero"
*>
macro char peekPrev(
  uint offset,
  char[] buffer)
{
  if (offset == 0) return 0;
  return buffer[offset-1];
}

