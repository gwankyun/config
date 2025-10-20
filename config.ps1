$wezterm = ".wezterm.lua"
$from_wezterm = Join-Path $PSScriptRoot $wezterm
$to_wezterm = Join-Path $HOME $wezterm

$alacritty = "alacritty"
$from_alacritty = Join-Path $PSScriptRoot $alacritty
$to_alacritty = Join-Path $env:APPDATA $alacritty

function New-Symlink {
    param (
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    # 检查目标路径是否存在，存在则删除
    if (Test-Path $Destination -PathType Container) {
        Write-Host "Removing existing file at $Destination"
        Remove-Item $Destination -Recurse
    }
    else {
        Remove-Item $Destination
    }

    # 创建符号链接
    Write-Host "Creating symlink from $Source to $Destination"
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source
}

# 调用函数创建符号链接
New-Symlink -Source $from_wezterm -Destination $to_wezterm
New-Symlink -Source $from_alacritty -Destination $to_alacritty
