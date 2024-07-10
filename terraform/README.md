# Terraform

## Setup

```
terraform -chdir="./terraform" init
terraform -chdir="./terraform" workspace new dev
```

## Dev

```
# select workspace
terraform -chdir="./terraform" workspace select dev

# plan
terraform -chdir="./terraform" plan

# apply !!
terraform -chdir="./terraform" apply

# destroy !!!!!
terraform -chdir="./terraform" destroy
```
