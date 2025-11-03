pipeline {
    agent any

    environment {
        EC2_USER = 'ubuntu'
        EC2_IP = '65.1.8.69'
        KEY_PATH = 'D:/keys/jenkins-aws.ppk'
        APP_NAME = 'myapp.jar'
        REMOTE_DIR = '/home/ubuntu/app'
    }

    stages {
        stage('Build') {
            steps {
                // Build your app locally
                sh './gradlew clean build -x test'
            }
        }

        stage('Deploy') {
            steps {
                // Copy artifact to EC2
                sh "scp -i ${KEY_PATH} build/libs/${APP_NAME} ${EC2_USER}@${EC2_IP}:${REMOTE_DIR}/"

                // Restart app on EC2
                sh """
                   ssh -i ${KEY_PATH} ${EC2_USER}@${EC2_IP} << EOF
                   pkill -f ${APP_NAME} || true
                   nohup java -jar ${REMOTE_DIR}/${APP_NAME} > ${REMOTE_DIR}/app.log 2>&1 &
                   EOF
                """
            }
        }
    }
}
