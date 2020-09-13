variable "AWS_REGION" {
  default = "us-east-1"
}

variable "AMI_UBUNTU" {
  type = map

  default = {
    us-east-1 = "ami-046842448f9e74e7d"
    us-east-2 = "ami-0367b500fdcac0edc"
    us-west-1 = "ami-0d58800f291760030"
    us-west-2 = "ami-0edf3b95e26a682df"
  }
}

variable "AMI_REDHAT" {
  type = map

  default = {
    us-east-1 = "ami-098f16afa9edf40be"
    us-east-2 = "ami-0a54aef4ef3b5f881"
    us-west-1 = "ami-066df92ac6f03efca"
    us-west-2 = "ami-02f147dfb8be58a10"
  }
}
