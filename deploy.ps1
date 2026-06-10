# ============================================
# NuclearLedger Frontend Deploy Script
# Usage: .\deploy.ps1
# ============================================

$ErrorActionPreference = "Stop"

$SERVER = "114.55.67.239"
$USER = "root"
$REMOTE_DIR = "/var/www/tech-portfolio"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$KEY_PATH = "$env:USERPROFILE\.ssh\id_rsa"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  NuclearLedger Frontend Deploy" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Step 1: Setup SSH key (only 1 password prompt)
Write-Host ""
Write-Host "[1/5] Setting up SSH keyless login..." -ForegroundColor Yellow

if (!(Test-Path $KEY_PATH)) {
    Write-Host "  Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f $KEY_PATH -N '""' -q
}

# Check if key is already authorized on server
$keyAlreadyInstalled = $false
$checkResult = ssh -o BatchMode=yes -o ConnectTimeout=5 "${USER}@${SERVER}" "echo ok" 2>$null
if ($LASTEXITCODE -eq 0) {
    $keyAlreadyInstalled = $true
    Write-Host "  SSH key already authorized, skipping." -ForegroundColor Green
}

if (!$keyAlreadyInstalled) {
    Write-Host "  Enter server password (only once):" -ForegroundColor Yellow
    $pubKey = Get-Content "$KEY_PATH.pub" -Raw
    $pubKey = $pubKey.Trim()
    $secCmd = "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '$pubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && sort -u ~/.ssh/authorized_keys -o ~/.ssh/authorized_keys"
    ssh "${USER}@${SERVER}" $secCmd
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Failed to setup SSH key!" -ForegroundColor Red
        exit 1
    }
    Write-Host "  SSH key installed. Future deploys won't need password." -ForegroundColor Green
}

# Step 2: Build
Write-Host ""
Write-Host "[2/5] Building frontend..." -ForegroundColor Yellow
Set-Location $SCRIPT_DIR
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  Build complete: dist/" -ForegroundColor Green

# Step 3: Upload dist to server (no password needed now)
Write-Host ""
Write-Host "[3/5] Uploading files to server..." -ForegroundColor Yellow

ssh "${USER}@${SERVER}" "mkdir -p ${REMOTE_DIR}"
scp -r "${SCRIPT_DIR}\dist\*" "${USER}@${SERVER}:${REMOTE_DIR}/"
Write-Host "  Upload complete." -ForegroundColor Green

# Step 4: Configure Nginx
Write-Host ""
Write-Host "[4/5] Configuring Nginx..." -ForegroundColor Yellow

$nginxConfig = @"
server {
    listen 80;
    server_name ${SERVER};

    root ${REMOTE_DIR};
    index index.html;

    location / {
        try_files `$uri `$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto `$scheme;
    }

    location /uploads/ {
        proxy_pass http://localhost:8080;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
"@

$nginxConfig | ssh "${USER}@${SERVER}" "cat > /tmp/tech-portfolio.conf"

ssh "${USER}@${SERVER}" @"
# Install nginx if not present
if ! command -v nginx &> /dev/null; then
    echo '  Installing Nginx...'
    if command -v apt-get &> /dev/null; then
        apt-get update -qq && apt-get install -y -qq nginx
    elif command -v yum &> /dev/null; then
        yum install -y nginx
    fi
fi

# Move config into place
cp /tmp/tech-portfolio.conf /etc/nginx/conf.d/tech-portfolio.conf

# Remove default site if it conflicts
rm -f /etc/nginx/sites-enabled/default 2>/dev/null
rm -f /etc/nginx/conf.d/default.conf 2>/dev/null

# Start nginx if not running, otherwise reload
if ! pgrep nginx &> /dev/null; then
    nginx
else
    nginx -t && nginx -s reload
fi
echo '  Nginx configured.'
"@

Write-Host "  Nginx configured." -ForegroundColor Green

# Step 5: Done
Write-Host ""
Write-Host "[5/5] Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Your site is live at:" -ForegroundColor Cyan
Write-Host "  http://${SERVER}" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
