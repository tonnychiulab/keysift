# KeySift 社群短影片

這個目錄提供可直接上傳 YouTube Shorts 與 Instagram Reels 的正體中文宣傳短片，以及完整、可重現的 Windows 渲染流程。

## 成果檔案

| 檔案 | 用途 |
| --- | --- |
| `keysift-short-zh-TW.mp4` | 35 秒直式短影片；包含正體中文旁白與原創合成音床 |
| `keysift-short-cover.png` | 1080 × 1920 封面 |
| `keysift-short-end.png` | 結尾 CTA 靜態圖 |
| `keysift-short-storyboard.png` | 七幕分鏡總覽 |
| `publishing-copy.md` | YouTube 與 Instagram 上架文案 |
| `render-short.ps1` | 從零產生上述視覺、音訊與影片的腳本 |

平台規格研究與官方來源見 [`../docs/social-video-specs.md`](../docs/social-video-specs.md)。

完成版 MP4 可從 [GitHub Release v1.0.0](https://github.com/tonnychiulab/keysift/releases/download/v1.0.0/keysift-short-zh-TW.mp4) 直接下載；repository 不追蹤大型影片檔，避免永久增加 clone 體積。

## 分鏡

| 時間 | 畫面 | 核心訊息 |
| --- | --- | --- |
| 00:00–00:05 | 被遮蔽的 `API_TOKEN` | 比對 `.env` 不該洩漏秘密 |
| 00:05–00:10 | KeySift 定位與安全輸出 | 只比對差異，不曝光值 |
| 00:10–00:15 | 實際 CLI 形式的結果 | 新增、移除、變更一眼看懂 |
| 00:15–00:20 | 三層安全能力 | 鍵名級輸出、嚴格解析、穩定排序 |
| 00:20–00:25 | Text／JSON／glob | 人與自動化都能使用 |
| 00:25–00:30 | CI 流程 | 退出碼攔截部署，零 runtime 第三方套件 |
| 00:30–00:35 | GitHub CTA | 開源、MIT、專案網址 |

## 旁白

> 在 CI 裡比對環境設定時，會不會順手把 Token 也印出來？Key Sift 專門檢查設定漂移，只顯示鍵名和差異狀態，值永遠不進輸出。新增、移除和變更，一眼看懂。它會拒絕重複鍵和錯誤格式，結果穩定又安全。支援文字、JSON 和忽略規則；退出碼直接串進 CI，而且零執行期第三方依賴。開源，MIT 授權。現在就把設定漂移擋在部署前。

## 重新渲染

需求：

- Windows PowerShell 5.1
- `Microsoft Hanhan Desktop` 正體中文系統語音
- FFmpeg（`ffmpeg` 與 `ffprobe`）
- `Microsoft JhengHei` 與 `Consolas` 字型

```powershell
winget install --id Gyan.FFmpeg --exact
powershell -NoProfile -ExecutionPolicy Bypass -File media/render-short.ps1
```

指定輸出路徑：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File media/render-short.ps1 `
  -OutputPath D:\exports\keysift-short.mp4
```

腳本會自行建立並清除暫存素材。音床由三個正弦波即時合成，不使用外部音樂或受版權限制的素材。

## 輸出 profile

- 9:16，1080 × 1920，square pixels
- 30 fps CFR，35 秒
- MP4 Fast Start，無 edit list
- H.264 High Profile、progressive、yuv420p、closed GOP
- VBR 目標 8 Mbps，上限 25 Mbps
- AAC-LC、48 kHz、stereo、128 kbps
- 旁白與音床整體正規化至約 `-16 LUFS`，true peak 目標 `-1.5 dBTP`

發布前仍應在 YouTube 與 Instagram App 內分別預覽，確認平台 UI 沒有遮住重要內容。
