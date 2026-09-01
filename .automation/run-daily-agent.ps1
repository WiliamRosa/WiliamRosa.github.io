# Roda o agente diario de conteudo do blog em modo headless.
# Chamado pelo Windows Task Scheduler - nao interativo, sem humano observando.

$ErrorActionPreference = "Continue"

# Task Scheduler nao herda o PATH atualizado por instaladores recentes (node, uv).
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$blogDir = "C:\Users\Anônimo\Desktop\repos_wiliam\MVP\blog"
$promptFile = Join-Path $blogDir ".automation\daily-content-agent.md"
$logDir = Join-Path $blogDir ".automation\logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }

$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$logFile = Join-Path $logDir "$timestamp.log"

Set-Location $blogDir

$prompt = Get-Content -Raw -Encoding UTF8 $promptFile

"===== Daily content agent run: $timestamp =====" | Out-File -FilePath $logFile -Encoding utf8

$prompt | & claude -p --permission-mode bypassPermissions --add-dir $blogDir *>&1 |
    Tee-Object -FilePath $logFile -Append

"===== End of run =====" | Out-File -FilePath $logFile -Append -Encoding utf8

# Mantem so os ultimos 30 logs
Get-ChildItem $logDir -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -Skip 30 | Remove-Item -Force
