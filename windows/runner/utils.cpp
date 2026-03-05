#include "utils.h"

#include <flutter_windows.h>
#include <io.h>
#include <stdio.h>
#include <windows.h>

#include <iostream>

std::vector<std::string> GetCommandLineArguments() {
  int* argcp = new int;
  wchar_t** argvp = CommandLineToArgvW(GetCommandLineW(), argcp);

  std::vector<std::string> command_line_arguments;

  if (argvp != nullptr) {
    for (int i = 0; i < *argcp; i++) {
      char arg[1024];
      size_t converted = 0;
      wcstombs_s(&converted, arg, sizeof(arg), argvp[i], _TRUNCATE);
      command_line_arguments.push_back(std::string(arg));
    }
    LocalFree(argvp);
  }

  delete argcp;
  return command_line_arguments;
}
