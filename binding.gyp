{
  "targets": [
    {
      "target_name": "<(module_name)",
      "cflags!": [
        "-fno-exceptions"
      ],
      "cflags_cc!": [
        "-fno-exceptions"
      ],
      "conditions": [
        [
          "OS=='win'",
          {
            "sources": [
              "sources/windows/main.cc"
            ],
            "libraries": []
          }
        ],
        [
          "OS=='mac'",
          {
            "sources": [
              "sources/macos/main.mm",
              "sources/macos/mouseEventMonitor.mm",
              "sources/macos/mouseEventMonitor.h"
            ],
            "libraries": ["-framework AppKit", "-framework CoreGraphics"],
            "xcode_settings": {
              "CLANG_ENABLE_OBJC_ARC": "YES",
              "OTHER_CPLUSPLUSFLAGS": [
                "-fobjc-arc",
                "-std=c++17"
              ],
              "MACOSX_DEPLOYMENT_TARGET": "11.0",
              "VALID_ARCHS": ["x86_64", "arm64"],
              "ARCHS": ["x86_64", "arm64"]
            }
          }
        ]
      ],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "defines": [
        "NAPI_VERSION=<(napi_build_version)",
        "NAPI_DISABLE_CPP_EXCEPTIONS=1"
      ],
      "msvs_settings": {
        "VCCLCompilerTool": {
          "ExceptionHandling": 1
        }
      }
    },
    {
      "target_name": "action_after_build",
      "type": "none",
      "dependencies": [
        "<(module_name)"
      ],
      "copies": [
        {
          "files": [
            "<(PRODUCT_DIR)/<(module_name).node"
          ],
          "destination": "<(module_path)"
        }
      ]
    }
  ]
}
