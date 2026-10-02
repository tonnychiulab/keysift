# KeySift

[正體中文](README.md) · [English](README.en.md) · [日本語](README.ja.md)

KeySift 是安全比對 `.env` 設定漂移的命令列工具。它只輸出變數名稱與差異狀態，**不會輸出任何值**，適合本機檢查、部署前驗證與 CI。

## 功能

- 比對新增、移除及值已變更的環境變數。
- 只揭露鍵名，不揭露密碼、Token 或其他值。
- 支援人類可讀文字與穩定的 JSON 輸出。
- 支援可重複使用的大小寫敏感 `*`／`?` glob 忽略規則。
- 以退出碼區分「相同」、「有差異」與「輸入錯誤」。
- 零執行期第三方相依套件。

## 快速開始

需求： [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)

```console
dotnet run --project src/KeySift -- .env.production .env.staging
```

範例輸出：

```text
CHANGED                API_TOKEN
MISSING_FROM_CANDIDATE LEGACY_ENDPOINT
MISSING_FROM_BASELINE  NEW_FEATURE_FLAG

3 difference(s), 8 matching, 0 ignored
```

### 安裝成全域工具

```console
dotnet pack src/KeySift -c Release -o artifacts
dotnet tool install --global --add-source ./artifacts KeySift.Tool
keysift .env.production .env.staging
```

## 用法

```text
Usage: keysift [options] <baseline.env> <candidate.env>

Options:
  --format <text|json>  Output format (default: text)
  --ignore <glob>       Ignore matching keys; repeatable (* and ? supported)
  --help, -h            Show help
  --version             Show version
```

使用 `--` 可停止解析選項，讓以 `-` 開頭的路徑仍可使用：

```console
keysift --ignore "LOCAL_*" --ignore "*_DEBUG" baseline.env candidate.env
keysift --format json baseline.env candidate.env > drift.json
keysift -- -baseline.env -candidate.env
```

glob 比對採大小寫敏感規則；`*` 代表任意長度字串，`?` 代表單一字元。

### 退出碼

| 退出碼 | 意義 |
|---:|---|
| `0` | 兩份設定相同（套用忽略規則後），或已顯示 `--help`／`--version` |
| `1` | 找到設定差異 |
| `2` | 命令列、檔案存取或 `.env` 語法錯誤 |

### JSON 格式

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

`status` 為 `changed`、`missing_from_baseline` 或 `missing_from_candidate`。

## 支援的 `.env` 語法

- 空白行與以 `#` 起始的註解。
- `KEY=VALUE` 與選用的 `export KEY=VALUE`。
- 可攜式鍵名：`[A-Za-z_][A-Za-z0-9_]*`。
- 不加引號、單引號或雙引號的值。
- 不加引號的值可使用前方帶空白的行尾註解。
- 引號值後可加註解；雙引號內支援 `\n`、`\r`、`\t`、`\"`、`\\`。
- 重複鍵、無效鍵名與未閉合引號會以退出碼 `2` 拒絕，避免模稜兩可的比較。

比較採大小寫敏感的序數比對。KeySift 不會展開 `$VARIABLE`，也不會讀取目前程序的環境變數。

## 安全性界線

KeySift 不會把值寫入標準輸出、標準錯誤或 JSON；錯誤訊息可能包含檔案路徑、行號與鍵名。工具仍需把輸入檔內容讀入程序記憶體，因此請保護來源檔、程序記憶體與 CI 工作區。請勿把真實 `.env` 檔提交到版本控制。

安全問題請依 [SECURITY.md](SECURITY.md) 私下回報。

## 短影片

- [下載 YouTube Shorts／Instagram Reels 成品](https://github.com/tonnychiulab/keysift/releases/download/v1.0.0/keysift-short-zh-TW.mp4)
- [查看分鏡、渲染流程與上架文案](media/README.md)

## 開發

```console
dotnet restore KeySift.sln
dotnet build KeySift.sln -c Release --no-restore
dotnet test KeySift.sln -c Release --no-build
dotnet pack src/KeySift -c Release --no-build -o artifacts
```

## 授權

[MIT](LICENSE)
