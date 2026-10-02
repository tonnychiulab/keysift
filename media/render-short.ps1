param(
    [string]$OutputPath = (Join-Path $PSScriptRoot "keysift-short-zh-TW.mp4")
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Speech

$Width = 1080
$Height = 1920
$Fps = 30
$SceneDuration = 5
$SceneCount = 7
$TotalDuration = 36

function Get-Color([string]$Hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

$Colors = @{
    Background = Get-Color "#070B16"
    Surface = Get-Color "#11182B"
    SurfaceLight = Get-Color "#18223A"
    Purple = Get-Color "#8B5CF6"
    PurpleLight = Get-Color "#C4B5FD"
    Teal = Get-Color "#2DD4BF"
    Green = Get-Color "#4ADE80"
    Red = Get-Color "#FB7185"
    Amber = Get-Color "#FBBF24"
    White = Get-Color "#F8FAFC"
    Muted = Get-Color "#94A3B8"
    Border = Get-Color "#293653"
}

function New-RoundedPath(
    [float]$X,
    [float]$Y,
    [float]$W,
    [float]$H,
    [float]$Radius
) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $Radius * 2
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $W - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $W - $diameter, $Y + $H - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $H - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Fill-RoundedRect(
    [System.Drawing.Graphics]$Graphics,
    [System.Drawing.Color]$Color,
    [float]$X,
    [float]$Y,
    [float]$W,
    [float]$H,
    [float]$Radius
) {
    $path = New-RoundedPath $X $Y $W $H $Radius
    $brush = [System.Drawing.SolidBrush]::new($Color)
    try {
        $Graphics.FillPath($brush, $path)
    }
    finally {
        $brush.Dispose()
        $path.Dispose()
    }
}

function Stroke-RoundedRect(
    [System.Drawing.Graphics]$Graphics,
    [System.Drawing.Color]$Color,
    [float]$Thickness,
    [float]$X,
    [float]$Y,
    [float]$W,
    [float]$H,
    [float]$Radius
) {
    $path = New-RoundedPath $X $Y $W $H $Radius
    $pen = [System.Drawing.Pen]::new($Color, $Thickness)
    try {
        $Graphics.DrawPath($pen, $path)
    }
    finally {
        $pen.Dispose()
        $path.Dispose()
    }
}

function Draw-Text(
    [System.Drawing.Graphics]$Graphics,
    [string]$Text,
    [float]$Size,
    [System.Drawing.Color]$Color,
    [float]$X,
    [float]$Y,
    [float]$W,
    [float]$H,
    [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular,
    [string]$Family = "Microsoft JhengHei",
    [System.Drawing.StringAlignment]$Alignment = [System.Drawing.StringAlignment]::Near
) {
    $font = [System.Drawing.Font]::new($Family, $Size, $Style, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = [System.Drawing.SolidBrush]::new($Color)
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = $Alignment
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    try {
        $Graphics.DrawString($Text, $font, $brush, [System.Drawing.RectangleF]::new($X, $Y, $W, $H), $format)
    }
    finally {
        $format.Dispose()
        $brush.Dispose()
        $font.Dispose()
    }
}

function Draw-Pill(
    [System.Drawing.Graphics]$Graphics,
    [string]$Text,
    [System.Drawing.Color]$Fill,
    [System.Drawing.Color]$Foreground,
    [float]$X,
    [float]$Y,
    [float]$W
) {
    Fill-RoundedRect $Graphics $Fill $X $Y $W 58 29
    Draw-Text $Graphics $Text 26 $Foreground $X ($Y + 10) $W 42 ([System.Drawing.FontStyle]::Bold) "Microsoft JhengHei" ([System.Drawing.StringAlignment]::Center)
}

function Draw-Brand([System.Drawing.Graphics]$Graphics, [float]$Y) {
    Fill-RoundedRect $Graphics $Colors.Purple 74 $Y 72 72 20
    $dotBrush = [System.Drawing.SolidBrush]::new($Colors.White)
    try {
        foreach ($point in @(@(94, 20), @(118, 20), @(106, 42))) {
            $Graphics.FillEllipse($dotBrush, $point[0], $Y + $point[1], 10, 10)
        }
    }
    finally {
        $dotBrush.Dispose()
    }
    Draw-Text $Graphics "KEYSIFT" 40 $Colors.White 166 ($Y + 8) 430 58 ([System.Drawing.FontStyle]::Bold) "Consolas"
}

function New-Scene([string]$Path, [scriptblock]$Painter) {
    $bitmap = [System.Drawing.Bitmap]::new($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $background = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.Rectangle]::new(0, 0, $Width, $Height),
        $Colors.Background,
        (Get-Color "#101936"),
        55
    )
    try {
        $graphics.FillRectangle($background, 0, 0, $Width, $Height)
        & $Painter $graphics
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $background.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

function Resolve-Executable([string]$Name) {
    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }

    $packageRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    $candidate = Get-ChildItem -Path $packageRoot -Filter "$Name.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $candidate) {
        throw "$Name was not found. Install FFmpeg before rendering."
    }

    return $candidate.FullName
}

$ffmpeg = Resolve-Executable "ffmpeg"
$ffprobe = Resolve-Executable "ffprobe"
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("keysift-video-" + [Guid]::NewGuid().ToString("N"))
[System.IO.Directory]::CreateDirectory($temp) | Out-Null
[System.IO.Directory]::CreateDirectory((Split-Path -Parent $OutputPath)) | Out-Null

try {
    $scenes = @()
    for ($index = 1; $index -le $SceneCount; $index++) {
        $scenes += Join-Path $temp ("scene-{0:D2}.png" -f $index)
    }

    New-Scene $scenes[0] {
        param($g)
        Draw-Brand $g 108
        Draw-Pill $g "CONFIG SECURITY" $Colors.SurfaceLight $Colors.PurpleLight 74 280 330
        Draw-Text $g "比對 .env" 108 $Colors.White 74 420 930 150 ([System.Drawing.FontStyle]::Bold)
        Draw-Text $g "不該洩漏秘密" 108 $Colors.White 74 555 930 300 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundedRect $g $Colors.Surface 74 980 932 310 34
        Stroke-RoundedRect $g $Colors.Border 2 74 980 932 310 34
        Draw-Text $g "API_TOKEN" 34 $Colors.Muted 124 1035 430 55 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "sk_live_••••••••" 38 $Colors.Red 124 1105 710 65 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "STOP" 28 $Colors.White 794 1048 130 45 ([System.Drawing.FontStyle]::Bold) "Consolas" ([System.Drawing.StringAlignment]::Center)
        Fill-RoundedRect $g $Colors.Red 790 1112 140 10 5
        Draw-Text $g "別再把 Token 印進 CI log" 42 $Colors.Teal 74 1450 932 90 ([System.Drawing.FontStyle]::Bold)
        Draw-Text $g "01 / 07" 24 $Colors.Muted 74 1640 932 40 ([System.Drawing.FontStyle]::Regular) "Consolas" ([System.Drawing.StringAlignment]::Far)
    }

    New-Scene $scenes[1] {
        param($g)
        Draw-Brand $g 108
        Draw-Pill $g "SECRET-SAFE DIFF" $Colors.Purple $Colors.White 74 300 360
        Draw-Text $g "只比對差異" 105 $Colors.White 74 470 932 145 ([System.Drawing.FontStyle]::Bold)
        Draw-Text $g "不曝光值" 105 $Colors.Teal 74 610 932 145 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundedRect $g $Colors.Surface 74 900 932 350 36
        Draw-Text $g "KEY" 28 $Colors.Muted 124 970 220 45 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "STATUS" 28 $Colors.Muted 640 970 260 45 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "API_TOKEN" 38 $Colors.White 124 1060 410 55 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Pill $g "CHANGED" (Get-Color "#3A254D") $Colors.Red 636 1048 260
        Draw-Pill $g "SAFE OUTPUT" (Get-Color "#153C3A") $Colors.Teal 74 1380 300
        Draw-Pill $g ".NET 10" $Colors.SurfaceLight $Colors.PurpleLight 398 1380 230
        Draw-Pill $g "MIT" $Colors.SurfaceLight $Colors.White 652 1380 170
        Draw-Text $g "02 / 07" 24 $Colors.Muted 74 1640 932 40 ([System.Drawing.FontStyle]::Regular) "Consolas" ([System.Drawing.StringAlignment]::Far)
    }

    New-Scene $scenes[2] {
        param($g)
        Draw-Brand $g 108
        Draw-Text $g "差異，一眼看懂" 78 $Colors.White 74 300 932 110 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundedRect $g (Get-Color "#0A0F1D") 74 500 932 760 36
        Stroke-RoundedRect $g $Colors.Border 2 74 500 932 760 36
        Draw-Text $g "●  ●  ●" 25 $Colors.Muted 120 545 250 45 ([System.Drawing.FontStyle]::Regular) "Consolas"
        Draw-Text $g '$ keysift baseline.env candidate.env' 29 $Colors.Muted 120 650 810 50 ([System.Drawing.FontStyle]::Regular) "Consolas"
        Draw-Text $g "CHANGED" 31 $Colors.Red 120 775 310 50 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "API_TOKEN" 31 $Colors.White 580 775 330 50 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "MISSING_FROM_BASELINE" 31 $Colors.Amber 120 865 450 50 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "NEW_FLAG" 31 $Colors.White 650 865 260 50 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "2 difference(s), 8 matching" 29 $Colors.Green 120 1010 790 50 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Pill $g "VALUES STAY HIDDEN" (Get-Color "#153C3A") $Colors.Teal 120 1125 430
        Draw-Text $g "03 / 07" 24 $Colors.Muted 74 1640 932 40 ([System.Drawing.FontStyle]::Regular) "Consolas" ([System.Drawing.StringAlignment]::Far)
    }

    New-Scene $scenes[3] {
        param($g)
        Draw-Brand $g 108
        Draw-Text $g "安全，不只一層" 82 $Colors.White 74 300 932 120 ([System.Drawing.FontStyle]::Bold)
        $cards = @(
            @{ Y = 520; Accent = $Colors.Teal; Number = "01"; Title = "鍵名級輸出"; Body = "密碼與 Token 不進 stdout、stderr、JSON" },
            @{ Y = 810; Accent = $Colors.Purple; Number = "02"; Title = "嚴格解析"; Body = "重複鍵、錯誤格式、未閉合引號直接拒絕" },
            @{ Y = 1100; Accent = $Colors.Green; Number = "03"; Title = "穩定結果"; Body = "序數排序；適合 code review 與 CI 判讀" }
        )
        foreach ($card in $cards) {
            Fill-RoundedRect $g $Colors.Surface 74 $card.Y 932 230 32
            Stroke-RoundedRect $g $Colors.Border 2 74 $card.Y 932 230 32
            Draw-Text $g $card.Number 34 $card.Accent 120 ($card.Y + 44) 100 50 ([System.Drawing.FontStyle]::Bold) "Consolas"
            Draw-Text $g $card.Title 46 $Colors.White 250 ($card.Y + 32) 680 65 ([System.Drawing.FontStyle]::Bold)
            Draw-Text $g $card.Body 30 $Colors.Muted 250 ($card.Y + 112) 660 90 ([System.Drawing.FontStyle]::Regular)
        }
        Draw-Text $g "04 / 07" 24 $Colors.Muted 74 1640 932 40 ([System.Drawing.FontStyle]::Regular) "Consolas" ([System.Drawing.StringAlignment]::Far)
    }

    New-Scene $scenes[4] {
        param($g)
        Draw-Brand $g 108
        Draw-Text $g "給人看，也給機器讀" 76 $Colors.White 74 300 932 120 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundedRect $g $Colors.Surface 74 520 932 230 32
        Draw-Pill $g "TEXT" $Colors.Purple $Colors.White 120 585 190
        Draw-Text $g "清楚的終端差異" 40 $Colors.White 350 590 560 60 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundedRect $g $Colors.Surface 74 790 932 230 32
        Draw-Pill $g "JSON" (Get-Color "#153C3A") $Colors.Teal 120 855 190
        Draw-Text $g "穩定格式，串接自動化" 40 $Colors.White 350 860 580 60 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundedRect $g $Colors.Surface 74 1060 932 230 32
        Draw-Pill $g "GLOB" (Get-Color "#3A2F14") $Colors.Amber 120 1125 190
        Draw-Text $g '--ignore "LOCAL_*"' 34 $Colors.White 350 1130 580 60 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Text $g "05 / 07" 24 $Colors.Muted 74 1640 932 40 ([System.Drawing.FontStyle]::Regular) "Consolas" ([System.Drawing.StringAlignment]::Far)
    }

    New-Scene $scenes[5] {
        param($g)
        Draw-Brand $g 108
        Draw-Pill $g "CI READY" $Colors.Purple $Colors.White 74 300 230
        Draw-Text $g "部署前，自動攔截" 82 $Colors.White 74 450 932 120 ([System.Drawing.FontStyle]::Bold)
        $boxY = 760
        Fill-RoundedRect $g $Colors.Surface 74 $boxY 250 190 28
        Draw-Text $g ".env" 50 $Colors.White 74 ($boxY + 58) 250 70 ([System.Drawing.FontStyle]::Bold) "Consolas" ([System.Drawing.StringAlignment]::Center)
        Draw-Text $g "→" 60 $Colors.PurpleLight 330 ($boxY + 58) 100 70 ([System.Drawing.FontStyle]::Bold) "Consolas" ([System.Drawing.StringAlignment]::Center)
        Fill-RoundedRect $g $Colors.Purple 430 $boxY 250 190 28
        Draw-Text $g "KeySift" 43 $Colors.White 430 ($boxY + 65) 250 65 ([System.Drawing.FontStyle]::Bold) "Consolas" ([System.Drawing.StringAlignment]::Center)
        Draw-Text $g "→" 60 $Colors.PurpleLight 686 ($boxY + 58) 100 70 ([System.Drawing.FontStyle]::Bold) "Consolas" ([System.Drawing.StringAlignment]::Center)
        Fill-RoundedRect $g (Get-Color "#153C3A") 786 $boxY 220 190 28
        Draw-Text $g "PASS`nBLOCK" 38 $Colors.Green 786 ($boxY + 42) 220 110 ([System.Drawing.FontStyle]::Bold) "Consolas" ([System.Drawing.StringAlignment]::Center)
        Draw-Pill $g "EXIT 0 / 1 / 2" $Colors.SurfaceLight $Colors.White 74 1120 360
        Draw-Pill $g "0 RUNTIME DEPENDENCIES" (Get-Color "#153C3A") $Colors.Teal 458 1120 548
        Draw-Text $g "本機、pre-deploy、GitHub Actions 都能用" 36 $Colors.Muted 74 1360 932 65 ([System.Drawing.FontStyle]::Regular)
        Draw-Text $g "06 / 07" 24 $Colors.Muted 74 1640 932 40 ([System.Drawing.FontStyle]::Regular) "Consolas" ([System.Drawing.StringAlignment]::Far)
    }

    New-Scene $scenes[6] {
        param($g)
        Draw-Brand $g 108
        Draw-Pill $g "OPEN SOURCE · MIT" $Colors.Purple $Colors.White 74 320 390
        Draw-Text $g "把設定漂移" 98 $Colors.White 74 500 932 130 ([System.Drawing.FontStyle]::Bold)
        Draw-Text $g "擋在部署前" 98 $Colors.Teal 74 630 932 130 ([System.Drawing.FontStyle]::Bold)
        Fill-RoundedRect $g $Colors.Surface 74 940 932 250 36
        Stroke-RoundedRect $g $Colors.Purple 3 74 940 932 250 36
        Draw-Text $g "github.com/" 35 $Colors.Muted 120 1000 820 50 ([System.Drawing.FontStyle]::Regular) "Consolas"
        Draw-Text $g "tonnychiulab/keysift" 48 $Colors.White 120 1060 820 70 ([System.Drawing.FontStyle]::Bold) "Consolas"
        Draw-Pill $g "STAR · TRY · SHARE" (Get-Color "#153C3A") $Colors.Teal 74 1360 430
        Draw-Text $g "KeySift 1.0" 30 $Colors.Muted 74 1510 932 50 ([System.Drawing.FontStyle]::Regular) "Consolas"
        Draw-Text $g "07 / 07" 24 $Colors.Muted 74 1640 932 40 ([System.Drawing.FontStyle]::Regular) "Consolas" ([System.Drawing.StringAlignment]::Far)
    }

    Copy-Item $scenes[0] (Join-Path $PSScriptRoot "keysift-short-cover.png") -Force
    Copy-Item $scenes[6] (Join-Path $PSScriptRoot "keysift-short-end.png") -Force

    $thumbWidth = 270
    $thumbHeight = 480
    $thumbGap = 8
    $storyboard = [System.Drawing.Bitmap]::new(
        (4 * $thumbWidth) + (5 * $thumbGap),
        (2 * $thumbHeight) + (3 * $thumbGap),
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    )
    $storyboardGraphics = [System.Drawing.Graphics]::FromImage($storyboard)
    try {
        $storyboardGraphics.Clear($Colors.Background)
        $storyboardGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        for ($index = 0; $index -lt $scenes.Count; $index++) {
            $column = $index % 4
            $row = [Math]::Floor($index / 4)
            $x = $thumbGap + ($column * ($thumbWidth + $thumbGap))
            $y = $thumbGap + ($row * ($thumbHeight + $thumbGap))
            $sceneImage = [System.Drawing.Image]::FromFile($scenes[$index])
            try {
                $storyboardGraphics.DrawImage($sceneImage, $x, $y, $thumbWidth, $thumbHeight)
            }
            finally {
                $sceneImage.Dispose()
            }
        }

        $storyboard.Save(
            (Join-Path $PSScriptRoot "keysift-short-storyboard.png"),
            [System.Drawing.Imaging.ImageFormat]::Png
        )
    }
    finally {
        $storyboardGraphics.Dispose()
        $storyboard.Dispose()
    }

    $clips = @()
    $frames = $SceneDuration * $Fps
    for ($index = 0; $index -lt $scenes.Count; $index++) {
        $clip = Join-Path $temp ("clip-{0:D2}.mp4" -f ($index + 1))
        $clips += $clip
        $zoomDirection = if ($index % 2 -eq 0) { "min(zoom+0.00035,1.035)" } else { "if(eq(on,1),1.035,max(zoom-0.00035,1.0))" }
        $filter = "scale=1180:2098,zoompan=z='$zoomDirection':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=${frames}:s=1080x1920:fps=${Fps},format=yuv420p"
        & $ffmpeg -hide_banner -loglevel error -y -loop 1 -i $scenes[$index] -vf $filter -frames:v $frames -an -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p $clip
        if ($LASTEXITCODE -ne 0) {
            throw "FFmpeg failed while rendering scene $($index + 1)."
        }
    }

    $concatFile = Join-Path $temp "clips.txt"
    $concatLines = $clips | ForEach-Object { "file '" + $_.Replace("\", "/").Replace("'", "'\''") + "'" }
    [System.IO.File]::WriteAllLines($concatFile, $concatLines, [System.Text.UTF8Encoding]::new($false))
    $silentVideo = Join-Path $temp "silent.mp4"
    & $ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i $concatFile -c copy $silentVideo
    if ($LASTEXITCODE -ne 0) {
        throw "FFmpeg failed while joining scenes."
    }

    $narrationPath = Join-Path $temp "narration.wav"
    $narration = "在 CI 裡比對環境設定時，會不會順手把 Token 也印出來？Key Sift 專門檢查設定漂移，只顯示鍵名和差異狀態，值永遠不進輸出。新增、移除和變更，一眼看懂。它會拒絕重複鍵和錯誤格式，結果穩定又安全。支援文字、JSON 和忽略規則；退出碼直接串進 CI，而且零執行期第三方依賴。開源，MIT 授權。現在就把設定漂移擋在部署前。"
    $speaker = [System.Speech.Synthesis.SpeechSynthesizer]::new()
    try {
        $speaker.SelectVoice("Microsoft Hanhan Desktop")
        $speaker.Rate = 1
        $speaker.Volume = 100
        $speaker.SetOutputToWaveFile($narrationPath)
        $speaker.Speak($narration)
    }
    finally {
        $speaker.Dispose()
    }

    $bedPath = Join-Path $temp "bed.m4a"
    $bedFilter = "[0:a]volume=0.020[a0];[1:a]volume=0.012[a1];[2:a]volume=0.008[a2];[a0][a1][a2]amix=inputs=3:normalize=0,afade=t=in:st=0:d=1,afade=t=out:st=33:d=2"
    & $ffmpeg -hide_banner -loglevel error -y `
        -f lavfi -i "sine=frequency=110:sample_rate=48000:duration=$TotalDuration" `
        -f lavfi -i "sine=frequency=165:sample_rate=48000:duration=$TotalDuration" `
        -f lavfi -i "sine=frequency=220:sample_rate=48000:duration=$TotalDuration" `
        -filter_complex $bedFilter -c:a aac -b:a 128k $bedPath
    if ($LASTEXITCODE -ne 0) {
        throw "FFmpeg failed while generating the original audio bed."
    }

    $mixFilter = "[1:a]adelay=450|450,volume=1.0[voice];[2:a]volume=1.0[bed];[voice][bed]amix=inputs=2:duration=longest:dropout_transition=0,loudnorm=I=-16:LRA=7:TP=-1.5,aresample=48000,aformat=channel_layouts=stereo,apad=pad_dur=$TotalDuration[audio]"
    & $ffmpeg -hide_banner -loglevel error -y -i $silentVideo -i $narrationPath -i $bedPath `
        -filter_complex $mixFilter -map 0:v:0 -map "[audio]" -t $TotalDuration -vf "setsar=1,tpad=stop_mode=clone:stop_duration=1" `
        -c:v libx264 -preset medium -profile:v high -pix_fmt yuv420p -b:v 8M -maxrate 25M -bufsize 16M -r $Fps -fps_mode cfr -g 15 -keyint_min 15 -bf 2 -flags +cgop `
        -c:a aac -profile:a aac_low -ar 48000 -ac 2 -b:a 128k -movflags +faststart -use_editlist 0 `
        -metadata title="KeySift — Secret-safe .env drift detection" $OutputPath
    if ($LASTEXITCODE -ne 0) {
        throw "FFmpeg failed while muxing the final video."
    }

    & $ffprobe -v error -show_entries format=duration,size:stream=codec_name,width,height,r_frame_rate,pix_fmt,sample_rate,channel_layout -of json $OutputPath
    if ($LASTEXITCODE -ne 0) {
        throw "FFprobe could not validate the final video."
    }
}
finally {
    Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
}
