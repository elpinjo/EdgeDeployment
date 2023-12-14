pipeline {
	agent {
		kubernetes {
    	label 'docker-builder'
    	defaultContainer 'jnlp'
    	yaml """
kind: Pod
spec:
  serviceAccountName: jenkins-agent-account
  containers:
  - name: jnlp
    workingDir: /tmp/jenkins
  - name: dind
    workingDir: /tmp/jenkins
    image: portainer/kube-tools
    imagePullPolicy: Always
    restartPolicy: Never
    command: 
    - /bin/cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
    - name: jenkins-docker-cfg
      mountPath: /root/.docker
    securityContext:
      privileged: true
  volumes:
  - name: docker-sock
    hostPath:
      path: "/var/run/docker.sock"
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: swagregcred
          items:
            - key: .dockerconfigjson
              path: config.json 
"""
		}
	}

		
	parameters{
		credentials(credentialType: 'com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl', 
			defaultValue: '', description: 'GitHub credentials ', name: 'GITHUB_CREDENTIALS', required: true)
		credentials(credentialType: 'org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl', 
			defaultValue: '', description: 'WPM Securiy Token', name: 'WPM_CREDENTIALS', required: true)
		string(name: 'REGISTRY', defaultValue: 'registry.localhost', description: 'Endpoint of the docker registry')
		string(name: 'HOST', defaultValue: 'edge.localhost', description: 'Base hostname of your cloud machine for the ingress')
        string(name: 'EDGE_VERSION', defaultValue: '10.16.5', description: 'Base version for the build')
	}

	environment {
		PACKAGE = "*"
		NAMESPACE = "edge-deployment"
		REGISTRY_INGRESS = "http://${params.REGISTRY}"
		CONTAINER = "demo-edge-runtime"
		CONTAINER_TAG = "1.0.${env.BUILD_NUMBER}"
		EDGE_VERSION = "${params.EDGE_VERSION}"
		GITHUB_CREDS = credentials('GITHUB_CREDENTIALS')
		WPM_CRED = credentials('WPM_CREDENTIALS')
    }

    stages {

		stage('Prepare'){
            steps {
				dir("${PACKAGE}") {
					sh 'mkdir build \
						build/repo \
						build/container \
						dist \
						build/test \
						build/test/reports'
					sh 'chmod -R go+w build/test' 
					sh 'cd build/container; \
					    cp -r ${WORKSPACE}/Dockerfile .; \
						cp -r ${WORKSPACE}/wpm .; \
					    mkdir ./packages;'
				}
			}
		}

        stage('Build'){
            steps {
				container(name: 'dind', shell: '/bin/sh') {
					sh '''#!/bin/sh
            			cd ${PACKAGE}
            		'''
					script {
						docker.withRegistry("${REGISTRY_INGRESS}") {
					
							def customImage = docker.build("${CONTAINER}:${CONTAINER_TAG}", "${PACKAGE}/build/container --no-cache --build-arg EDGE_VERSION=${EDGE_VERSION} --build-arg WPM_CRED=${WPM_CRED} --build-arg GITHUB_CREDS_USR=${GITHUB_CREDS_USR} --build-arg GITHUB_CREDS_PSW=${GITHUB_CREDS_PSW}")

							/* Push the container to the custom Registry */
							customImage.push()
						}
					}
				}
			}
		}
		
		stage('Deploy-Container'){
            steps {
				container(name: 'dind', shell: '/bin/sh') {
					withKubeConfig([credentialsId: 'jenkins-agent-account', serverUrl: 'https://kubernetes.default']) {
						sh '''#!/bin/sh
						cat deployment/api-DC.yml | sed --expression='s/${CONTAINER}/'$CONTAINER'/g' | sed --expression='s/${REGISTRY}/'$REGISTRY'/g' | sed --expression='s/${CONTAINER_TAG}/'$CONTAINER_TAG'/g' | sed --expression='s/${NAMESPACE}/'$NAMESPACE'/g' | kubectl apply -f -'''
						script {
							try {
								sh 'kubectl -n ${NAMESPACE} get service ${CONTAINER}-service'
							} catch (exc) {
								echo 'Service does not exist yet'
								sh '''cat deployment/service-route.yml | sed --expression='s/${HOST}/'$HOST'/g' | sed --expression='s/${CONTAINER}/'$CONTAINER'/g' | sed --expression='s/${NAMESPACE}/'$NAMESPACE'/g' | kubectl apply -f -'''
							}
						}
					}
				}
            }
		}
    }
}
