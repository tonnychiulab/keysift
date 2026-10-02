# KeySift

[正體中文](README.md) · [English](README.en.md) · [日本語](README.ja.md)

KeySift は、`.env` ファイル間の設定ドリフトを安全に検出するコマンドラインツールです。出力するのは変数名と差分状態だけで、**値は一切出力しません**。ローカル確認、デプロイ前検証、CI に利用できます。

## 特長

- 環境変数の追加、削除、値の変更を検出。
- パスワードやトークンなどの値を表示せず、キー名だけを表示。
- 人間向けテキストと安定した JSON 出力を提供。
- 大文字・小文字を区別する `*`／`?` glob 除外ルールを複数指定可能。
- 一致、ドリフト、入力エラーを終了コードで判別可能。
- 実行時のサードパーティ依存関係なし。

## クイックスタート

[.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0) が必要です。

```console
dotnet run --project src/KeySift -- .env.production .env.staging
```

出力例：

```text
CHANGED                API_TOKEN
MISSING_FROM_CANDIDATE LEGACY_ENDPOINT
MISSING_FROM_BASELINE  NEW_FEATURE_FLAG

3 difference(s), 8 matching, 0 ignored
```

### グローバルツールとしてインストール

```console
dotnet pack src/KeySift -c Release -o artifacts
dotnet tool install --global --add-source ./artifacts KeySift.Tool
keysift .env.production .env.staging
```

## 使用方法

```text
Usage: keysift [options] <baseline.env> <candidate.env>

Options:
  --format <text|json>  Output format (default: text)
  --ignore <glob>       Ignore matching keys; repeatable (* and ? supported)
  --help, -h            Show help
  --version             Show version
```

`-` で始まるパスを指定する場合は、`--` でオプション解析を終了します。

```console
keysift --ignore "LOCAL_*" --ignore "*_DEBUG" baseline.env candidate.env
keysift --format json baseline.env candidate.env > drift.json
keysift -- -baseline.env -candidate.env
```

glob は大文字・小文字を区別します。`*` は任意長の文字列、`?` は 1 文字に一致します。

### 終了コード

| コード | 意味 |
|---:|---|
| `0` | 除外適用後に一致、または `--help`／`--version` を表示 |
| `1` | 設定ドリフトを検出 |
| `2` | コマンドライン、ファイルアクセス、または `.env` 構文エラー |

### JSON 形式

```json
{
  "differences": [
    {
      "key": "API_TOKEN",
      "status": "changed"
    }
  ],
  "summary": {
    "differences": 1,
    "matching": 8,
    "ignored": 2
  }
}
```

`status` は `changed`、`missing_from_baseline`、`missing_from_candidate` のいずれかです。

## 対応する `.env` 構文

- 空行と `#` で始まるコメント。
- `KEY=VALUE` と任意の `export KEY=VALUE`。
- 移植性のあるキー名：`[A-Za-z_][A-Za-z0-9_]*`。
- 引用符なし、シングルクォート、ダブルクォートの値。
- 引用符なしの値では、空白の後に行末コメントを記述可能。
- 引用値の後にコメントを記述可能。ダブルクォート内では `\n`、`\r`、`\t`、`\"`、`\\` を利用可能。
- 重複キー、不正なキー名、閉じていない引用符は曖昧な比較を避けるため終了コード `2` で拒否。

比較は大文字・小文字を区別する序数比較です。KeySift は `$VARIABLE` を展開せず、現在のプロセス環境も読み取りません。

## セキュリティ境界

KeySift は値を標準出力、標準エラー、JSON に書き込みません。エラーにはファイルパス、行番号、キー名が含まれる場合があります。入力内容はプロセスメモリに読み込まれるため、元ファイル、プロセスメモリ、CI ワークスペースを保護してください。実際の `.env` ファイルをバージョン管理へコミットしないでください。

セキュリティ上の問題は [SECURITY.md](SECURITY.md) の手順で非公開報告してください。

## 開発

```console
dotnet restore KeySift.sln
dotnet build KeySift.sln -c Release --no-restore
dotnet test KeySift.sln -c Release --no-build
dotnet pack src/KeySift -c Release --no-build -o artifacts
```

## ライセンス

[MIT](LICENSE)
