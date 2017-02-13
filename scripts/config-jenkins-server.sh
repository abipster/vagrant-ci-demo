# CONSTANTS
PROVISION_STATE_FILE="/tmp/provision.dat"

output=/tmp/provison.log
echo "Provisioning at $(date)" > $output 

function getGDriveFile {
    sharedURL=$1
    ggID=$(echo $sharedURL | egrep -o '(\w|-){26,}')
    ggURL='https://drive.google.com/uc?export=download'
    filename="$(curl -sc /tmp/gcokie "${ggURL}&id=${ggID}" | grep -o '="uc-name.*</span>' | sed 's/.*">//;s/<.a> .*//')"
    getcode="$(awk '/_warning_/ {print $NF}' /tmp/gcokie)"
    curl -Lb /tmp/gcokie "${ggURL}&confirm=${getcode}&id=${ggID}" -o "${filename}" &>> $output
}


if [ ! -f $PROVISION_STATE_FILE ];
then
    #if we don't have a file, start at zero
    value=0
else
    # otherwise read the value from the file
    value=`cat $PROVISION_STATE_FILE`
fi

# Only installs software on the first provision
if [ ${value} -eq 0 ] 
then
    # install and configure httpd service
    sudo yum clean all
    sudo yum -y update &>> $output
    
    # disable firewall
    sudo systemctl stop firewalld 
    sudo systemctl disable firewalld 
    
    # Install Java 
    sudo yum install -y java-1.8.0-openjdk-devel &>> $output
    sudo cp /etc/profile /etc/profile_backup
    echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk' | sudo tee -a /etc/profile
    echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
    source /etc/profile

    # Install utils
    sudo yum install -y wget git yum-utils &>> $output

    # Install Jenkins
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo &>> $output
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    sudo yum install -y jenkins &>> $output

    # Make sure Jenkins is stoped and configure it
    sudo systemctl stop jenkins.service
    getGDriveFile "https://drive.google.com/open?id=0Bwz6-3PXQynlakRFcHBwSlNOXzA"
    sudo tar -xzf $filename -C /
    sudo chown -R jenkins:jenkins /var/lib/jenkins/*
    # small hack to pass misconfiguration in jenkins authentication 
    sudo sed -i 's/<useSecurity>true<\/useSecurity>/<useSecurity>false<\/useSecurity>/g' /var/lib/jenkins/config.xml

    # Start the Jenkins service and set it to run at boot time
    sudo systemctl start jenkins.service
    sudo systemctl enable jenkins.service

    # Install Artifactory
    sudo wget https://bintray.com/jfrog/artifactory-rpms/rpm -O bintray-jfrog-artifactory-rpms.repo &>> $output
    sudo mv bintray-jfrog-artifactory-rpms.repo /etc/yum.repos.d/
    sudo yum install -y jfrog-artifactory-oss &>> $output

    # Start the Artifactory service and set it to run at boot time
    sudo systemctl start artifactory.service
    sudo systemctl enable artifactory.service

fi

# - To check if Jenkins started correctly go to http://<file_server_ip>:8080 (all should be configured but if it isn't check the next steps)
# - The first time Jenkins will be locked, to unlock it enter the vagrant vm, type following command and copy and paste the file contents in the webbrowser: 
#       sudo less /var/lib/jenkins/secrets/initialAdminPassword
# - Install the recommended plugins for jenkins
# - Extra plugins to install
#       Blue Ocean beta
#       Maven Release Plug-in
#
# - TO check if Jenkins started correctly go to http://<file_server_ip>:8081/artifactory and follow the wizard, you just need the maven repo



# increment the value
value=`expr ${value} + 1`

# and save it for next time
echo "${value}" > $PROVISION_STATE_FILE