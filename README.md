# 🚀 TP DevOps - Usine Logicielle Complète

## Structure du projet

```
devops-tp/
├── app/                        # Code source Node.js
│   ├── app.js                  # Application Express
│   ├── package.json
│   └── test/
│       └── app.test.js         # Tests unitaires Jest
├── k8s/                        # Manifests Kubernetes
│   ├── deployment.yaml
│   ├── service.yaml
│   └── prometheus-rules.yaml   # Règles d'alerte
├── terraform/
│   └── main.tf                 # Provisionnement namespaces K8s
├── ansible/
│   ├── inventory.ini
│   └── deploy.yml              # Playbook de déploiement
├── Dockerfile                  # Multi-stage build
├── Jenkinsfile                 # Pipeline CI/CD complet
├── docker-compose.yml          # Jenkins + SonarQube
└── sonar-project.properties    # Config SonarQube
```

---

## ⚙️ ÉTAPE 1 — Démarrer Jenkins + SonarQube

```bash
docker-compose up -d
docker ps
```

- Jenkins  → http://localhost:8080
- SonarQube → http://localhost:9000  (admin / admin)

---

## ⚙️ ÉTAPE 2 — Configurer Jenkins

### Plugins à installer :
- Git, Pipeline, Docker Pipeline
- SonarQube Scanner
- Credentials Binding

### Credentials à ajouter :
| ID | Type | Valeur |
|---|---|---|
| `dockerhub-credentials` | Username/Password | Ton login Docker Hub |
| `sonar-token` | Secret text | Token généré sur SonarQube |

### Configurer SonarQube dans Jenkins :
`Manage Jenkins → Configure System → SonarQube servers`
- Name : `SonarQube`
- URL : `http://sonarqube:9000`

---

## ⚙️ ÉTAPE 3 — Démarrer Minikube

```bash
minikube start --driver=docker
kubectl cluster-info
```

---

## ⚙️ ÉTAPE 4 — Modifier le Jenkinsfile

Dans `Jenkinsfile`, remplace :
```
DOCKER_IMAGE = "TON_USERNAME/devops-tp-app"
```
Par ton vrai username Docker Hub.

---

## ⚙️ ÉTAPE 5 — Lancer le Pipeline Jenkins

1. Créer un dépôt GitHub et pousser le code
2. Créer un nouveau Pipeline Jenkins pointant sur ton repo
3. Build Now

---

## ⚙️ ÉTAPE 6 — Installer Prometheus + Grafana

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=admin123

# Accéder à Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3001:80 -n monitoring
```

Grafana → http://localhost:3001 (admin / admin123)

---

## ⚙️ ÉTAPE 7 — Appliquer les règles d'alerte

```bash
kubectl apply -f k8s/prometheus-rules.yaml
```

---

## 📸 Captures à faire

| # | Quoi |
|---|---|
| 1 | `docker ps` + SonarQube UI |
| 2 | Pipeline Jenkins tous stages ✅ |
| 3 | SonarQube Quality Gate PASSED |
| 4 | Image sur Docker Hub |
| 5 | `kubectl get pods -n devops-tp` |
| 6 | Dashboard Grafana avec métriques |
