pipeline {
    agent any

    environment {
        EC2_USER = 'ubuntu'
        EC2_IP = '65.1.8.69'
        REMOTE_DIR = '/home/ubuntu/app'
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
                        Write-Host "Copying jar to EC2..."

                        # Use your actual built JAR name
                        $JAR_PATH = "build/libs/test_ci-0.0.1-SNAPSHOT.jar"
                        $key = $env:KEYFILE.Replace('\\', '/')

                        if (-Not (Test-Path $JAR_PATH)) {
                            Write-Error "❌ JAR file not found at $JAR_PATH"
                            exit 1
                        }

                        # Copy jar to EC2
                        scp -o StrictHostKeyChecking=no -o "StrictModes=no" -i "$key" "$JAR_PATH" ubuntu@65.1.8.69:/home/ubuntu/app/app.jar

                        Write-Host "Restarting app remotely..."
                        ssh -o StrictHostKeyChecking=no -o "StrictModes=no" -i "$key" ubuntu@65.1.8.69 "pkill -f app.jar || true && nohup java -jar /home/ubuntu/app/app.jar > /home/ubuntu/app/app.log 2>&1 &"

                        Write-Host "✅ Deployment completed successfully."
                    '''
                }
            }
        }
    }
}
