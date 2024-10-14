module c3_binder;

import std::io;

import hlp, c3_binder::cfg;

/**
 * Main Data class
 */
struct Data
{
  ContextList contexts;
  File src_file;
  File out_file;
}

// Entry point
fn void! main(String[] args)
{
  Data data;
	init(&data, args)!;
  generateModule(data.src_file, data.out_file, &data.contexts)!;
  defer cleanup(&data);
}


/**
 * @param [out] data
 */
fn void! init(Data* data, String[] args)
{
  CommandArgs res_args;

  hlp::parseCommandArgs(args, &res_args)!;
  defer res_args.free();

  data.src_file = file::open_path(res_args.src_path, "r")!;
  data.out_file = file::open_path(res_args.out_path, "w")!;

  hlp::printFuncInfoN("Opened source file: ", res_args.src_path);
  hlp::printFuncInfoN("Opened output file: ", res_args.out_path);
}


/**
 * @param data
 */
fn void cleanup(Data* data)
{
  data.src_file.close()!!;
  data.out_file.close()!!;
}

