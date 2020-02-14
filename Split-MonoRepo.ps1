[CmdletBinding()]
param (
    [string]$SourceRepo = $(throw "-SourceRepo is required."),
    [string]$Destination = $(throw "-Destination is required."),
    [string]$AzureDevOpsInstance = $(throw "-AzureDevOpsInstance is required"),
    [string]$AzureDevOpsProject = $(throw "-AzureDevOpsProject is required"),
    [System.Collections.ArrayList]$ExcludedDirs = @("")
)

Set-StrictMode -Version 3.0

if (-Not (Test-Path $SourceRepo)) {
    throw "Source directory {$SourceRepo} does not exist"
}

if (-Not (Test-Path $SourceRepo/.git)) {
    throw "Source directory {$SourceRepo} does not appear to be a git repository"
}

if (-Not (Test-Path $Destination)) {
    try {
        New-Item -ItemType "Directory" $Destination
    }
    catch {
        "Destination directory {$Destination} does not exist, and we couldn't create it"
        throw
    }
}

$charsToRemove = @( " ", "?", "~", "^", ":", "*", "[", "]", "@", "@{")
$monoRepoDirs = [System.Collections.ArrayList](Get-ChildItem -Path $SourceRepo -Directory | Select-Object -Property Name )
$manyRepoDir = $Destination

$monoRepoDirs.Remove($ExcludedDirs)

Push-Location $SourceRepo
foreach ($dir in $monoRepoDirs) {
    #tidy up the directory strings
    $dir = $dir.Name.Replace($charsToRemove, "")
    $newDir = "$manyRepoDir/$dir"
    write-output "****$dir****"

    #code gets branched off the current branch into its own branch
    #this new branch contains only code for the current subdir, current branch
    $newBranchName = "$dir-only"
    git subtree split -P $dir -b $newBranchName

    #create new directory and switch to it
    New-Item -ItemType "Directory" $newDir
    Push-Location $newDir

    #init new git repo
    git init
    #add remote to the monorepo
    git remote add mono $SourceRepo
    #pull in new branch from above
    git pull mono $newBranchName
    #get the new repo ready to go
    Copy-Item  $SourceRepo/.gitignore .
    git add .
    git commit -m '***repo split.  Add .gitignore!'

    #Create the Azure DevOps resources
    az repos create --project $AzureDevOpsProject --organization "$AzureDevOpsInstance" --name $dir
    #add remote to the repo you just created...
    git remote add origin $AzureDevOpsInstance/DefaultCollection/$AzureDevOpsProject/_git/$dir/
    #push changes up to the remote
    git push origin -u master

    #pop back up to the $SourceRepo dir
    Pop-Location
}