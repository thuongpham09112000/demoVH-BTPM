# AWS Terraform Ansible Automation Lab

### Simple AWS lab
<br>

AWS-based lab designed to be automatically deployed using Terraform. All hosts inside of the lab are initially configured with CloudInit scripts and later on managed by Ansible. I am usually using this lab for acloudguru.com AWS classes. It can be quickly deployed, modified to fulfill class requirements, and torn down after class. Access to the lab is possible via a management host placed in one of the public subnets. This is also the host that configures other VMs via Ansible. The project contains private key that is solely used for the Ansible automation inside of this lab, so please do not raise any security concerns over this fact :)

### Lab diagram
![AWS lab diagram](https://github.com/ccie18643/AWS-Terraform-Ansible-Automation-Lab/blob/master/pictures/diag01.png)


