# Split-MonoRepo
Powershell script to split a git monolithic repository into smaller repositories

This program runs commands:
    * use the "git subtree" command to isolate each solution into a branch
    * create a new local repository from the branches created above
    * remotely create a VSTS repository
    * push the new repo to VSTS

There are several prerequisites:
    * the "vsts" tool - https://docs.microsoft.com/en-us/cli/vsts/overview?view=vsts-cli-latest
    * bash
    * git, including the subtree module    
