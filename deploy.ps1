# deploy.ps1 - Deployment Script

# 1. ArgoCD Installation
Write-Host "Checking ArgoCD Installation..."
if (-not (kubectl get namespace argocd --ignore-not-found)) {
    Write-Host "Creating 'argocd' namespace..."
    kubectl create namespace argocd
}

# Check if ArgoCD is installed (checking one key deployment)
if (-not (kubectl get deployment argocd-server -n argocd --ignore-not-found)) {
    Write-Host "Installing ArgoCD..."
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    Write-Host "Waiting for ArgoCD components to be ready..."
    kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s
} else {
    Write-Host "ArgoCD is already installed."
}


# 2. Apply Cluster Resources (Issuer, etc.)
Write-Host "Applying Cluster Resources..."
kubectl apply -f k8s/cluster-resources/

# 3. Create Secret (Manual Step reminder, or interactive)
if (-not (kubectl get secret argocd-website-secret -n default --ignore-not-found)) {
    Write-Warning "Secret 'argocd-website-secret' not found!"
    Write-Host "Creating sample secret from template (Update this later!)..."
    kubectl apply -f k8s/base/secret.template.yaml
}

# 4. Apply Application (via Kustomize Prod Overlay)
Write-Host "Deploying Application..."
kubectl apply -k k8s/overlays/prod

# 5. Install Prometheus & Grafana (kube-prometheus-stack)
Write-Host "Installing/Upgrading Prometheus Stack..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
# Install in 'monitoring' namespace
if (-not (kubectl get namespace monitoring --ignore-not-found)) {
    kubectl create namespace monitoring
}
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring

Write-Host "Deployment Complete."
Write-Host "----------------------------------------------------------------"
Write-Host "To access ArgoCD, Prometheus, and Grafana, please run:"
Write-Host ".\start-port-forwards.ps1"
Write-Host "----------------------------------------------------------------"

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

Write-Host "`nGetting ArgoCD Initial Admin Password..."
try {
    $argoPassword = kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}"
    if ($argoPassword) {
        $decodedArgoPassword = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($argoPassword))
        Write-Host "ArgoCD Admin Password: $decodedArgoPassword" -ForegroundColor Cyan
        Write-Host "User: admin"
    } else {
        Write-Warning "Could not retrieve ArgoCD password. Use 'argocd admin initial-password -n argocd' if needed."
    }
} catch {
    Write-Warning "Error retrieving ArgoCD password: $_"
}
