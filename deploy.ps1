# deploy.ps1 - Deployment Script

# 1. Apply Cluster Resources (Issuer, etc.)
Write-Host "Applying Cluster Resources..."
kubectl apply -f k8s/cluster-resources/

# 2. Create Secret (Manual Step reminder, or interactive)
if (-not (kubectl get secret argocd-website-secret -n default --ignore-not-found)) {
    Write-Warning "Secret 'argocd-website-secret' not found!"
    Write-Host "Creating sample secret from template (Update this later!)..."
    kubectl apply -f k8s/base/secret.template.yaml
    # Rename it to the actual secret name if using the template literally (template has correct name metadata)
}

# 3. Apply Application (via Kustomize Prod Overlay)
Write-Host "Deploying Application..."
kubectl apply -k k8s/overlays/prod

# 4. Install Prometheus & Grafana (kube-prometheus-stack)
Write-Host "Installing/Upgrading Prometheus Stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
# Install in 'monitoring' namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring

Write-Host "Deployment Complete."
Write-Host "To access Grafana: kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80"
Write-Host "To access Prometheus: kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090"

Write-Host "`nGetting Grafana Admin Password..."
try {
    $gfPassword = kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}"
    if ($gfPassword) {
        $decodedPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($gfPassword))
        Write-Host "Grafana Admin Password: $decodedPassword" -ForegroundColor Green
        Write-Host "User: admin"
    } else {
        Write-Warning "Could not retrieve Grafana password. Secret 'prometheus-grafana' might not exist yet."
    }
} catch {
    Write-Warning "Error retrieving password: $_"
}
