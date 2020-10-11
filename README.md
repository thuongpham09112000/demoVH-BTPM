# AWS-Trraform-Ansible-Automation-Lab

AWS based lab designed to be automatically deployed using Terraform. All hosts inside of the lab are initially configured with CloudInit scripts and later on managed by Ansible. I am usually using this lab for acloudguru.com AWS classes. It can be quickly deployed, modified to fulfill class requirements and torn down after class. Access to the lab is possible via management host placed in one of public subnets. This is also the host that configures other VMs via ansible.  

### Lab diagram
![AWS lab diagram](https://github.com/ccie18643/AWS-Terraform-Ansible-Automation-Lab/blob/master/pictures/diag01.png)


