#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  void SetQuitOnClose(bool quit_on_close);

  bool IsRunning() const;

  void SetChildContent(HWND child_content);

  HWND GetNativeWindow() const;

  void Show();

 protected:
  virtual LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  virtual bool OnCreate();
  virtual void OnDestroy();

 private:
  static LRESULT CALLBACK WndProc(HWND const window, UINT const message,
                                  WPARAM const wparam, LPARAM const lparam) noexcept;

  std::wstring window_class_;
  std::wstring title_;
  HWND window_handle_;
  HWND child_content_;
  bool quit_on_close_;
  bool is_running_;
};

#endif
