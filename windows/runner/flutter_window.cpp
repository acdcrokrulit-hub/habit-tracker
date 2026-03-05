#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  const size_t target_width = frame.right - frame.left;
  const size_t target_height = frame.bottom - frame.top;

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      target_width, target_height, project_);

  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->GetNativeWindow());

  flutter_controller_->Engine()->SetNextFrameCallback([&]() {
    Show();
  });

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
