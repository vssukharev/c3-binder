
module c3_binder;

import std::collections::list;
import std::io::file;
import hlp;

def TokenKindList = List(<TokenKind>);
def StringList    = List(<String>);
def ContextList   = List(<Context>);

struct Tokens
{
  TokenKindList kinds;
  StringList strs;
}

struct Context
{
  Tokens tokens;
  ContextKind kind;
}


/**
 * @param data
 */
fn void! generateModule(Data* data)
{
  hlp::printFuncInfoN("Start generating module");

  usz bytes_read = 0;
  char[] read_buffer;

  parseSourceHeader(data.src_file)!;
  writeOutputModule(data.out_file)!;
  
  // while (!data.src_file.eof()) {
  //   
  //   data.out_file.write(read_buffer[..])!;
  //   data.out_file.write("\n")!;
  // }
}

/**
 * @param file
 */
fn void! parseSourceHeader(File file)
{
  // file.seek(0, Seek.SET);
  // 
  // @pool() {
  //   DString token_str;
  //   token_str.temp_init();
  //
  //   char sym;
  //   do {
  //     sym = file.read_byte();  
  //
  //   } while (sym != ' ');
  // };
  //
}

/**
 * @param file
 */
fn void! writeOutputModule(File file)
{

}

enum ContextKind : char {
  FUNC_MACRO_DECL,
  CONST_MACRO_DECL,
  FUNCTION_DECL,
  STRUCT_DECL,
  TYPEDEF_DECL,
  STRUCT_BODY,
}

enum TokenKind : char {
  MACRO_DEFINE,     // #define
  MACRO_IFDEF,      // #ifdef
  MACRO_IFNDEF,     // #ifndef
  MACRO_IF,         // #if
  TYPEDEF,          // typedef
  UNQUALIFIED_NAME, // VkResult
  ENUM,             // enum
  STRUCT,           // struct 
  BUILTIN_TYPE,     // uint32_t
  NUMBER,           // 2.0 || 2 || 2U || 0x12323
  BRACKET_LEFT,     // (
  BRACKET_RIGHT,    // )
  CURLY_BRACKET_LEFT,  // {
  CURLY_BRACKET_RIGHT, // }
  POINTER,          // *
}

