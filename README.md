# terraform-aws-gitea
This terraform template creates AWS infrastructure for the Gitea source control service.

1) The template uses remote-state-backend, so you have to initialize the s3 bucket first - just run `./terraform-init.sh`
2) Then apply terraform as usual - `terraform apply`
3) Finally, navigate to you created gitea server (see terraform output for for dns name), port 3000. Or ssh to server - `./connect.sh`
