pipeline {
    agent any

    environment {
        // ⚠️ Remplace par ton username Docker Hub
        DOCKER_IMAGE    = "rayenchemlali/devops-tp-app"
        DOCKER_TAG      = "${BUILD_NUMBER}"
        SONAR_PROJECT   = "devops-tp"
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        // ══════════════════════════════════════════
        // EXERCICE 1 : CI & Qualité du Code
        // ══════════════════════════════════════════

        stage('Checkout') {
            steps {
                checkout scm
                echo "✅ Code récupéré - Branch: ${GIT_BRANCH} - Commit: ${GIT_COMMIT[0..7]}"
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('app') {
                    sh 'npm ci'
                    echo "✅ Dépendances installées"
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir('app') {
                    sh 'npm test'
                }
            }
            post {
                always {
                    echo "📊 Tests terminés"
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=${SONAR_PROJECT} \
                          -Dsonar.sources=app \
                          -Dsonar.tests=app/test \
                          -Dsonar.javascript.lcov.reportPaths=app/coverage/lcov.info \
                          -Dsonar.exclusions=**/node_modules/**
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
            post {
                success { echo "✅ Quality Gate PASSED" }
                failure { echo "❌ Quality Gate FAILED - Pipeline arrêté" }
            }
        }

        // ══════════════════════════════════════════
        // EXERCICE 2 : CD - Artefact & Sécurité
        // ══════════════════════════════════════════

        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest ."
                echo "✅ Image construite : ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }

        stage('Trivy Scan') {
            steps {
                sh """
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      aquasec/trivy:latest image \
                      --exit-code 0 \
                      --severity HIGH,CRITICAL \
                      --format table \
                      --no-progress \
                      ${DOCKER_IMAGE}:${DOCKER_TAG}
                """
                echo "✅ Scan Trivy terminé"
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo \${DOCKER_PASS} | docker login -u \${DOCKER_USER} --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout
                    """
                }
                echo "✅ Image publiée : ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }

        // ══════════════════════════════════════════
        // EXERCICE 3 : IaC & Déploiement
        // ══════════════════════════════════════════

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    echo "✅ Terraform initialisé"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                    echo "✅ Infrastructure provisionnée"
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                sh """
                    ansible-playbook ansible/deploy.yml \
                      -i ansible/inventory.ini \
                      --extra-vars "image_tag=${DOCKER_TAG} docker_image=${DOCKER_IMAGE}" \
                      -v
                """
                echo "✅ Déploiement Ansible terminé"
            }
        }

        stage('Smoke Test') {
            steps {
                sh """
                    echo "⏳ Attente démarrage des pods..."
                    sleep 20

                    APP_URL=\$(minikube service devops-tp-service -n devops-tp --url 2>/dev/null || echo "http://localhost:3000")
                    echo "🔍 Test de l'URL : \${APP_URL}"

                    HTTP_CODE=\$(curl -s -o /dev/null -w "%{http_code}" \${APP_URL}/health)
                    if [ "\${HTTP_CODE}" = "200" ]; then
                        echo "✅ Smoke Test RÉUSSI - App accessible (HTTP \${HTTP_CODE})"
                    else
                        echo "❌ Smoke Test ÉCHOUÉ - HTTP \${HTTP_CODE}"
                        exit 1
                    fi
                """
            }
        }
    }

    post {
        success {
            echo """
            ╔══════════════════════════════════════════╗
            ║  🎉 PIPELINE RÉUSSI - Build #${BUILD_NUMBER}  ║
            ║  Image : ${DOCKER_IMAGE}:${DOCKER_TAG}
            ╚══════════════════════════════════════════╝
            """
        }
        failure {
            echo "❌ Pipeline échoué au build #${BUILD_NUMBER} - Consulter les logs"
        }
        always {
            sh 'docker image prune -f || true'
        }
    }
}
