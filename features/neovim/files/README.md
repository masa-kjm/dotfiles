# My Neovim

Neovim 0.12 以降向けの設定。プラグイン管理は組み込みの `vim.pack`、LSP・補完・診断は標準機能を使う。
ツール類は dotfiles の feature（mise / brew / scoop / npm など）が導入する。設定は PATH 上のバイナリを前提とする。

## 依存ツール

| ツール | 用途 | 導入元 |
|---|---|---|
| Neovim 0.12+ | 本体 | `neovim` feature |
| git | `vim.pack` によるプラグイン取得 | `git` feature |
| tree-sitter CLI | nvim-treesitter（main）の parser ビルド | `neovim` feature（mise） |
| C コンパイラ（gcc / clang） | parser のビルド | Linux/WSL は OS 側、Windows は `cli-tools` の gcc |
| ripgrep / fd / fzf | 検索・ピッカー | `cli-tools` feature |
| lazygit | Git UI | `git-tools` feature |
| lua-language-server / stylua / luacheck | Lua | `lua` feature |
| rust-analyzer | Rust | `rust` feature |
| typescript-language-server / vscode-langservers-extracted（eslint） | TS / JS | `npm` feature |
| @github/copilot-language-server | Copilot（inline completion） | `npm` feature |
| ruff / basedpyright | Python（lint・format / 型チェック・補完） | `uv` feature |

## 新しい環境での初回手順

1. dotfiles を適用して `~/.config/nvim` にリンクされ、上記ツールが入っていることを確認する。
2. `nvim` を起動する。初回は `vim.pack` が全プラグインを clone する（数分かかる）。
   - 待機上限（約2分）を超えて `timeout` エラーになることがある。その場合は `nvim` を再起動すれば続きから進む。
3. 起動後、treesitter の parser が非同期でビルドされる（ログが流れる）。完了するまで待つ。
4. 状態を確認する。
   ```vim
   :checkhealth vim.pack
   :checkhealth nvim-treesitter
   :checkhealth vim.lsp
   ```
5. Copilot を使う場合は、Lua / TS などのファイルを開いて `:LspCopilotSignIn` を実行し、表示される手順でサインインする。
6. Markdown プレビューは初回のみ `mkdp#util#install()` が走る（`PackChanged` で自動実行）。失敗したら `:call mkdp#util#install()` を手動実行する。

VSCode-Neovim から読み込まれた場合（`vim.g.vscode`）は、`core` と `core/vscode-keymaps` だけを読み、プラグインと LSP は一切読み込まない。

## ヘルプの見方

| 目的 | コマンド |
|---|---|
| キーワードで検索 | `:help {topic}`（例: `:help vim.pack`、`:help lsp`） |
| あいまい検索 | `:helpgrep {pattern}` |
| 全体の索引 | `:help index` / `:help lua-guide` |
| Lua API | `:help vim.lsp.config()`、`:help vim.diagnostic.config()` など |
| 新機能 | `:help news` |
| キーマップの確認 | `:map` / `:verbose map {lhs}`（定義元ファイルも分かる） |
| LSP の状態 | `:checkhealth vim.lsp` |
| LSP ログ | `:lua vim.cmd.tabnew(vim.lsp.log.get_filename())` |
| 各プラグインのヘルプ | `:help {plugin-name}`（`:help fzf-lua` など。`doc/` を持つプラグインのみ） |

LSP の標準キー: `grn`（rename）、`gra`（code action）、`grr`（references）、`gri`（implementation）、`grt`（type definition）、`gO`（symbols）、`]d` / `[d`（診断移動）、挿入モードの `<C-S>`（signature help）。
Visual モードの `an` / `in` は treesitter による選択範囲の拡大 / 縮小。

## プラグインの管理

プラグインは `vim.pack` が `~/.local/share/nvim/site/pack/core/opt/` に配置する。
バージョンは `nvim-pack-lock.json` で固定され、この lockfile は commit する。

| 操作 | 方法 |
|---|---|
| 追加 | `lua/plugins/init.lua` の `vim.pack.add` に追記し、設定が必要なら `lua/plugins/<group>/<name>.lua` を作って `modules` に追加する |
| 更新 | `:lua vim.pack.update()`（差分を確認するバッファが開く。`:write` で適用、`:quit` で破棄） |
| 更新（確認なし） | `:lua vim.pack.update(nil, { force = true })` |
| 特定のプラグインのみ更新 | `:lua vim.pack.update({ 'name' })` |
| 状態の確認 | `:lua vim.pack.get()` / `:checkhealth vim.pack` |
| 削除 | `vim.pack.add` から外し、`:lua vim.pack.del({ 'name' })` |
| lockfile に合わせる | `:lua vim.pack.update(nil, { target = 'lockfile' })` |

- ビルドが必要なプラグイン（treesitter、markdown-preview）は `PackChanged` autocmd（`lua/plugins/init.lua`）で処理している。
- `version` を変更しても既存の clone は自動では切り替わらない。`:lua vim.pack.update({ 'name' }, { force = true })` を実行する。
- clone が中断されて壊れた場合は、該当ディレクトリを削除して `nvim-pack-lock.json` から該当エントリを消し、再起動する。

## 設定構成

```
nvim/
├── init.lua                # エントリポイント
├── nvim-pack-lock.json     # プラグインのバージョン固定（commit する）
├── after/lsp/<server>.lua  # LSP サーバー別の設定
├── lua/
│   ├── core/               # 共通設定（options / keymaps / autocmds / vscode-keymaps）
│   ├── config/             # 標準機能・連携の設定（lsp.lua、diagnostic.lua、agent.lua）
│   ├── plugins/            # プラグイン宣言（init.lua）と設定（base / edit / git / ui）
│   ├── overseer/template/  # overseer のタスクテンプレート
│   └── utils/              # 共通ユーティリティ（keymap ヘルパーなど）
```

`init.lua` の読み込み順:

1. `core`（options / keymaps / autocmds）
2. `vim.g.vscode` なら `core/vscode-keymaps` だけ読んで終了
3. `plugins`（`vim.pack.add` → 各設定モジュール）
4. `config.diagnostic` / `config.lsp` / `config.agent` / `config.ui` / `config.cmdline`

### LSP

- サーバーの定義は nvim-lspconfig が供給し、差分だけを `after/lsp/<server>.lua` に書く（`lsp/` ではなく `after/` なのは、プラグイン側の定義より優先させるため）。
- 有効化するサーバーは `lua/config/lsp.lua` の `servers` で管理する。
- サーバーを追加するには、(1) feature でバイナリを導入、(2) `after/lsp/<server>.lua` を作成、(3) `servers` に追記、の順に行う。
- 補完は `vim.lsp.completion`（自動表示。選択は `<C-n>` / `<C-p>`、確定は `<C-y>`、中止は `<C-e>`。
- メッセージ / cmdline UI は実験的機能の `ui2`（`lua/config/ui.lua`）。`vim.notify` などは右上の浮動ウィンドウに表示され、hit-enter プロンプトは出ない。長いメッセージは `g<` で pager に表示する。仕様変更や不具合があれば `config/ui.lua` の読み込みを外せば標準 UI に戻る。
- コマンドライン（`:` `/` `?`）は入力中に候補を自動表示（`lua/config/cmdline.lua`）。選択は `<Tab>` / 矢印キー。
- Copilot は `vim.lsp.inline_completion`。`<C-y>` で受け入れ、`<M-]>` / `<M-[>` で次 / 前の候補。

### フォーマット / lint

```bash
bash features/neovim/lint.sh   # stylua / luacheck / headless smoke test（起動・health・キーマップ・VSCode）。`bash tools/lint.sh` からも実行される
```

コメントは英語で書く。設定は `.stylua.toml` と `.luacheckrc` に従う。

## キーマップメモ

Leader は `<Space>`。`<Space>` を押して少し待つと which-key が候補を表示する（`g` `f` などのグループ名は `lua/plugins/ui/which-key.lua` で宣言）。一覧は `<Leader>fk`（fzf-lua の keymaps ピッカー）でも検索できる。

### `<Leader>` の体系

| プレフィックス | 意味 | 主なキー |
|---|---|---|
| `f` | find（fzf-lua） | `fn` files、`fa` live grep、`fb` buffers、`fh` help、`ff` バッファ内検索、`fd` 診断、`fs` symbols、`fm` marks、`f:` コマンド履歴、`fq` quickfix 履歴、`fr` resume、`fk` keymaps |
| `g` | git | `gd` HEAD との差分、`gf` ファイル履歴、`gc` diffview を閉じる、`gD` `:Diffview`、`gp` hunk preview、`gr` hunk reset、`gq` 変更ファイルを quickfix へ、`gl` log、`gs` status |
| `e` | explorer（oil） | `e` カレントバッファのディレクトリ、`E` cwd |
| `s` | session | `ss` 保存、`sl` 一覧 / 検索 |
| `b` | buffer | `bp` pin、`bs` ディレクトリ順に並べ替え、`bco` / `bcr` / `bcl` 他 / 右 / 左を閉じる |
| `t` | task（overseer） | `to` 一覧、`tr` 実行、`tl` 直前のタスクを再実行 |
| `i` | agent | `ic` CLI の開閉、`ip` パス送信、`is`（Visual）選択範囲送信 |
| `o` | outline（aerial） | `o` toggle（`]o` / `[o` で前後のシンボル） |
| `d` | diagnostics | `d` 診断のフロート表示（LSP attach 時のみ） |
| 単独 | その他 | `m` `%` へ移動、`M` split / join（treesj）、`u` undo tree、`/` 検索ハイライト解除、`k` hover（LSP attach 時のみ） |

- `]c` / `[c`: 次 / 前の hunk、`]q` / `[q`: quickfix、`<C-n>` / `<C-p>`: 次 / 前のバッファ（bufferline）、`s` / `S`: flash。
- `gO` は標準の document symbols（aerial の toggle は `<Leader>o`）。
- 新しい `<Leader>` グループを追加したら `lua/plugins/ui/which-key.lua` の `spec` にグループ名を足す。重複キーの検出は `:checkhealth which-key` でもできる。
- 新しいキーを追加するときは、`utils.keymap` を使い `desc` を必ず付ける。`desc` の漏れと、あるキーが別のキーの前方一致になること（`timeoutlen` 待ちの原因）は `features/neovim/lint.sh` が検出する。

### Insert mode

- register の貼り付け: `<C-r>"`
- クリップボードの貼り付け: `<C-r>+`

### filer（oil）の中

カレントディレクトリへ移動: `_`

### lazygit

files でエディタを使ってコミットを作成: `C`

### Agent 連携（`lua/config/agent.lua`）

- 外部で変更されたファイルは `autoread` + `checktime`（FocusGained / BufEnter / CursorHold / TermLeave）で自動再読み込みし、通知する。
- `<Leader>ic`: Copilot CLI（`copilot`）を常駐ターミナルで開閉。`vim.g.agent_cli_cmd` で別コマンドに変更できる。
- `<Leader>ip`: 現在ファイルのパス（`@path`）を CLI に送信。
- Visual `<Leader>is`: 選択範囲（`@path:開始-終了` + 本文）を CLI に送信。
