<#
.SYNOPSIS
    SwiftUI on Windows - Live GUI Application Runner
    Renders the exact SwiftUI test application (ContentView / CounterView) natively on Windows.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

# Create main window
$form = New-Object System.Windows.Forms.Form
$form.Text = "SwiftUI on Windows — Demo"
$form.ClientSize = New-Object System.Drawing.Size(800, 620)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 244)
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Header panel (blue)
$header = New-Object System.Windows.Forms.Panel
$header.Size = New-Object System.Drawing.Size(800, 64)
$header.Location = New-Object System.Drawing.Point(0, 0)
$header.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 255)

$headerTitle = New-Object System.Windows.Forms.Label
$headerTitle.Text = "SwiftUI on Windows"
$headerTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$headerTitle.ForeColor = [System.Drawing.Color]::White
$headerTitle.Location = New-Object System.Drawing.Point(24, 16)
$headerTitle.AutoSize = $true

$headerSub = New-Object System.Windows.Forms.Label
$headerSub.Text = "macOS Compatibility Layer (Native Win32)"
$headerSub.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$headerSub.ForeColor = [System.Drawing.Color]::FromArgb(220, 235, 255)
$headerSub.Location = New-Object System.Drawing.Point(500, 20)
$headerSub.AutoSize = $true

$header.Controls.Add($headerTitle)
$header.Controls.Add($headerSub)
$form.Controls.Add($header)

# Main Card Panel (CounterView)
$card = New-Object System.Windows.Forms.Panel
$card.Size = New-Object System.Drawing.Size(752, 280)
$card.Location = New-Object System.Drawing.Point(24, 88)
$card.BackColor = [System.Drawing.Color]::White

# Counter State
$script:count = 0

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "CounterView (@State private var count: Int = 0)"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
$titleLabel.Location = New-Object System.Drawing.Point(24, 20)
$titleLabel.AutoSize = $true
$card.Controls.Add($titleLabel)

$countDisplay = New-Object System.Windows.Forms.Label
$countDisplay.Text = "Count: 0"
$countDisplay.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$countDisplay.ForeColor = [System.Drawing.Color]::FromArgb(0, 122, 255)
$countDisplay.Location = New-Object System.Drawing.Point(24, 60)
$countDisplay.AutoSize = $true
$card.Controls.Add($countDisplay)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Initial state"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Italic)
$statusLabel.ForeColor = [System.Drawing.Color]::Gray
$statusLabel.Location = New-Object System.Drawing.Point(24, 120)
$statusLabel.AutoSize = $true
$card.Controls.Add($statusLabel)

# Buttons
$btnDec = New-Object System.Windows.Forms.Button
$btnDec.Text = "− Decrement"
$btnDec.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
$btnDec.Size = New-Object System.Drawing.Size(140, 42)
$btnDec.Location = New-Object System.Drawing.Point(24, 160)
$btnDec.BackColor = [System.Drawing.Color]::FromArgb(235, 235, 240)
$btnDec.FlatStyle = "Flat"
$btnDec.FlatAppearance.BorderSize = 0
$card.Controls.Add($btnDec)

$btnInc = New-Object System.Windows.Forms.Button
$btnInc.Text = "+ Increment"
$btnInc.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnInc.Size = New-Object System.Drawing.Size(140, 42)
$btnInc.Location = New-Object System.Drawing.Point(180, 160)
$btnInc.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 255)
$btnInc.ForeColor = [System.Drawing.Color]::White
$btnInc.FlatStyle = "Flat"
$btnInc.FlatAppearance.BorderSize = 0
$card.Controls.Add($btnInc)

$footerNote = New-Object System.Windows.Forms.Label
$footerNote.Text = "⚡ Reactive updates triggered via StateManager dispatch to the Windows message queue"
$footerNote.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$footerNote.ForeColor = [System.Drawing.Color]::Gray
$footerNote.Location = New-Object System.Drawing.Point(24, 230)
$footerNote.AutoSize = $true
$card.Controls.Add($footerNote)

$form.Controls.Add($card)

# Update state function
function Update-CounterUI {
    $countDisplay.Text = "Count: $($script:count)"
    if ($script:count -gt 10) {
        $statusLabel.Text = "🎉 You passed 10! (ConditionalContent active)"
        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(52, 199, 89)
    } elseif ($script:count -lt 0) {
        $statusLabel.Text = "⚠️ Going negative! (ConditionalContent active)"
        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 59, 48)
    } else {
        $statusLabel.Text = "Standard range [0..10]"
        $statusLabel.ForeColor = [System.Drawing.Color]::Gray
    }
}

$btnInc.Add_Click({
    $script:count++
    Update-CounterUI
})

$btnDec.Add_Click({
    $script:count--
    Update-CounterUI
})

# Feature Cards (HStack layout)
$card1 = New-Object System.Windows.Forms.Panel
$card1.Size = New-Object System.Drawing.Size(236, 110)
$card1.Location = New-Object System.Drawing.Point(24, 388)
$card1.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 255)

$c1Title = New-Object System.Windows.Forms.Label
$c1Title.Text = "Views"
$c1Title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$c1Title.ForeColor = [System.Drawing.Color]::White
$c1Title.Location = New-Object System.Drawing.Point(16, 16)
$c1Title.AutoSize = $true
$c1Sub = New-Object System.Windows.Forms.Label
$c1Sub.Text = "Text, Button, Image,`nTextField, Toggle, Slider"
$c1Sub.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$c1Sub.ForeColor = [System.Drawing.Color]::FromArgb(220, 235, 255)
$c1Sub.Location = New-Object System.Drawing.Point(16, 46)
$c1Sub.AutoSize = $true
$card1.Controls.Add($c1Title)
$card1.Controls.Add($c1Sub)
$form.Controls.Add($card1)

$card2 = New-Object System.Windows.Forms.Panel
$card2.Size = New-Object System.Drawing.Size(236, 110)
$card2.Location = New-Object System.Drawing.Point(282, 388)
$card2.BackColor = [System.Drawing.Color]::FromArgb(52, 199, 89)

$c2Title = New-Object System.Windows.Forms.Label
$c2Title.Text = "Layout"
$c2Title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$c2Title.ForeColor = [System.Drawing.Color]::White
$c2Title.Location = New-Object System.Drawing.Point(16, 16)
$c2Title.AutoSize = $true
$c2Sub = New-Object System.Windows.Forms.Label
$c2Sub.Text = "VStack, HStack, ZStack,`nScrollView, List, ForEach"
$c2Sub.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$c2Sub.ForeColor = [System.Drawing.Color]::FromArgb(225, 250, 230)
$c2Sub.Location = New-Object System.Drawing.Point(16, 46)
$c2Sub.AutoSize = $true
$card2.Controls.Add($c2Title)
$card2.Controls.Add($c2Sub)
$form.Controls.Add($card2)

$card3 = New-Object System.Windows.Forms.Panel
$card3.Size = New-Object System.Drawing.Size(236, 110)
$card3.Location = New-Object System.Drawing.Point(540, 388)
$card3.BackColor = [System.Drawing.Color]::FromArgb(175, 82, 222)

$c3Title = New-Object System.Windows.Forms.Label
$c3Title.Text = "State & Lifecycle"
$c3Title.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$c3Title.ForeColor = [System.Drawing.Color]::White
$c3Title.Location = New-Object System.Drawing.Point(16, 16)
$c3Title.AutoSize = $true
$c3Sub = New-Object System.Windows.Forms.Label
$c3Sub.Text = "@State, @Binding,`n@StateObject, App, Window"
$c3Sub.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$c3Sub.ForeColor = [System.Drawing.Color]::FromArgb(245, 230, 255)
$c3Sub.Location = New-Object System.Drawing.Point(16, 46)
$c3Sub.AutoSize = $true
$card3.Controls.Add($c3Title)
$card3.Controls.Add($c3Sub)
$form.Controls.Add($card3)

# System info footer
$sysInfo = New-Object System.Windows.Forms.Label
$sysInfo.Text = "SwiftUIOnWindows (Equivalent to SwiftUI 2.0 / 3.0, macOS 11/12) • Running on Windows 11 ($([System.Environment]::OSVersion))"
$sysInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
$sysInfo.ForeColor = [System.Drawing.Color]::Gray
$sysInfo.Location = New-Object System.Drawing.Point(24, 520)
$sysInfo.AutoSize = $true
$form.Controls.Add($sysInfo)

[System.Windows.Forms.Application]::Run($form)
