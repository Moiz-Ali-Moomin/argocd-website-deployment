# start-port-forwards.ps1
# Starts port forwarding for ArgoCD, Prometheus, and Grafana

Write-Host "Starting Port Forwards..." -ForegroundColor Cyan

# 1. ArgoCD Server
# Local: 8080 -> Remote: 443 (ArgoCD usually runs on HTTPS 443 internally)
# Note: argocd-server service usually exposes 80 and 443. We'll target the service port 443 unless using insecure mode.
# Let's map 8080 to service port 443 (https)
$argoJob = Start-Job -ScriptBlock { 
    kubectl port-forward svc/argocd-server -n argocd 8080:443 
}
Write-Host "ArgoCD accessible at https://localhost:8080 (Ignore SSL warnings)"

# 2. Grafana
# Local: 3000 -> Remote: 80
$grafanaJob = Start-Job -ScriptBlock { 
    kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80 
}
Write-Host "Grafana accessible at http://localhost:3000"

# 3. Prometheus
# Local: 9090 -> Remote: 9090
$promJob = Start-Job -ScriptBlock { 
    kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090 
}
Write-Host "Prometheus accessible at http://localhost:9090"

Write-Host "`nPort forwards are running in background jobs." -ForegroundColor Green
Write-Host "To stop them, close this PowerShell session or run 'Get-Job | Stop-Job'"
Write-Host "Press Enter to view job status..."
Read-Host
Get-Job
