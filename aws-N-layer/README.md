# AWS install 3-Layer Architecture with Terraform

![do not forget to update pic when update the scheme file](res/scheme.png "initial scheme") <br>

### Create AWS access keys (manually)

1. IAM -> User groups -> create group "testgroup" with policies
    * AmazonEC2FullAccess - temporary
2. IAM -> Users -> create user "testuser"
    * not 'Provide user access to the AWS Management Console'
    * add to just created "testgroup"
3. open new user page -> `Create access key` -> Command Line Interface (CLI)
4. prepare aws CLI config
    * chmod 600 aws/*
    * `cp ./aws/* ~/.aws/`
    * edit (access key ID, secret access key, region, output format)


### Prepare AWS CLI (on debian)

open AWS web console and create access keys

```
git clone <this repo>
cd IaC/aws-N-layer                          # enter working directory
---
python3 -m venv venv                        # # # create Python virtual env (only on first launch)
. venv/bin/activate                         # enter to the python virtual env
python3 -m pip install --upgrade pip        # # # upgrade pip (only on first launch)
pip install -r requirements.txt             # # # install project requirements (only on first launch)
```

configure AWS CLI with `aws configure` using your access keys


### Download and install Terraform via APT Package manager (official ppa repo)
```
# install dependencies
sudo apt update
sudo apt install gnupg software-properties-common

# download (wget) and install (gpg --dearmor | tee) HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# Verify the GPG key fingerprint
gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

# Add the official HashiCorp repository to your system
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# finally Install Terraform from the new PPA repository
sudo apt update
sudo apt install terraform
```

### Apply terraform file for main goal

```
terraform init                              # only once
terraform plan
terraform apply
```

