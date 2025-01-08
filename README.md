# Envoy
The envoy configuration introduces separate functionality (e.g., application-layer logic and traffic management), modularizing it improves code reusability and separation of concerns.


---

## Project Structure

- **`main.tf`**: Main configuration file.

- **`envoy-config.yaml`**: Envoy proxy configuration.

- **`envoy-module.tf`**: Manages Envoy and AWS resources.

- **`outputs.tf`**: Outputs for the Terraform module.

- **`README.md`**: Documentation.

---


## Create a New Module


Create a standalone module for Envoy:


1. Create a New Directory:


Define Envoy Resources: In main.tf:





### Module for Envoy configuration

2. Envoy proxy configuration : envoy-config.yaml: 

    

---

3. Manages Envoy and AWS resources: envoy-module.tf:

    



4. Output the Configuration: In outputs.tf:


 




5. Call the Module: Reference this module in your existing deployment:


   


6. Add Envoy to the Deployment Pipeline: 

Update your CI/CD pipeline to include the deployment of Envoy's configuration.

---

## Recommendation

Given the complexity of Envoy and the scope of the aws-privatelink file, 

it's best to create a separate module to ensure clean and maintainable code. 

Then, link it to the existing infrastructure using Terraform outputs and inputs.

---




## Prerequisites

- AWS account and IAM permissions.
- Terraform CLI installed.
- Git access to Disney's Terraform module repository.

---

## Steps to Deploy

1. Initialize Terraform:

--terraform init

2. Plan the deployment:

--terraform plan

3. Apply the configuration:

--terraform apply

---

## Outputs

