pipeline {
    agent any

    environment {
        EC2_USER = 'ubuntu'
        EC2_IP = '65.1.8.69'
        APP_NAME = 'myapp.jar'
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
                        $key = $env:KEYFILE.Replace('\\', '/')
                        scp -o StrictHostKeyChecking=no -i "$key" build/libs/myapp.jar ubuntu@65.1.8.69:/home/ubuntu/app/

                        Write-Host "Restarting app remotely..."
                        ssh -o StrictHostKeyChecking=no -i "$key" ubuntu@65.1.8.69 "pkill -f myapp.jar || true && nohup java -jar /home/ubuntu/app/myapp.jar > /home/ubuntu/app/app.log 2>&1 &"
                    '''
                }
            }
        }
    }
}
