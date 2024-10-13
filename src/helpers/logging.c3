
module hlp;

import std::io;

/**
 *
 */
macro printFuncInfo(...) 
{
  io::print("[INFO] ");
  io::print($$FUNC);
  io::print(" : ");
  $for (var $i = 0; $i < $vacount; ++$i)
    io::printf("%s", $vaarg[$i]);
  $endfor
}

/**
 *
 */
macro printFuncInfoN(...) 
{
  printFuncInfo($vasplat);
  io::printn();
}

/**
 *
 */
macro printFuncErr(...)
{
  io::print("[ERROR] ");
  io::print($$FUNC);
  io::print(" : ");
  $for (var $i = 0; $i < $vacount; ++$i)
    io::printf("%s", $vaarg[$i]);
  $endfor
}

/**
 *
 */
macro printFuncErrN(...) 
{
  printFuncErr($vasplat);
  io::printn();
}

/**
 *
 */
macro printUserErr(...)
{
  io::print("[ERROR] "); 
  $for (var $i = 0; $i < $vacount; ++$i)
    io::printf("%s", $vaarg[$i]);
  $endfor
}

/**
 *
 */
macro printUserErrN(...)
{
  printUserErr($vasplat);
  io::printn();
}

/**
 *
 */
macro printUserInfo(...)
{
  io::print("[INFO] "); 
  $for (var $i = 0; $i < $vacount; ++$i)
    io::printf("%s", $vaarg[$i]);
  $endfor
}

/**
 *
 */
macro printUserInfoN(...)
{
  printUserInfo($vasplat);
  io::printn();
}

/**
 * Prints slice of chars as string
 *
 * @param [in] arr
 */
macro printCharSlice(char[] arr) 
{
  foreach (char c : arr)
    io::printf("%c", c);
}

/**
 * Prints slice of chars as string, 
 * appending new line at the end
 *
 * @param [in] arr
 */
macro printCharSliceN(char[] arr) 
{
  printCharSlice(arr);
  io::printn();
}


