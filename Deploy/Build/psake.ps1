param([string]$ReleaseNumber)


function ExitWithCode([string]$exitCode)
{
	$host.SetShouldExit($exitcode)
	exit 
}

Try 
{
	Set-ExecutionPolicy RemoteSigned
	Import-Module .\psake\psake.psm1
	Invoke-Psake -framework 4.0 .\build.ps1 -parameters @{ReleaseNumber=$ReleaseNumber;} 
	ExitWithCode($LastExitCode)
}
Catch 
{
	Write-Error $_
	Write-Host "GO.PS1 EXITS WITH ERROR"
	ExitWithCode 9
}