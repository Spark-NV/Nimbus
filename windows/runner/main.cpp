#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"
#include "file_handler_stream_handler.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  HANDLE mutex = CreateMutexW(NULL, TRUE, L"NimbusAppMutex");
  if (GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND hwnd = FindWindowW(NULL, L"Nimbus");
    if (hwnd) {
      SetForegroundWindow(hwnd);
      if (command_line && wcslen(command_line) > 0) {
        COPYDATASTRUCT cds;
        cds.dwData = 1;
        cds.cbData = static_cast<DWORD>((wcslen(command_line) + 1) * sizeof(wchar_t));
        cds.lpData = command_line;
        SendMessageW(hwnd, WM_COPYDATA, 0, (LPARAM)&cds);
      }
    }
    return 0;
  }


  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }


  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Nimbus", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      window.GetFlutterViewController()->engine()->messenger(), "com.nimbus/args",
      &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getArguments") {
          int argc;
          LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
          if (argv != nullptr) {
            if (argc > 1) {
              int size_needed = WideCharToMultiByte(CP_UTF8, 0, argv[1], -1, nullptr, 0, nullptr, nullptr);
              std::string strTo(size_needed, 0);
              WideCharToMultiByte(CP_UTF8, 0, argv[1], -1, &strTo[0], size_needed, nullptr, nullptr);
              result->Success(flutter::EncodableValue(strTo));
            } else {
              result->Success(flutter::EncodableValue(""));
            }
            LocalFree(argv);
          } else {
            result->Success(flutter::EncodableValue(""));
          }
        } else {
          result->NotImplemented();
        }
      });

  auto event_channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
      window.GetFlutterViewController()->engine()->messenger(), "com.nimbus/file_handler",
      &flutter::StandardMethodCodec::GetInstance());
  event_channel->SetStreamHandler(std::make_unique<FileHandlerStreamHandler>());

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ReleaseMutex(mutex);
  CloseHandle(mutex);

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
