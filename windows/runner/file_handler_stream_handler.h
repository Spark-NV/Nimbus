#ifndef RUNNER_FILE_HANDLER_STREAM_HANDLER_H_
#define RUNNER_FILE_HANDLER_STREAM_HANDLER_H_

#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>

class FileHandlerStreamHandler : public flutter::StreamHandler<flutter::EncodableValue> {
 public:
  FileHandlerStreamHandler() = default;
  virtual ~FileHandlerStreamHandler() = default;

 protected:
  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) override {
    int argc;
    LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv != nullptr && argc > 1) {
      int size_needed = WideCharToMultiByte(CP_UTF8, 0, argv[1], -1, nullptr, 0, nullptr, nullptr);
      std::string strTo(size_needed, 0);
      WideCharToMultiByte(CP_UTF8, 0, argv[1], -1, &strTo[0], size_needed, nullptr, nullptr);
      events->Success(flutter::EncodableValue(strTo));
    }
    LocalFree(argv);
    return nullptr;
  }

  std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
      const flutter::EncodableValue* arguments) override {
    return nullptr;
  }
};

#endif  // RUNNER_FILE_HANDLER_STREAM_HANDLER_H_ 