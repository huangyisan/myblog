pipeline {
    agent {
        label 'master'
    }

    stages {
        stage('Parellel get repo') {
            parallel {
                stage('Fetch hexo barnch') {
                    environment {
                        NVM_DIR = "/var/lib/jenkins/.nvm"
                    }
                    steps {
                        dir('hexo-branch') {
                            git branch: 'hexo', credentialsId: '0cc091e1-b69f-4e1d-b8c6-b7a9df25e438', url: 'https://github.com/huangyisan/myblog.git'
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
            }
        }
        
        stage('Build hexo') {
            steps {
                dir('hexo-branch') {
                    sh '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && npm install && hexo clean && hexo g'
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
    post {
        always {
            dir('hexo-branch') {
                script {
                    def COMMIT_ID = ""
                    COMMIT_ID = sh(returnStdout: true, script:'git log --pretty=format:"%h" -1')
                    
                    def mimeType = 'text/html'

                    def to = 'anonymousyisan@gmail.com'

                    def subject = '【构建通知】$PROJECT_NAME - $COMMIT_ID - Build # $BUILD_NUMBER - $BUILD_STATUS!'

                    def body = 
                    '''
<html>

<head>
    <meta charset="UTF-8">
    <title>${ENV, var="JOB_NAME"}-第${BUILD_NUMBER}次构建日志</title>
</head>

<body leftmargin="8" marginwidth="0" topmargin="8" marginheight="4" offset="0">
    <table width="95%" cellpadding="0" cellspacing="0"
        style="font-size: 11pt; font-family: Tahoma, Arial, Helvetica, sans-serif">
        <tr>
            <div>
                <p>本邮件由系统自动发出，无需回复</p>
                <p>小主，您好！以下为${PROJECT_NAME}项目构建信息</p>
                <p>
                    <font color="#CC0000">构建结果 - ${BUILD_STATUS}</font>
                </p>
            </div>
        </tr>
        <tr>
            <td><br />
                <b>
                    <font color="#0B610B">构建信息</font>
                </b>
                <hr size="2" width="100%" align="center" />
            </td>
        </tr>
        <tr>
            <td>
                <ul>
                    <li>项目名称 ： ${PROJECT_NAME}</li>
                    <li>构建编号 ： 第${BUILD_NUMBER}次构建</li>
                    <li>触发原因： ${CAUSE}</li>
                    <li>构建状态： ${BUILD_STATUS}</li>
                    <li>构建日志： <a href="${BUILD_URL}console">${BUILD_URL}console</a></li>
                    <li>构建 Url ： <a href="${BUILD_URL}">${BUILD_URL}</a></li>
                    <li>工作目录 ： <a href="${PROJECT_URL}ws">${PROJECT_URL}ws</a></li>
                    <li>项目 Url ： <a href="${PROJECT_URL}">${PROJECT_URL}</a></li>
                </ul>
                <h4>
                    <font color="#0B610B">失败用例</font>
                </h4>
                <hr size="2" width="100%" />
                $FAILED_TESTS<br />

                <hr size="2" width="100%" />
                <ul>
                    ${CHANGES_SINCE_LAST_SUCCESS, reverse=true, format="%c", changesFormat="<li>%d [%a] %m</li>"}
                </ul>
                <p>详细提交: <a href="${PROJECT_URL}changes">${PROJECT_URL}changes</a></p>
            </td>
        </tr>
    </table>
</body>

</html>
                    '''

                emailext(
                    to: to,
                    subject: subject,
                    mimeType: mimeType,
                    body: body
                )
                }
            }
        }
    }
}