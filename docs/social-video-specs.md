# YouTube Shorts 與 Instagram Reels 共用影片輸出規格

存取日期：**2026-10-02**

本文只引用 YouTube／Google 與 Instagram／Meta 的官方第一手資料。為避免把建議誤寫成平台硬性限制，以下分為「官方事實」與「KeySift 建議選擇」。

## 官方事實

### YouTube Shorts

| 項目 | 官方事實 | 官方來源 |
| --- | --- | --- |
| 畫面比例 | 電腦上傳 Shorts 時，影片須為**正方形或直向格式**；官方未把 9:16 列為唯一比例。YouTube 也明示播放器能處理 9:16 直向影片，並建議不要在影片內自行加入邊框或黑邊。 | [上傳 YouTube Shorts](https://support.google.com/youtube/answer/12779649?co=GENIE.Platform%3DDesktop&hl=zh-Hant)（存取：2026-10-02）；[影片解析度和長寬比](https://support.google.com/youtube/answer/6375112?hl=zh-Hant)（存取：2026-10-02） |
| 解析度 | Shorts 官方入門頁只明示最高為 **1080p**，未明示直式影片的固定像素尺寸；因此 **1080 × 1920 並非該頁明列的 Shorts 強制尺寸**。 | [開始製作 YouTube Shorts](https://support.google.com/youtube/answer/10059070?hl=zh-Hant)（存取：2026-10-02） |
| 時長 | 電腦上傳的 Shorts 最多 **3 分鐘**。 | [上傳 YouTube Shorts](https://support.google.com/youtube/answer/12779649?co=GENIE.Platform%3DDesktop&hl=zh-Hant)（存取：2026-10-02） |
| 容器 | YouTube 的建議上傳設定為 **MP4**、不使用 edit lists，並將 `moov` atom 放在檔案開頭（Fast Start）。這是一般 YouTube 上傳建議，不是 Shorts 專屬硬性規格。 | [YouTube 建議的上傳編碼設定](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02） |
| 視訊編碼 | 建議採 **H.264 High Profile**、progressive scan、CABAC、2 個連續 B-frame、closed GOP 與 4:2:0 色度取樣。這是一般 YouTube 上傳建議，不是 Shorts 專屬硬性規格。 | [YouTube 建議的上傳編碼設定](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02） |
| 音訊編碼 | 建議採 **AAC-LC、Opus 或 Eclipsa Audio**；取樣率為 **48 kHz**，可使用立體聲。這是一般 YouTube 上傳建議，不是 Shorts 專屬硬性規格。 | [YouTube 建議的上傳編碼設定](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02） |
| 幀率 | 應以和錄製時相同的幀率編碼及上傳；常見幀率為 **24、25、30、48、50、60 fps**，其他幀率亦可接受。交錯內容應先去交錯。官方未明示 Shorts 專屬固定幀率。 | [YouTube 建議的上傳編碼設定](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02） |
| UI 遮擋 | Shorts 編輯器的視覺輔助工具會標示按鈕、留言、影片說明等介面元素可能出現的位置；元素太靠近邊緣時會顯示「非安全區域」。官方沒有公布可供外部剪輯軟體使用的固定像素或百分比安全區。 | [提升 Shorts 品質：使用視覺輔助工具](https://support.google.com/youtube/answer/16215842?co=GENIE.Platform%3DAndroid&hl=zh-Hant)（存取：2026-10-02） |

> 適用範圍：YouTube 的「建議上傳編碼設定」頁面註明相關功能僅供採用 YouTube 工作室內容管理工具的合作夥伴使用，因此本文只把該頁內容稱為官方**建議**，不宣稱為所有 Shorts 的硬性驗收條件。[來源](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02）

### Instagram Reels

| 項目 | 官方事實 | 官方來源 |
| --- | --- | --- |
| 畫面比例 | 一般 Reels 可上傳 **1.91:1 至 9:16**；Instagram 發布 API 建議 **9:16**，以避免裁切或留白。 | [Instagram Reel 大小和長寬比](https://help.instagram.com/1038071743007909)（存取：2026-10-02）；[IG User Media：Reel Specifications](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 解析度 | 一般 Reels 頁面明示最低解析度為 **720 pixels**，但未明示該數值是寬或高，也未指定固定輸出尺寸。發布 API 另訂水平像素最多 **1920 columns**。官方未明示一般自然 Reels 必須為 1080 × 1920。 | [Instagram Reel 大小和長寬比](https://help.instagram.com/1038071743007909)（存取：2026-10-02）；[IG User Media：Reel Specifications](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 時長 | Instagram 發布 API 的 Reels 規格為至少 **3 秒**、最多 **15 分鐘**。這是專業帳號 API 發布規格；一般 App 的所有上傳路徑是否採同一上下限，官方未在此規格頁明示。 | [IG User Media：Reel Specifications](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 容器 | 發布 API 接受 **MOV 或 MP4（MPEG-4 Part 14）**，不得含 edit lists，且 `moov` atom 必須位於檔案前端。一般使用者 Reels 尺寸頁未明示容器。 | [IG User Media：Reel Specifications](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02）；[Instagram Reel 大小和長寬比](https://help.instagram.com/1038071743007909)（存取：2026-10-02） |
| 視訊編碼 | 發布 API 接受 **HEVC 或 H.264**，並要求 progressive scan、closed GOP 與 4:2:0 色度取樣。一般使用者 Reels 尺寸頁未明示視訊編碼。 | [IG User Media：Reel Specifications](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02）；[Instagram Reel 大小和長寬比](https://help.instagram.com/1038071743007909)（存取：2026-10-02） |
| 音訊編碼 | 發布 API 要求 **AAC**，取樣率最高 **48 kHz**，可為 mono 或 stereo，音訊位元率為 **128 kbps**。一般使用者 Reels 尺寸頁未明示音訊編碼。 | [IG User Media：Reel Specifications](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02）；[Instagram Reel 大小和長寬比](https://help.instagram.com/1038071743007909)（存取：2026-10-02） |
| 幀率 | 一般 Reels 應至少為 **30 fps**；發布 API 接受 **23–60 fps**。兩者數值交集為 30–60 fps，但這個交集是本文整理結果，不是 Meta 另行發布的推薦範圍。 | [Instagram Reel 大小和長寬比](https://help.instagram.com/1038071743007909)（存取：2026-10-02）；[IG User Media：Reel Specifications](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| UI 遮擋 | Meta 對 **Reels 廣告**建議頂端 14%、底端 35%、左右各 6% 不放文字、標誌或其他重要元素，以避開裁切、個人檔案圖示與 CTA；另建議 9:16 Stories／Reels 廣告的頂、底與兩側邊緣不要放重要元素。這些百分比是廣告規格，官方未明示自然（非廣告）Reels 的固定百分比安全區。 | [Instagram Reels 廣告規格](https://www.facebook.com/business/ads-guide/update/video/instagram-reels/traffic)（存取：2026-10-02）；[限時動態和 Reels 廣告的疊壓文字和安全區域](https://www.facebook.com/business/help/980593475366490)（存取：2026-10-02） |

> 適用範圍：上述容器、編碼、時長與 23–60 fps 數值來自 Instagram 專業帳號的發布 API；安全區百分比來自 Reels 廣告規格。一般自然 Reels 頁面沒有明示相同的完整技術規格，不應把 API 或廣告數值改寫成所有 App 上傳的硬性要求。[API 來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02）；[廣告來源](https://www.facebook.com/business/ads-guide/update/video/instagram-reels/traffic)（存取：2026-10-02）

## KeySift 建議的單一共用輸出 profile

下表是**工程選擇**，不是兩平台共同發布的官方 profile。它取兩邊官方文件可相容的保守交集，讓同一檔案可直接用於 YouTube Shorts 與 Instagram Reels，亦符合 Instagram 發布 API 的技術範圍。

| 設定 | 建議值 | 選擇理由 |
| --- | --- | --- |
| 畫布 | **9:16、1080 × 1920、square pixels** | 9:16 是 Instagram API 官方建議，YouTube 接受直向並能顯示 9:16；1080 × 1920 是 KeySift 選定的 9:16 直式 1080p 畫布，**不是任何一方明示的 Shorts／自然 Reels 固定尺寸**。[YouTube 比例來源](https://support.google.com/youtube/answer/12779649?co=GENIE.Platform%3DDesktop&hl=zh-Hant)（存取：2026-10-02）；[Instagram 比例來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 時長 | **3–180 秒** | 取 Instagram API 的 3 秒下限與 YouTube Shorts 的 3 分鐘上限。[Instagram 來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02）；[YouTube 來源](https://support.google.com/youtube/answer/12779649?co=GENIE.Platform%3DDesktop&hl=zh-Hant)（存取：2026-10-02） |
| 容器 | **MP4；無 edit lists；Fast Start** | MP4、無 edit lists、前置 `moov` atom 同時出現在兩方官方文件。[YouTube 來源](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02）；[Instagram 來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 視訊 | **H.264 High Profile；progressive；yuv420p；CABAC；closed GOP；2 B-frames** | H.264、progressive 與 4:2:0 是兩方相容交集；High Profile、CABAC 與 2 B-frames 採 YouTube 官方建議。[YouTube 來源](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02）；[Instagram 來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 視訊位元率 | **VBR，目標 8 Mbps，且不超過 25 Mbps** | 8 Mbps 是 YouTube 對 1080p SDR、24／25／30 fps 的建議值；Instagram API 的 VBR 上限為 25 Mbps。[YouTube 來源](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02）；[Instagram 來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 幀率 | **固定 30 fps** | 30 fps 符合 Instagram 一般 Reels 的最低值及 API 的 23–60 fps 範圍，也在 YouTube 所列常見幀率中。30 fps 是 KeySift 的單一輸出選擇，**不是兩平台共同推薦值**。[YouTube 來源](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02）；[Instagram 一般 Reels 來源](https://help.instagram.com/1038071743007909)（存取：2026-10-02）；[Instagram API 來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |
| 音訊 | **AAC-LC、48 kHz、stereo、128 kbps** | AAC 與 48 kHz 可同時符合兩方文件；128 kbps 採 Instagram API 規格。AAC-LC、stereo 採 YouTube 建議。[YouTube 來源](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02）；[Instagram 來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02） |

### ffmpeg 對應參數

輸入畫面應先在剪輯／合成階段完成 9:16 排版；以下縮放假設來源本身就是 9:16，以免自動加黑邊或意外裁掉內容。

```bash
ffmpeg -i INPUT \
  -vf "scale=1080:1920:flags=lanczos,setsar=1" \
  -r 30 -fps_mode cfr \
  -c:v libx264 -profile:v high -pix_fmt yuv420p \
  -b:v 8M -maxrate 25M -bufsize 16M \
  -g 15 -keyint_min 15 -bf 2 -flags +cgop \
  -c:a aac -profile:a aac_low -ar 48000 -ac 2 -b:a 128k \
  -movflags +faststart -use_editlist 0 \
  OUTPUT.mp4
```

`-g 15` 對應 30 fps 下「GOP 為畫面更新率的一半」的 YouTube 建議；`-flags +cgop` 對應兩方的 closed GOP 要求／建議。[YouTube 編碼來源](https://support.google.com/youtube/answer/1722171?hl=zh-Hant)（存取：2026-10-02）；[Instagram 編碼來源](https://developers.facebook.com/documentation/instagram-platform/instagram-graph-api/reference/ig-user/media#reels-specs)（存取：2026-10-02）。

## UI 安全區實務

1. **共用自然貼文不採固定百分比模板。** YouTube 與 Instagram 都沒有在上述自然 Shorts／Reels 官方頁面公布可共用的固定數值安全區；不可把 Meta 的廣告百分比冒充自然貼文規格。[YouTube 來源](https://support.google.com/youtube/answer/16215842?co=GENIE.Platform%3DAndroid&hl=zh-Hant)（存取：2026-10-02）；[Instagram／Meta 來源](https://www.facebook.com/business/ads-guide/update/video/instagram-reels/traffic)（存取：2026-10-02）。
2. **重要文字、標誌、主體與操作提示不要貼近四邊。** 這符合 YouTube 對「非安全區域」與互動元素位置的提示，也符合 Meta 對 Reels 廣告四邊留空的官方建議。[YouTube 來源](https://support.google.com/youtube/answer/16215842?co=GENIE.Platform%3DAndroid&hl=zh-Hant)（存取：2026-10-02）；[Meta 來源](https://www.facebook.com/business/help/980593475366490)（存取：2026-10-02）。
3. **發布前分別預覽兩個 App 的實際介面。** 在 YouTube Shorts 編輯器移動文字／貼紙，依視覺輔助工具避開按鈕、留言、影片說明及白線標出的非安全區；Instagram 自然 Reels 因官方未提供固定數字，應以實際發布介面檢查為準。[YouTube 來源](https://support.google.com/youtube/answer/16215842?co=GENIE.Platform%3DAndroid&hl=zh-Hant)（存取：2026-10-02）；Instagram 自然 Reels 數值安全區：**官方未明示**。
4. **若素材也會投放為 Reels 廣告，另採廣告安全區。** 頂端 14%、底端 35%、左右各 6% 不放重要文字、標誌或主體；這是 Meta 廣告建議，不是自然 Reels 的硬性規格。[Meta Reels 廣告來源](https://www.facebook.com/business/ads-guide/update/video/instagram-reels/traffic)（存取：2026-10-02）。
