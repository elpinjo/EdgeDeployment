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
  - name: kaniko
    workingDir: /tmp/jenkins
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    restartPolicy: Never
    command: 
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: jenkins-docker-cfg
      mountPath: /kaniko/.docker
    - name: tmp-dir
      mountPath: /wm-installer
  volumes:
  - name: tmp-dir
    hostPath:
      path: "/tmp/license"
  - name: jenkins-docker-cfg
    projected:
      sources:
      - secret:
          name: docker-credentials 
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
		string(name: 'REGISTRY', defaultValue: 'registry.k8s', description: 'Endpoint of the docker registry')
		string(name: 'HOST', defaultValue: 'edge.localhost', description: 'Hostname of your cloud machine for the ingress')
        string(name: 'EDGE_VERSION', defaultValue: '11.0', description: 'Base version for the build')
	}

	environment {
		PACKAGE = "*"
		NAMESPACE = "edge-deployment"
		REGISTRY_INGRESS = "https://${params.REGISTRY}"
		REGISTRY = "${params.REGISTRY}"
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

    stage('Build') {
		  steps {
			  container(name: 'kaniko', shell: '/busybox/sh') {
				  sh '''#!/busybox/sh
				  /kaniko/executor --context . \
				    --skip-tls-verify \
					  --destination ${REGISTRY}/${CONTAINER}:${CONTAINER_TAG} \
		  			--build-arg EDGE_VERSION=${EDGE_VERSION} \
		  			--build-arg WPM_CRED=${WPM_CRED} \
		  			--build-arg GITHUB_CREDS_USR=${GITHUB_CREDS_USR} \
		  			--build-arg GITHUB_CREDS_PSW=${GITHUB_CREDS_PSW}
				  '''
			  }
		  }
		}
		
		stage('Deploy-Container'){
      steps {
				container(name: 'kaniko', shell: '/bin/sh') {
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
