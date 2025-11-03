pipeline {
    agent any

    environment {
        EC2_USER = 'ubuntu'
        EC2_IP = '65.1.8.69'
        REMOTE_DIR = '/home/ubuntu/app'
        LOCAL_JAR = 'build/libs/test_ci-0.0.1-SNAPSHOT.jar'
        REMOTE_JAR = 'app.jar'
    }

    stages {
        stage('Build') {
            steps {
                echo "Building application..."
                bat 'gradlew clean build -x test'
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying to EC2..."
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-deploy-key',
                        keyFileVariable: 'KEYFILE')]) {
                    powershell '''
                Write-Host "Copying JAR to EC2..."

                $key = $env:KEYFILE.Replace('\\', '/')
                $jarPath = "build/libs/test_ci-0.0.1-SNAPSHOT.jar"

                if (-Not (Test-Path $jarPath)) {
                    Write-Error "❌ JAR file not found: $jarPath"
                    exit 1
                }

                Write-Host "Fixing key permissions..."
                # Remove all permissions and grant only Jenkins service account (SYSTEM)
                icacls $key /inheritance:r /remove:g "BUILTIN\\Users" /T
                icacls $key /grant:r "SYSTEM:R" /T

                Write-Host "Copying file via SCP..."
                scp -o StrictHostKeyChecking=no -i "$key" "$jarPath" ${env:EC2_USER}@${env:EC2_IP}:${env:REMOTE_DIR}/${env:REMOTE_JAR}

                Write-Host "Restarting app remotely..."
                ssh -o StrictHostKeyChecking=no -i "$key" ${env:EC2_USER}@${env:EC2_IP} "pkill -f ${env:REMOTE_JAR} || true && nohup java -jar ${env:REMOTE_DIR}/${env:REMOTE_JAR} > ${env:REMOTE_DIR}/app.log 2>&1 &"

                Write-Host "✅ Deployment completed successfully."
            '''
                }
            }
        }

    }
}
