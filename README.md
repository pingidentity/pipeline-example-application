# Ping Application Example Pipeline

This repository is intended to present a simplified reference demonstrating how a management and deployment pipeline might work for applications that depend on services managed by a central IAM platform team. As such, it is a complement to the [infrastructure](https://github.com/pingidentity/pipeline-example-infrastructure) and [platform](https://github.com/pingidentity/pipeline-example-platform) example pipeline repositories.

> NOTE: This repository directly depends on a completed setup of the [pipeline-example-platform](https://github.com/pingidentity/pipeline-example-platform?tab=readme-ov-file#deploy-prod-and-qa). Please ensure you have completed the steps for configuration leading up to and including the previous link, where a `prod` and `qa` environment have been deployed.

**Infrastructure** - Components dealing with deploying software onto self-managed Kubernetes infrastructure and any configuration that must be delivered directly via the filesystem.

**Platform** - Components dealing with deploying configuration to self-managed or hosted services that will be shared and leveraged by upstream applications.

**Application** - Delivery and configuration of a client application that relies on core services from Platform and Infrastructure.

The use cases and features shown in this repository are an implementation of the guidance provided from Ping Identity's [Terraform Best Practices](https://terraform.pingidentity.com/best-practices/) and [Getting Started with Configuration Promotion at Ping](https://terraform.pingidentity.com/getting-started/configuration-promotion/) documents.

In this repository, the processes and features shown in a GitOps process of developing and delivering a new application include:

- Feature Request Template
- Feature Development in an on-demand or persistent development environment
- Extracting feature configuration to be stored as code
- Validating the extracted configuration from the developer perspective
- Validating that the suggested configuration adheres to contribution guidelines
- Review process of suggested change
- Approval of change and automatic deployment into higher environments

## Prerequisites

To be successful in recreating the use cases supported by this pipeline, there are initial steps that should be completed prior to configuring this repository:

- Completion of all pre-requisites and configuration steps leading to [Feature Development](https://github.com/pingidentity/pipeline-example-platform?tab=readme-ov-file#feature-development) from the example-pipeline-platform repository
- [Docker](https://docs.docker.com/engine/install/) - used to deploy the UI for a sample interface
- [tflint](https://github.com/terraform-linters/tflint) - for Terraform linting
- [dvlint](https://github.com/pingidentity/dvlint) - for Davinci flow linting
- [trivy](https://github.com/aquasecurity/trivy) - for security scanning

> Note - The last three tools are used by the pipeline in Github, and the pipeline will fail if these tests and configuration checks are not passed. It is recommended to install these tools locally to ensure that the pipeline will pass when changes are pushed.

<!-- TODO - Review Required Permissions-->
> Note - For PingOne, meeting these requirements means you should have credentials for a worker app residing in the "Administrators" environment that has organization-level scoped roles. For DaVinci, you should have credentials for a user in a non-"Administrators" environment that is part of a group specifically intended to be used by command-line tools or APIs with environment-level scoped roles.

### Development Environment

If you have not created a static development environment in your PingOne account, you can do so in the local copy of the *pipeline-example-platform* repository by running the following commands to instantiate one matching prod and qa:

```bash
git checkout prod
git pull origin prod
git checkout -b dev
git push origin dev
```

Capture the environment ID for the development environment for use later.

> Note - In many cases, the platform team will provide each developer with a unique development environment. For purposes of this guide, we will assume that the development environment is shared and will be used by multiple developers.

![PingOne Environments](./img/pingOneEnvs.png "PingOne Environments")

### Repository Setup

Click the **Use this template** button at the top right of this page to create your own repository.  After the repository is created, clone it to your local machine to continue.  The rest of this guide will assume you are working from the root of the cloned repository.

> Note - A pipeline will run and fail when the repository is created. This result is expected as the pipeline is attempting to deploy the application and the necessary configuration has not yet been completed.

## Development Lifecycle Diagram

The use cases in this repository follow a flow similar to this diagram:

![SDLC flow](./img/generic-pipeline.png "Development Flow")

## Before You Start

There are a few items to configure before you can successfully use this repository.

### PingOne Environments

> Note - The configurations in this sample repository rely on environments created from [pipeline-example-platform](https://github.com/pingidentity/pipeline-example-platform). For the `PINGONE_TARGET_ENVIRONMENT_ID_PROD` and `PINGONE_TARGET_ENVIRONMENT_ID_QA` variables needed down below, get the Environment ID for the `prod` and `qa` environments. The Environment ID can be found from the output at the end of a terraform apply (whether from the Github Actions pipeline, or local) or directly from the PingOne console.

### Github CLI

The Github cli: `gh` will need to be configured for your repository. Run the command **gh auth login** and follow the prompts.  You will need an access token for your Github account and the repository created from this template:

```bash
gh auth login

? What account do you want to log into? GitHub.com
? You're already logged into github.com. Do you want to re-authenticate? Yes
? What is your preferred protocol for Git operations? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Paste an authentication token
Tip: you can generate a Personal Access Token here https://github.com/settings/tokens
The minimum required scopes are 'repo', 'read:org', 'workflow'.
? Paste your authentication token: ****************************************
- gh config set -h github.com git_protocol https
✓ Configured git protocol
✓ Logged in as <User>
```

### Github Actions Secrets

The Github pipeline actions depend on sourcing secrets as ephemeral environment variables. To prepare the secrets in the repository:

```bash
cp secretstemplate localsecrets
```

> Note - `secretstemplate` is a template file while `localsecrets` contains credentials. `localsecrets` is part of *.gitignore* and should never be committed into the repository. **`secretstemplate`** is committed to the repository, so ensure that you do not edit it directly or you risk exposing your secrets.

Fill in `localsecrets` accordingly, referring to the comments in the file for guidance. Many of the values needed for this file can be found in the corresponding localsecrets file from the platform repository.

After updating the file, run the following command to upload **localsecrets** to Github:

```bash
_secrets="$(base64 -i localsecrets)"
gh secret set --app actions TERRAFORM_ENV_BASE64 --body $_secrets
unset _secrets
```

> Note - On the Apple Mac platform, if you have installed the **base64** application using brew, there will be a file content failure in the pipeline stemming from the first command shown above.  Use the default version of base64 by specifying the path explicitly: `_secrets="$(/usr/bin/base64 -i localsecrets)"`

## Feature Development

Now that the repository and pipeline are configured, the typical git flow can be followed. You will follow steps similar to those documented in the [pipeline-example-platform "Feature Development"](https://github.com/pingidentity/pipeline-example-platform/tree/prod?tab=readme-ov-file#feature-development) section.

A notable difference between this repository and the platform example is that the application pipeline does NOT deploy to feature environments. Feature or development environment configuration deployment only takes place from the local machine. Unlike the IDs for QA and Prod, the development environment ID is not stored in the repository as an environment variable and is not found in the `secretstemplate` file. When the `./scripts/local_feature_deploy.sh` script runs, you will be prompted for the environment ID.  The reasoning behind operating with this flow is the consideration that there might be multiple development environments provided to application developers with no way of distinguishing them in the pipeline with a single variable. As a result, it creates the possibility that developers would change the variable and impact another engineer's work.  Therefore, the developer must provide the environment ID for development and initial testing from the local machine, but the pipeline will handle processing changes to QA and Prod, as those are common across teams and can be defined universally.

To experience the developer's perspective, a walkthrough follows. The demonstration will simulate the use case of modifying a Davinci flow and promoting the change. To simplify the demonstration, a starting pre-configured flow will be created using Terraform.  The UI components will be built into a Docker image and launched on your local machine. After you have deployed the flow, you will be able to make the changes necessary in the PingOne UI, export the configuration, and promote the change to the QA and Prod environments.

### Feature Development Walkthrough

1. To align with a typical developer experience, use the **Feature request** template in Github to create a GitHub Issue in the UI. GitHub Issue templates help ensure the requestor provides appropriate information on the issue. Provide a description and save the issue by clicking the "Submit New Issue" button.

![Create a new issue](./img/githubissuerequest.png "Create a new issue")

2. Select the issue and click "Create a branch" and choose "Checkout Locally" from the right-hand navigation menu.  This action will cause GitHub to create a development branch on your behalf.

![Create a branch](./img/createabranch.png "Create a branch")

3. Deploy the sample Davinci flow to the development environment by running the following commands. You will be prompted for the development environment ID:

```bash
source localsecrets
./scripts/local_feature_deploy.sh
```

> Note - If you want to see what Terraform will do without actually deploying, provide the `-g` or `--generate` flag to the script. This flag generates the Terraform configuration without applying it.

4. Confirm the deployment by examining the Davinci flow in the PingOne console in the development environment matching the ID you provided. Click on the Davinci link from the PingOne console to open the DaVinci console and select **Flows** from the left navigation panel. Click on the **PingOne DaVinci Registration Example** flow to view the configuration.

5. Try out the flow navigating to [https://127.0.0.1:8080](https://127.0.0.1:8080) to access the container launched from the image built by the script. You will be presented a simple form to enter an email address. Since the address is not stored, you will be prompted to register the user.

6. On the next panel, you are told to provide the email and password. There are password rules in place, but you are not informed when prompted. Try using a simple password such as `password`. The form does not indicate there is a problem, but refuses to accept the password and continue.  The password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character.  

7. Create a valid password. After registering the user, you will be redirected to login.

8. To improve the flow, you will add a small prompt on the registration page to indicate that the password must meet the requirements.  To do so, select the **Registration Window** node in the Davinci flow editor. Replace the text in the HTML Template editor with the following.  The only change in this block from what is provided is the addition of the password requirements notification and some descriptive comments.

```html
<form id="registerForm">
    <p>We did not locate that account. Sign up now!</p>

    <!-- Email Input Field -->
    <input type="text" id="email" placeholder="Email address" required />

    <!-- Password Input Field -->
    <input type="password" id="password" placeholder="password" required />

    <!-- Password Requirement Text -->
    <small id="passwordRequirements" style="display: block; margin-top: 0.5rem; color: #6c757d;">
        Password must be at least 8 characters and contain 1 uppercase, 1 lowercase, 1 digit, and 1 symbol
    </small>

    <!-- Submit Button -->
    <button class="btn" data-skcomponent="skbutton" data-skbuttontype="form-submit" data-skform="registerForm" data-skbuttonvalue="submit">Register</button>
</form>
```

9. Click **Apply** to save the changes, then click **Deploy** to update the flow in the development environment.

10. Try the flow again, and provide a new email address.  Notice on the registration page that you are presented the password requirements message.  There is no need to register the new user as you can see the change has been applied in the interface.

11. To capture the changes for inclusion in your code, export the flow. You can do so by selecting the three dots at the top right of the editor and clicking **Download Flow JSON**. Ensure to select **Include Variable Values** when you export.

![Export Menu](./img/pingOneEnvs.png "Export Menu")

12. For the sake of brevity, assume that testing has been done, and you are ready to proceed. After the application is "tested", the new configuration must be added to the Terraform configuration. This addition will happen in a few steps:

  a. Copy the contents of the downloaded JSON file and use them to replace the `terraform/davinci-flows/davinci-widget-reg-authn-flow.json` file contents. If you examine the changes, you will see that it involves the company ID, metadata about the file and the changes you made to the node in the flow.

  b. Run the deploy script again:

```bash
source localsecrets
./scripts/local_feature_deploy.sh 
```

  c. If you examine the output, you will see that the change to the JSON object caused Terraform to detect a delta between the state stored in S3 (with the old JSON code) and what is present in the new code:
  
```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # davinci_flow.registration_flow will be updated in-place
  ~ resource "davinci_flow" "registration_flow" {
      ~ flow_configuration_json = (sensitive value)
      ~ flow_export_json        = (sensitive value)
      ~ flow_json               = (sensitive value)
      id                      = "a6d551f1d7aa2612f2bf6c371b0026e1"
        name                    = "PingOne DaVinci Registration Example"
        # (4 unchanged attributes hidden)

        # (3 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

  d. Applying the change will update and 'redeploy' the flow (even though it is exactly the same as what is there, the update to the file creates a delta for Terraform to resolve) and afterward, the state will reflect the new configuration. Type `yes` to apply the changes.

  e. Run the script again to confirm that the state matches the configuration:

```bash
No changes. Your infrastructure matches the configuration.
Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are
needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

13. If you want to go one step further, you can modify the HTML code that is placed in the nginx image. To do so, you can modify `./terraform/sample-app/index.html` in some manner.  When the script is ran again, it will detect the change to the file, rebuild the Docker image, and launch a replacement container for the UI.

14. Before committing and pushing the changes, run a devcheck against the code to ensure the formatting and syntax are correct, ignoring any warnings or informational messages:

```bash
make devcheck
```

15. Commit and push the changes to the repository:

```bash
git add .
git commit -m "Adding password requirements to registration page"
git push
```

16. The push will fire a pipeline that runs the same checks as you did locally. As it running on a local development branch, no deployment will occur.

17. Create a pull request in the repository from your branch to `qa`.  The pipeline will run and validate the changes, then deploy the flow to the **qa** environment in your PingOne account.  You can confirm the flow exists and has your change.

18. Finally, you can create a pull request from `qa` to `prod`.  The pipeline will run and validate the changes, then deploy the flow to the **prod** environment in your PingOne account.

## Conclusion

This repository demonstrates a simplified example of how a pipeline can be used to manage the development and deployment of an application that relies on services managed by a central IAM platform team. The pipeline is designed to be flexible and extensible, allowing for the addition of new features and services as needed. By following the steps outlined in this repository, you can gain a better understanding of how to implement a similar pipeline in your own environment.
