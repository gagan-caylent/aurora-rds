<<<<<<< HEAD
terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = ">= 2.2"
    # }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "caylent-dev"
  #alias = "primary"
}

# provider "aws" {
#   region = "us-east-2"
#   profile = "caylent-dev"
#   alias = "secondary"
# }
=======
terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9.0"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = ">= 2.2"
    # }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "caylent-dev"
  alias = "primary"
}

provider "aws" {
  region = "us-east-2"
  profile = "caylent-dev"
  alias = "secondary"
}
>>>>>>> 4a4d456c414774fc62d2728072356b5d9451fba7
