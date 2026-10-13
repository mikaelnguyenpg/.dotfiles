{ config, pkgs, lib, ... }:

let
  # TẠM THỜI (2026-10): nixpkgs nixos-unstable @ 7fd4004 khai báo sai hash pnpmDeps
  # của typescript-language-server 6.0.2 -> "hash mismatch in fixed-output derivation".
  # master đã sửa đúng hash bên dưới. Chỉ override khi còn hash lỗi, nên khi
  # nixos-unstable có bản sửa thì đoạn này tự thành no-op -> xoá được.
  typescript-language-server =
    let
      pkg = pkgs.typescript-language-server;
      brokenHash = "sha256-MUSxDMlbG21KSesGdEvqa2kEpuVfLlXRUX1qV/FGsSo=";
    in
    if pkg.pnpmDeps.outputHash == brokenHash then
      pkg.overrideAttrs (old: {
        pnpmDeps = old.pnpmDeps.overrideAttrs {
          outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
        };
      })
    else pkg;
in
{
  home.packages = with pkgs; [
    # Node.js LSPs & Formatters
    typescript-language-server
    vscode-langservers-extracted # Cho HTML/CSS/JSON
    emmet-ls
    prettier
    tailwindcss-language-server

    # Thêm scls làm engine gợi ý snippet
    simple-completion-language-server

    # Rust

    # Python
    pyright
    ruff

    # Dart (Thường cài qua Flutter SDK ngoài Nix hoặc qua pkgs.dart)
    # dart
  ];

  home.file.".config/helix/snippets/snippets.toml".text = ''
  [[snippets]]
  prefix = "slg"
  scope = [ "typescript", "javascript", "typescriptreact", "javascriptreact" ]
  body = "console.log('[' + new Date().toISOString() + '] [''${1:SSR:Page|CLIENT:Comp|ACTION:ServerAction|API:Route|MIDDLEWARE}] [''${2:ModuleName}] 🚀⚙️✅❌ [''${3:1/3 START|VALIDATE|FETCH|SUCCESS|ERROR}] ''${4:Message}:', ''${5:data});''$0"
  description = "Structured console.log cho data-flow tracing"
  [[snippets]]
  prefix = "sle"
  scope = [ "typescript", "javascript", "typescriptreact", "javascriptreact" ]
  body = "console.error('[' + new Date().toISOString() + '] [''${1:SSR:Page|CLIENT:Comp|ACTION:ServerAction|API:Route|MIDDLEWARE}] [''${2:ModuleName}] ❌ [ERROR] ''${3:Message}:', ''${4:error});''$0"
  description = "Structured console.error"
  [[snippets]]
  prefix = "slt"
  scope = [ "typescript", "javascript", "typescriptreact", "javascriptreact" ]
  body = "try {\n  ''${1:const result = await someAsyncCall();}\n} catch (error) {\n  console.error('[' + new Date().toISOString() + '] [''${2:ModuleName}] ❌ [ERROR] ''${3:Operation failed}:', error);\n  ''${4:throw error;}\n}''$0"
  description = "Async try/catch co structured error log"
  [[snippets]]
  prefix = "stc"
  scope = [ "typescript", "javascript", "typescriptreact", "javascriptreact" ]
  body = "it(`''${1:should do something}`, () => {\n  // Arrange\n  ''${2}\n\n  // Act\n  ''${3}\n\n  // Assert\n  expect(''${4}).toBe(''${5});\n});\n''$0"
  description = "Test case theo pattern Arrange-Act-Assert"
  [[snippets]]
  prefix = "srfc"
  scope = [ "typescriptreact" ]
  body = "interface ''${1:ComponentName}Props {\n  ''${2:propName}: ''${3:string};\n}\n\nexport function ''${1:ComponentName}({ ''${2:propName} }: ''${1:ComponentName}Props) {\n  return (\n    <div>''${4}</div>\n  );\n}\n''$0"
  description = "React Functional Component voi typed props"
  [[snippets]]
  prefix = "srfc"
  scope = [ "javascriptreact" ]
  body = "export function ''${1:ComponentName}({ ''${2:propName} }) {\n  return (\n    <div>''${3}</div>\n  );\n}\n''$0"
  description = "React Functional Component"
  [[snippets]]
  prefix = "srue"
  scope = [ "typescriptreact", "javascriptreact" ]
  body = "useEffect(() => {\n  ''${1:// effect logic}\n\n  return () => {\n    ''${2:// cleanup}\n  };\n}, [''${3:dependencies}]);''$0"
  description = "useEffect voi cleanup function"
  [[snippets]]
  prefix = "sact"
  scope = [ "typescript", "typescriptreact" ]
  body = "'use server';\n\nexport async function ''${1:actionName}(''${2:formData: FormData}) {\n  try {\n    ''${3:// validate + process}\n    console.log('[' + new Date().toISOString() + '] [ACTION:ServerAction] [''${1:actionName}] ✅ [SUCCESS] ''${4:Done}');\n  } catch (error) {\n    console.error('[' + new Date().toISOString() + '] [ACTION:ServerAction] [''${1:actionName}] ❌ [ERROR] Failed:', error);\n    throw error;\n  }\n}\n''$0"
  description = "Next.js Server Action skeleton (TS)"
  [[snippets]]
  prefix = "sact"
  scope = [ "javascript", "javascriptreact" ]
  body = "'use server';\n\nexport async function ''${1:actionName}(''${2:formData}) {\n  try {\n    ''${3:// validate + process}\n    console.log('[' + new Date().toISOString() + '] [ACTION:ServerAction] [''${1:actionName}] ✅ [SUCCESS] ''${4:Done}');\n  } catch (error) {\n    console.error('[' + new Date().toISOString() + '] [ACTION:ServerAction] [''${1:actionName}] ❌ [ERROR] Failed:', error);\n    throw error;\n  }\n}\n''$0"
  description = "Next.js Server Action skeleton (JS)"
  [[snippets]]
  prefix = "sroute"
  scope = [ "typescript", "typescriptreact" ]
  body = "export async function ''${1:GET|POST|PUT|DELETE}(request: Request) {\n  try {\n    ''${2:const body = await request.json();}\n    return Response.json({ ''${3:data} });\n  } catch (error) {\n    console.error('[' + new Date().toISOString() + '] [API:Route] ❌ [ERROR] Request failed:', error);\n    return Response.json({ error: 'Internal error' }, { status: 500 });\n  }\n}\n''$0"
  description = "Next.js Route Handler skeleton (TS)"
  [[snippets]]
  prefix = "sroute"
  scope = [ "javascript", "javascriptreact" ]
  body = "export async function ''${1:GET|POST|PUT|DELETE}(request) {\n  try {\n    ''${2:const body = await request.json();}\n    return Response.json({ ''${3:data} });\n  } catch (error) {\n    console.error('[' + new Date().toISOString() + '] [API:Route] ❌ [ERROR] Request failed:', error);\n    return Response.json({ error: 'Internal error' }, { status: 500 });\n  }\n}\n''$0"
  description = "Next.js Route Handler skeleton (JS)"
'';

  programs.helix = {
    enable        = true;
    defaultEditor = true;

    settings = {
      theme = "tokyo-night-storm";
      # --- Editor Settings ---
      editor = {
        bufferline              = "multiple";
        cursorline              = true;
        # display-inlay-hint      = false;
        end-of-line-diagnostics = "hint";
        line-number             = "relative";
        rulers                  = [ 100 ];
        true-color              = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };

        indent-guides = {
          character = "╎";
          render    = true;
        };

        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };

        lsp = {
          auto-signature-help = false;
          display-messages    = true;
          display-inlay-hints = true;
        };

        statusline = {
          left = [ "mode" "spinner" "version-control" "file-name" ];
        };
      };

      # --- Keybindings ---
      keys = {
        insert = {
          esc = [ "collapse_selection" "keep_primary_selection" "normal_mode" ];
        };

        normal = {
          esc       = [ "collapse_selection" "keep_primary_selection" "normal_mode" ];
          "{"       = [ "goto_prev_paragraph" ];
          "}"       = [ "goto_next_paragraph" ];
          "^"       = [ "goto_first_nonwhitespace" ];
          "$"       = [ "goto_line_end" ];
          "G"       = [ "goto_last_line" ];
          
          # Tích hợp Yazi (File Manager) và Lazygit
          "C-e"     = [ ":new" ":insert-output yazi" ":buffer-close!" ":redraw" ":reload-all" ];
          "C-g"     = [ ":new" ":insert-output lazygit" ":buffer-close!" ":redraw" ":reload-all" ];
          
          # Git Blame cho dòng hiện tại (Space + B)
          space."B" = [ ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}" ];
        };

        select = {
          "{" = [ "goto_prev_paragraph" ];
          "}" = [ "goto_next_paragraph" ];
        };
      };
    };

    languages = lib.mkMerge [
      # ────────────────────────────────────────────────────────────────
      # HTML + CSS + Emmet
      # ────────────────────────────────────────────────────────────────
      {
        language-server.emmet-ls = {
          command = "emmet-ls";
          args    = [ "--stdio" ];
        };
        language-server.vscode-html-language-server = {
          command = "vscode-html-language-server";
          args    = [ "--stdio" ];
        };
        language-server.vscode-css-language-server = {
          command = "vscode-css-language-server";
          args    = [ "--stdio" ];
        };

        language = [
          { name = "html";
            roots = [ ".git" ];
            formatter = { command = "prettier"; args = [ "--parser" "html" ]; };
            language-servers = [ "vscode-html-language-server" "emmet-ls" ];
            auto-format = true;
          }
          { name = "css";
            formatter = { command = "prettier"; args = [ "--parser" "css" ]; };
            language-servers = [ "vscode-css-language-server" "tailwindcss-ls" "emmet-ls" ];
            auto-format = true;
          }
          { name = "scss";
            formatter = { command = "prettier"; args = [ "--parser" "scss" ]; };
            language-servers = [ "vscode-css-language-server" "emmet-ls" ];
            auto-format = true;
          }
        ];
      }

      # ────────────────────────────────────────────────────────────────
      # JavaScript / TypeScript / JSX / TSX
      # ────────────────────────────────────────────────────────────────
      {
        language-server.scls = {
          command = "simple-completion-language-server";
          environment = {
            RUST_LOG = "info,simple_completion_language_server=info";
            LOG_FILE = "/tmp/completion.log";
          };
          config = {
            feature_snippets = true;   # Bật tính năng snippet
            snippets_first = true;     # Ưu tiên đưa snippet lên đầu danh sách gợi ý
            feature_words = false;     # Tắt gợi ý từ thuần túy (tránh làm loãng menu auto-complete)
          };
        };

        language-server.typescript-language-server = {
          command = "typescript-language-server";
          args = [ "--stdio" ];
          config = {
            typescript.inlayHints = {
              includeInlayEnumMemberValueHints = true;
              includeInlayFunctionLikeReturnTypeHints = true;
              includeInlayFunctionParameterTypeHints = true;
              includeInlayParameterNameHints = "all";
              includeInlayParameterNameHintsWhenArgumentMatchesName = true;
              includeInlayPropertyDeclarationTypeHints = true;
              includeInlayVariableTypeHints = true;
            };
            javascript.inlayHints = {
              includeInlayEnumMemberValueHints = true;
              includeInlayFunctionLikeReturnTypeHints = true;
              includeInlayFunctionParameterTypeHints = true;
              includeInlayParameterNameHints = "all";
              includeInlayParameterNameHintsWhenArgumentMatchesName = true;
              includeInlayPropertyDeclarationTypeHints = true;
              includeInlayVariableTypeHints = true;
            };
          };
        };
        language-server.tailwindcss-ls = {
          command = "tailwindcss-language-server";
          args = [ "--stdio" ];
        };

        language = [
          { name = "javascript";
            formatter = { command = "prettier"; args = [ "--parser" "typescript" ]; };
            language-servers = [ "typescript-language-server" "emmet-ls" "scls" ];
            auto-format = true;
          }
          { name = "typescript";
            formatter = { command = "prettier"; args = [ "--parser" "typescript" ]; };
            language-servers = [ "typescript-language-server" "emmet-ls" "scls" ];
            auto-format = true;
            scope = "source.ts";
            injection-regex = "(ts|typescript)";
            file-types = [ "ts" ]; # "tsx"
            roots = [ "package.json" "tsconfig.json" ];
            # debugger = { /* ... giữ nguyên phần debugger */ };
          }
          { name = "jsx";
            formatter = { command = "prettier"; args = [ "--parser" "typescript" ]; };
            language-servers = [ "typescript-language-server" "emmet-ls" "scls" ];
            auto-format = true;
          }
          { name = "tsx";
            formatter = { command = "prettier"; args = [ "--parser" "typescript" ]; };
            language-servers = [ "typescript-language-server" "emmet-ls" "scls" ];
            auto-format = true;
          }
        ];
      }

      # ────────────────────────────────────────────────────────────────
      # Rust
      # ────────────────────────────────────────────────────────────────
      {
        language-server.rust-analyzer = {
          command = "rust-analyzer";
          # command =  "rustup";
          # args = [ "run" "stable" "rust-analyzer" ];
          config = {
            # Bật diagnostics realtime (gạch đỏ khi đang gõ)
            diagnostics = {
              enable = true;
              disabled = [ "unresolved-proc-macro" ]; # tắt cảnh báo proc macro nếu không cần
            };

            # Inlay hints (hiển thị type, parameter name ngay trong code)
            inlayHints = {
              enable = true;
              lifetimeElisionHints.enable = "skip_trivial";
              closureReturnTypeHints.enable = "with_block";
              reborrowHints.enable = "never";
              typeHints = {
                hideNamedConstructor = false;
              };
              parameterHints = {
                enable = true;
              };
              closingBraceHints = {
                enable = true;
                minLines = 1;
              };
            };

            # Cargo check dùng clippy thay vì check thông thường
            check = {
              command = "clippy";
              # allTargets = false; # nếu không muốn check tests/benches
            };

            # Cargo config (nếu bạn dùng sysroot đặc biệt)
            # cargo = {
            #   # sysroot = "path/to/custom/sysroot"; # hiếm khi cần
            # };
          };
        };

        language = [
          {
            name = "rust";
            scope = "source.rust";
            injection-regex = "rust";
            file-types = [ "rs" ];
            roots = [ "Cargo.toml" "Cargo.lock" ];

            # Auto-format khi save bằng rustfmt
            auto-format = true;
            formatter = {
              # command = "rustup";
              # args = [ "run" "stable" "rust-fmt" "--edition" "2021" ];
              command = "rustfmt";
              args = [ "--edition" "2021" ];
            };

            language-servers = [ "rust-analyzer" ];

            debugger = {
              name = "codelldb";
              command = "/home/michael/.cursor/extensions/vadimcn.vscode-lldb-1.12.1/adapter/codelldb";
              transport = "tcp";
              port-arg = "--port {}";
            };

            debugger.templates = [
              {
                name = "binary";
                request = "launch";
                completion = [ { name = "binary"; completion = "filename"; } ];
                args = {
                  program = "{0}";
                  # stopOnEntry = true;
                  # runInTerminal = true;
                  # !Note: per project
                  # cwd = "/data/20_Workspace/10_Active/rust-tutorial/advance_1/backend";
                  # sourceMap = {
                  #   "/data/20_Workspace/10_Active/rust-tutorial" = "/home/michael/20_Workspace/10_Active/rust-tutorial";
                  # };
                  # initCommands = [
                  #   "settings set target.source-map /data/20_Workspace/10_Active/rust-tutorial /home/michael/20_Workspace/10_Active/rust-tutorial"
                  # ];
                };
              }
            ];
          }
        ];
      }

      # ────────────────────────────────────────────────────────────────
      # Python
      # ────────────────────────────────────────────────────────────────
      {
        language-server.pyright = {
          command = "pyright-langserver";
          args = [ "--stdio" ];
          config.python.pythonPath = ".venv/bin/python";
        };
        language-server.ruff-lsp = {
          command = "ruff-lsp";
          args = [ ];
        };

        language = [
          { name = "python";
            scope = "source.python";
            injection-regex = "python";
            file-types = [ "py" "pyi" "py3" "pyw" "ptl" ];
            roots = [ "pyproject.toml" "setup.py" "requirements.txt" ".git" ];
            formatter = { command = "ruff"; args = [ "format" "--quiet" "-" ]; };
            language-servers = [ "pyright" "ruff-lsp" ];
            auto-format = true;
            # debugger = { /* ... giữ nguyên debugpy */ };
          }
        ];
      }

      # ────────────────────────────────────────────────────────────────
      # Dart / Flutter
      # ────────────────────────────────────────────────────────────────
      {
        language-server.dart-language-server = {
          command = "dart";
          args = [ "language-server" "--protocol=lsp" ];
        };
        language-server.dart-debug-adapter = {
          command = "dart";
          args = [ "debug_adapter" ];
        };

        language = [
          { name = "dart";
            scope = "source.dart";
            injection-regex = "dart";
            file-types = [ "dart" "flutter" ];
            roots = [ "pubspec.yaml" ".git" ];
            formatter = { command = "dart"; args = [ "format" ]; };
            language-servers = [ "dart-language-server" ];
            auto-format = true;
            # debugger = { /* ... giữ nguyên phần debugger */ };
          }
        ];
      }

      # ────────────────────────────────────────────────────────────────
      # Các ngôn ngữ khác (JSON, Markdown, v.v.)
      # ────────────────────────────────────────────────────────────────
      {
        language = [
          { name = "json";
            formatter = { command = "prettier"; args = [ "--parser" "json" ]; };
            auto-format = true;
          }
          { name = "markdown";
            injection-regex = "md|markdown";
            file-types = [ "md" "markdown" "txt" ];
            roots = [ ".marksman.toml" ".git" ];

            # Kết nối với server Marksman
            language-servers = [ "marksman" ];

            formatter = { command = "prettier"; args = [ "--parser" "markdown" ]; };
            auto-format = true;
          }
        ];
      }
    ];
  };
}
