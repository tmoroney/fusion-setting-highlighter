# Fusion Setting Highlighter

A local extension for VS Code and compatible forked editors that adds syntax highlighting for **DaVinci Resolve Fusion `.setting` files**, with full embedded Lua support inside script blocks.

## Installation (local, no marketplace required)

### macOS / Linux install command

Run the installer and choose your editor from the prompt:

```sh
curl -fsSL https://raw.githubusercontent.com/tmoroney/fusion-setting-highlighter/master/scripts/install.sh | sh
```

Available targets are VS Code, Cursor, Windsurf, and Antigravity.

### Windows install command

In PowerShell, run the installer and choose your editor from the prompt:

```powershell
irm https://raw.githubusercontent.com/tmoroney/fusion-setting-highlighter/master/scripts/install.ps1 | iex
```

Available targets are VS Code, Cursor, Windsurf, and Antigravity.

### Manual install paths

Clone or copy this folder into your editor's local extensions directory:

<details>
<summary>macOS / Linux</summary>

- **VS Code:** `~/.vscode/extensions/fusion-setting-highlighter/`
- **Cursor:** `~/.cursor/extensions/fusion-setting-highlighter/`
- **Windsurf:** `~/.windsurf/extensions/fusion-setting-highlighter/`
- **Antigravity:** `~/.antigravity/extensions/fusion-setting-highlighter/`

</details>

<details>
<summary>Windows</summary>

- **VS Code:** `%USERPROFILE%\.vscode\extensions\fusion-setting-highlighter\`
- **Cursor:** `%USERPROFILE%\.cursor\extensions\fusion-setting-highlighter\`
- **Windsurf:** `%USERPROFILE%\.windsurf\extensions\fusion-setting-highlighter\`
- **Antigravity:** `%APPDATA%\Antigravity\extensions\fusion-setting-highlighter\`

</details>

Restart the editor. Any `.setting` file will automatically use the "Fusion Setting" language mode.

## What is a `.setting` file?

DaVinci Resolve's Fusion compositing engine stores macros, tools, and node templates as `.setting` files. The format is a Lua-like serialization dialect — superficially similar to Lua table constructors, but used as a configuration/data format rather than executable Lua scripts.

Example snippet:

```
AutoSubs = MacroOperator {
    CustomData = {
        HelpPage = "https://autosubs.app",
    },
    Inputs = ordered() {
        MainInput = InstanceInput {
            SourceOp = "AutoSubs",
            Source = "Input",
        },
        ShadowColor = {
            LINKS_Name = "Shadow Color",
            LINKID_DataType = "Number",
            INPID_InputControl = "ColorControl",
            INP_Default = 0,
            INPS_ExecuteOnChange = [[
                local r = tool:GetInput("ShadowRed")
                local g = tool:GetInput("ShadowGreen")
                local b = tool:GetInput("ShadowBlue")
                tool:SetInput("Red3", r)
            ]],
        },
    },
}
```

There is no official VS Code extension for this format. Without this extension, editors either show the file as plain text or — if associated with Lua — display false syntax errors because the format is not a standalone Lua script.

## What this extension does

- **Syntax highlighting** for all elements of the `.setting` format:
  - Fusion constructor keywords: `MacroOperator`, `TextPlus`, `Input`, `InstanceInput`, `InstanceOutput`, `GroupInfo`, etc.
  - Fusion metadata keys with standard prefixes: `INP_*`, `INPID_*`, `INPS_*`, `LINKID_*`, `LINKS_*`, `BTNCS_*`, `IC_*`, and more
  - The `ordered()` special constructor
  - Strings, numbers, booleans, `nil`
  - Numeric table keys (`[0]`, `[9]`, etc.)
  - Regular identifier keys
  - `--` line comments
  - Braces, brackets, punctuation
- **Embedded Lua highlighting** inside `[[ ... ]]` block string literals — these are used for callbacks and scripts such as `INPS_ExecuteOnChange` and `BTNCS_Execute`. The content is highlighted with full Lua syntax colours (keywords, functions, variables, etc.) via VS Code's built-in Lua grammar.
- **No language server** — no false-positive error squiggles, no diagnostics. Pure highlighting only.
- **Bracket matching and comment toggling** via `language-configuration.json`.

## How it works

The extension is a standard [VS Code language extension](https://code.visualstudio.com/api/language-extensions/syntax-highlight-guide) consisting of three files:

```
fusion-setting/
├── package.json                          # Extension manifest
├── language-configuration.json           # Bracket matching, comment toggle
└── syntaxes/
    └── fusion-setting.tmLanguage.json    # TextMate grammar
```

### `package.json`

Registers the `fusion-setting` language ID, associates it with the `.setting` file extension, and declares the `embeddedLanguages` mapping:

```json
"embeddedLanguages": {
    "meta.embedded.block.lua": "lua"
}
```

This tells VS Code that any region of the grammar with scope `meta.embedded.block.lua` should be treated as Lua — enabling the Lua extension's tokenizer to run inside those regions.

### `fusion-setting.tmLanguage.json`

A [TextMate grammar](https://macromates.com/manual/en/language_grammars) that defines all the token patterns. The key pattern for embedded Lua uses a `begin`/`end` rule:

```json
{
    "name": "meta.embedded.block.lua",
    "begin": "\\[\\[",
    "end": "\\]\\]",
    "contentName": "source.lua",
    "patterns": [{ "include": "source.lua" }]
}
```

When the tokenizer encounters `[[`, it switches into `source.lua` scope and delegates all tokenization to the Lua grammar until it hits `]]`. This gives full Lua highlighting for any inline scripts.

### `language-configuration.json`

Configures editor behaviour: `--` as the line comment token, and bracket pairs for `{}`, `[]`, `()`, and `""`.
