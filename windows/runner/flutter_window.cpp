#include "flutter_window.h"
#include "file_handler_stream_handler.h"

#include <optional>
#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_channel.h>
#include <flutter/method_result.h>
#include <shlobj.h>

#include "flutter/generated_plugin_registrant.h"

#include <fstream>
#include <chrono>
#include <iomanip>
#include <sstream>

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);

  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }

  RegisterPlugins(flutter_controller_->engine());

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  flutter_controller_->ForceRedraw();

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
  switch (message) {
    case WM_COPYDATA:
      return OnCopyData(hwnd, reinterpret_cast<PCOPYDATASTRUCT>(lparam));
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      return 0;
    default:
      return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
  }
}

LRESULT FlutterWindow::OnCopyData(HWND hwnd, PCOPYDATASTRUCT pcds) {
    if (pcds->dwData == 1) {
        int size_needed = WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)pcds->lpData, -1, nullptr, 0, nullptr, nullptr);
        std::string strTo(size_needed, 0);
        WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)pcds->lpData, -1, &strTo[0], size_needed, nullptr, nullptr);

        if (!flutter_controller_) {
            return TRUE;
        }

        if (!flutter_controller_->engine()) {
            return TRUE;
        }

        if (!flutter_controller_->engine()->messenger()) {
            return TRUE;
        }
        
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            flutter_controller_->engine()->messenger(), "com.nimbus/args",
            &flutter::StandardMethodCodec::GetInstance());

        class SimpleResult : public flutter::MethodResult<flutter::EncodableValue> {
        public:
            void SuccessInternal(const flutter::EncodableValue* result) override {}
            void ErrorInternal(const std::string& error_code,
                             const std::string& error_message,
                             const flutter::EncodableValue* error_details) override {}
            void NotImplementedInternal() override {}
        };

        try {
            channel->InvokeMethod(
                "handleFile",
                std::make_unique<flutter::EncodableValue>(strTo),
                std::make_unique<SimpleResult>());
        } catch (...) {
            // Silently handle exception
        }
    }
    return TRUE;
}
