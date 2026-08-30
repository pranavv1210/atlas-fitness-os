# Generates Atlas favicon sizes and the Open Graph card.
# Uses only files already in the repository (logo + Gilroy fonts).
# Regenerate any time brand assets change:
#   powershell -ExecutionPolicy Bypass -File scripts/make-brand-assets.ps1

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$root  = Split-Path -Parent $PSScriptRoot
$logo  = Join-Path $root 'public/brand/atlas-logo.png'
$ogDir = Join-Path $root 'public/og'
$brand = Join-Path $root 'public/brand'

if (!(Test-Path $ogDir)) { New-Item -ItemType Directory -Path $ogDir -Force | Out-Null }

# Load brand fonts (fall back to system fonts if GDI+ cannot read the OTF).
$gilroyBold = $null
$gilroyLight = $null
$fonts = New-Object System.Drawing.Text.PrivateFontCollection
try {
  $fonts.AddFontFile((Join-Path $root 'public/fonts/Gilroy-ExtraBold.otf'))
  $fonts.AddFontFile((Join-Path $root 'public/fonts/Gilroy-Light.otf'))
  $gilroyBold  = New-Object System.Drawing.Font($fonts.Families[0], 120, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $gilroyLight = New-Object System.Drawing.Font($fonts.Families[1], 40,  [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
} catch {
  Write-Warning "Could not load Gilroy fonts ($_). Falling back to system fonts."
}
if (-not $gilroyBold)  { $gilroyBold  = New-Object System.Drawing.Font('Segoe UI', 66, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel) }
if (-not $gilroyLight) { $gilroyLight = New-Object System.Drawing.Font('Segoe UI', 24, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel) }

$logoImg = [System.Drawing.Image]::FromFile($logo)

function New-Graphic([int]$w, [int]$h) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  return ,@($bmp, $g)
}

function Save-Downscale([string]$srcPath, [string]$dstPath, [int]$size) {
  $img = [System.Drawing.Image]::FromFile($srcPath)
  $pair = New-Graphic $size $size
  $bmp = $pair[0]; $g = $pair[1]
  try {
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($img, 0, 0, $size, $size)
    $bmp.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "  wrote $dstPath ($size x $size)"
  } finally {
    $g.Dispose(); $bmp.Dispose(); $img.Dispose()
  }
}

function Get-Color([string]$html, [int]$alpha = 255) {
  $base = [System.Drawing.ColorTranslator]::FromHtml($html)
  return [System.Drawing.Color]::FromArgb($alpha, $base)
}

# ---- Favicon + app icons (downscaled from the 192px logo) ----
Write-Output 'Generating favicon / app icons...'
Save-Downscale $logo (Join-Path $brand 'favicon-16.png') 16
Save-Downscale $logo (Join-Path $brand 'favicon-32.png') 32
Save-Downscale $logo (Join-Path $brand 'apple-touch-icon.png') 180
Save-Downscale $logo (Join-Path $brand 'icon-512.png') 512

# ---- Open Graph card (1200 x 630) ----
Write-Output 'Generating Open Graph card...'
$pair   = New-Graphic 1200 630
$bmp    = $pair[0]; $g = $pair[1]
$top    = Get-Color '#141A22'
$bottom = Get-Color '#0A0C10'
$white  = Get-Color '#FFFFFF'
$muted  = Get-Color '#9AA7B5'
$dim    = Get-Color '#5E6A78'
$blue   = Get-Color '#2563FF'
$cyan   = Get-Color '#22C8E8'

try {
  # Vertical graphite gradient
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, 1200, 630)), $top, $bottom,
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillRectangle($bg, 0, 0, 1200, 630)
  $bg.Dispose()

  # Soft blue radial glow top-left
  $glow = New-Object System.Drawing.Drawing2D.GraphicsPath
  $glow.AddEllipse(-260, -320, 900, 900)
  $pg = New-Object System.Drawing.Drawing2D.PathGradientBrush($glow)
  $pg.CenterColor = Get-Color '#2563FF' 34
  $pg.SurroundColors = @(Get-Color '#0A0C10' 0)
  $g.FillPath($pg, $glow)
  $pg.Dispose(); $glow.Dispose()

  # Fine grid (subdued)
  $gridPen = New-Object System.Drawing.Pen((Get-Color '#FFFFFF' 14), 1)
  for ($x = 0; $x -le 1200; $x += 80) { $g.DrawLine($gridPen, $x, 0, $x, 630) }
  for ($y = 0; $y -le 630; $y += 80)  { $g.DrawLine($gridPen, 0, $y, 1200, $y) }
  $gridPen.Dispose()

  # Logo
  $g.DrawImage($logoImg, 84, 74, 128, 128)

  # Headline "Atlas"
  $sfLeft = New-Object System.Drawing.StringFormat
  $sfLeft.Alignment = [System.Drawing.StringAlignment]::Near
  $sfLeft.LineAlignment = [System.Drawing.StringAlignment]::Near
  $g.DrawString('Atlas', $gilroyBold, (New-Object System.Drawing.SolidBrush($white)), 82, 248, $sfLeft)

  # Accent line (Atlas blue -> cyan)
  $acc = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(86, 396, 170, 6)), $blue, $cyan, 0.0)
  $g.FillRectangle($acc, 86, 396, 170, 6)
  $acc.Dispose()

  # Tagline
  $g.DrawString('Your Personal Fitness Operating System', $gilroyLight, (New-Object System.Drawing.SolidBrush($muted)), 84, 430, $sfLeft)

  # Bottom feature line
  $small = New-Object System.Drawing.Font('Segoe UI', 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString('2,069 exercises  -  5-day training cycle  -  Progress - History - Hydration - Goals', $small, (New-Object System.Drawing.SolidBrush($dim)), 84, 556, $sfLeft)
  $small.Dispose()

  $bmp.Save((Join-Path $ogDir 'atlas-og.png'), [System.Drawing.Imaging.ImageFormat]::Png)
  Write-Output '  wrote public/og/atlas-og.png (1200 x 630)'
} finally {
  $g.Dispose(); $bmp.Dispose(); $logoImg.Dispose()
}

Write-Output 'Done.'