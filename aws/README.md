AWS Setup
---------

1. Make sure you have set up your system according to instructions in the [project README](../README.md). 
2. Put your AWS credentials into environment variables.
   * There are various methods to this from authorization keys to SSO login.
   * Describing each method is outside the scope of this project.
3. Copy `secret.tfvars.example` to `secret.tfvars` and modify the values according to your environment
4. Run `terraform apply -var-file sectret.tfvars` and approve by typing "yes"
   * Always make sure to review your changes to ensure this is what you want.
   * This is easiest if you run this from a full-admin account. Otherwise have fun chasing down and setting all the 
     required permissions to add to your role/user. 
5. Go up a directory level (`cd ..`) and run `./deploy-image.sh`. 
   * Take note of the tag for the next step
6. Enter this directory again (`cd aws`) and run `terraform apply -var-file sectret.tfvars -var "image_tag={tag from deploy}"`
   * You can use TF_VARS_name=value environment variables instead of setting `-var-file` and `-var` if you so fancy.

If you would like to access your new Kubernetes cluster from you local machine, add the connection details to your config
with this command:

```
aws eks update-kubeconfig --region "$AWS_REGION"  --name k8s-demo
```

You can now easily access, inspect, and modify the contents of the cluster via a tool of your choosing. Terraform will 
complain if you modify any tracked resources and will attempt to restore them to the values in the code upon subsequent 
applies. 
