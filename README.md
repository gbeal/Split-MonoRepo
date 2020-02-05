# Split-MonoRepo
Powershell script to split a git monolithic repository into smaller repositories

This program runs commands:
    * use the "git subtree" command to isolate each solution into a branch
    * create a new local repository from the branches created above
    * remotely create an Azure DevOps repository
    * push the new repo to Azure DevOps

There are several prerequisites:
    * the Azure DevOps extentions to the Azure CLI - https://github.com/Azure/azure-devops-cli-extension
    * Powershell
    * git, including the subtree module    
