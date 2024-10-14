
module c3_binder;

import std::collections::list;
import std::io::file;
import hlp, c3_binder::cfg;

def TokenKindList = List(<TokenKind>);
def StringList    = List(<String>);
def ContextList   = List(<Context>);
def IszList       = List(<isz>);

struct TokenKinds 
{
  TokenKindList list;
  IszList str_indices; 
}

struct Context
{
  TokenKinds token_kinds;
  StringList token_strs; // WARNING: token_kinds.len != token_strs in most of the cases
  ContextKind kind;
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
  TYPEDEF,          // typedef
  UNQUALIFIED_NAME, // VkResult
  ENUM,             // enum
  STRUCT,           // struct 
  BUILTIN_TYPE,     // uint32_t
  NUMBER,           // 2.0, 2, 2U, 0x12323
  BRACKET_LEFT,     // (
  BRACKET_RIGHT,    // )
  CURLY_BRACKET_LEFT,  // {
  CURLY_BRACKET_RIGHT, // }
  POINTER,          // *
  HASH,             // #
}

const char[] SPECIAL_TOKENS = {
  '\n', ';', ',', '(', ')', '#', '*', '{', '}', '>'
};


/**
 * @param src_file
 * @param out_file
 * @param contexts
 *
 * @require src_file.file != null
 * @require out_file.file != null
 */
fn void! generateModule(File src_file, File out_file, ContextList* contexts)
{
  hlp::printFuncInfoN("Start generating module");
  
  src_file.seek(0, Seek.SET)!;
  out_file.seek(0, Seek.SET)!;
  
  
  contexts.new_init(16);

  for (usz i = 0; ; ++i) {
    if (i >= contexts.len()) contexts.reserve(contexts.len() * 2);
    
    if ( catch exc = readNextContext(src_file, contexts.get_ref(i))) {
      hlp::printFuncInfoN("Caught excuse: ", exc);
      break;
    }
  }
}


/**
 * @param file
 * @param [out] context
 *
 * @return! IoError.EOF 
 */
fn void! readNextContext(File file, Context* context)
{
  context.token_strs.new_init(8);
  
  bool context_finished;

  for (usz i = 0; !context_finished; ++i) {
    hlp::printFuncInfoN("Reading token ", i);
    
    if (i >= context.token_strs.len()) context.token_strs.reserve(context.token_strs.len());
    readNextToken(file, 
        context.token_kinds.list.get_ref(i), 
        context.token_kinds.str_indices.get_ref(i), 
        &context.token_strs)!;
  }
}

/**
 * TODO: do not save '//' and '/**/' comment blocks to tokens array
 *
 * @param file
 * @param [out] token_kind
 * @param [out] token_str_index
 * @param [out] token_strs
 *
 * @return! IoError.EOF
 */
fn void! readNextToken(
    File file, 
    TokenKind* token_kind, 
    isz* token_str_index, 
    StringList* token_strs)
{
  static char last_c;

  last_c = file.read_byte()!;

  @pool() {
    DString tmp_str;
    tmp_str.temp_init(cfg::DEFAULT_TOKEN_STR_CAP);

    
    while (true) {
      if (tmp_str.len() > 0) {
        if ( @ok(array::index_of(SPECIAL_TOKENS, last_c)) || last_c == ' ' ) {
          break;
        }
      } else {
        if (last_c == ' ') {
          last_c = file.read_byte()!;
          continue;
        } else if (@ok(array::index_of(SPECIAL_TOKENS, last_c))) {
          tmp_str.append_char(last_c);
          break;
        }
      }
 
      tmp_str.append_char(last_c);
      last_c = file.read_byte()!;
    }

    hlp::printFuncInfoN("Resulted string: '", tmp_str, "'");
    token_strs.push(tmp_str.copy_str());
  };
}


