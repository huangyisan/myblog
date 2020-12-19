pipeline {
    agent {
        label 'master'
    }

    stages {
        stage('Fetch hexo branch') {
            environment {
                NVM_DIR = "/var/lib/jenkins/.nvm"
            }
            steps {
                dir('hexo-branch') {
                    git branch: 'hexo', credentialsId: '0cc091e1-b69f-4e1d-b8c6-b7a9df25e438', url: 'https://github.com/huangyisan/myblog.git'
                }
                
            }
        }
        stage('Build hexo') {
            steps {
                dir('hexo-branch') {
                    sh '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && npm install && hexo clean && hexo g'
                }
            }
        }
        
        
        stage('Fetch master branch') {
            steps{
                dir('master-branch') {
                    git branch: 'master', credentialsId: '0cc091e1-b69f-4e1d-b8c6-b7a9df25e438', url: 'https://github.com/huangyisan/myblog.git'
                }
            }
        }
        
        stage('cp master .git to hexo-branch/public'){
            steps{
                dir('master-branch') {
                    sh 'cp -a ./.git ../hexo-branch/public'
                }
            }
        }
        
        stage('set git user info') {
            steps {
                dir('hexo-branch') {
                    sh 'cd ./public && git config user.name  "huangyisan" && git config user.email "anonymousyisan@gmail.com"' 
                }
            }
        }
        stage ('git add && commit') {

            steps {
                dir('hexo-branch') {
                    sh 'cd ./public && git add . && git commit -m "Jenkins CI Auto Builder at `date +"%Y-%m-%d %H:%M"`" '
                }
            }
        }
        stage ('Push public to Master branch') {
            environment {
                GH_REF="github.com/huangyisan/myblog.git"
            }
            steps {
                dir('hexo-branch') {
                    withCredentials([string(credentialsId: 'e5d2d117-b5ab-4dc5-9e07-a5e96bfb6e31', variable: 'TOKEN')]) {
                        sh 'cd public && git push --force --quiet "https://${TOKEN}@${GH_REF}" master:master'
                    }
                }
            }

        }
    }

}