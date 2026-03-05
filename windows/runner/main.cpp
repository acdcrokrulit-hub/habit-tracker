#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Habit Tracker");
  if (hwnd != NULL) {
    ::ShowWindow(hwnd, SW_NORMAL);
    ::SetForegroundWindow(hwnd);
    return EXIT_FAILURE;
  }

  WNDCLASSA wc_class;
  wc_class.style = CS_HREDRAW | CS_VREDRAW;
  wc_class.lpfnWndProc = DefWindowProc;
  wc_class.cbClsExtra = 0;
  wc_class.cbWndExtra = 0;
  wc_class.hInstance = GetModuleHandle(nullptr);
  wc_class.hIcon = LoadIcon(nullptr, IDI_APPLICATION);
  wc_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  wc_class.hbrBackground = 0;
  wc_class.lpszMenuName = nullptr;
  wc_class.lpszClassName = "HabitTracker";
  RegisterClassA(&wc_class);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(400, 700);
  if (!window.Create(L"Habit Tracker", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
