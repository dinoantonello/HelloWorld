properties {
    $BaseDir = Resolve-Path "..\..\"
    $SolutionFile = "$BaseDir\BC.EQCS.sln"
	$WebProjectDirectory = "$BaseDir\BC.EQCS.Web"
	$WebProjectFile = "$WebProjectDirectory\BC.EQCS.Web.csproj"
		
	$DatabaseProjectFile = "$BaseDir\BC.EQCS.Db\BC.EQCS.Database.sqlproj"

	$DeployDirectory = "$BaseDir\Deploy"   
    $BuildDirectory = "$DeployDirectory\_build"    
    $ReleasePackageDirectory = "$DeployDirectory\_release"
	$BuildReports = "$DeployDirectory\_reports"    
	$BuildReportsIntegration = "$DeployDirectory\_reports\integration_tests"    
	$BuildReportsUnit = "$DeployDirectory\_reports\unit_tests"  

	$NuGetToolPath = "$DeployDirectory\Tools\Nuget\nuget.exe"
	$NunitToolPath = "$DeployDirectory\Tools\Nunit\nunit-console.exe"
	$SpecFlowToolPath = "$BaseDir\packages\SpecFlow.1.9.0\tools\SpecFlow.exe"
	
	
}

task default -depends Init, Clean, Build, RunUnitTests, UpdateReleaseNumber, Package

task Init {
	cls 
}

task Clean {
    if (Test-Path $ReleasePackageDirectory) {
        ri $ReleasePackageDirectory -Recurse
    }      
}

task Build {	
	 exec { msbuild $SolutionFile /p:Configuration=Release  }
}

task RunUnitTests {	
	if (Test-Path $BuildReportsUnit) {
		ri $BuildReportsUnit -Recurse					  
	}
	mkdir $BuildReportsUnit  

	 exec {  & "$NunitToolPath" "$BaseDir\BC.EQCS.UnitTests\BC.EQCS.UnitTests.csproj" /config:Release /out=$BuildReportsUnit\TestResult.txt /xml:$BuildReportsUnit\TestResult.xml  }
}

task UpdateReleaseNumber {
	
	
	Get-ChildItem $WebProjectDirectory -Include web.config -Recurse | %{ 	
		 
		$filePath = $_.FullName      
		
		[xml] $fileXml = Get-Content $filePath 
		$node = $fileXml.SelectSingleNode("/configuration/appSettings/add[@key='application.ReleaseNumber']") 
		if ($node) { 
			$node.Value = $ReleaseNumber

			$fileXml.Save($filePath)  
		} 
		
	}
}

task Package {
	mkdir $ReleasePackageDirectory
	if (Test-Path $ReleasePackageDirectory) {
		Remove-Item -Recurse -Force  $ReleasePackageDirectory
	} 

    exec { msbuild $WebProjectFile /p:Configuration=Release  /p:RunOctoPack=true  /p:OctoPackPublishPackageToFileShare=$ReleasePackageDirectory /p:VisualStudioRelease=12.0  /p:OctoPackPackageVersion=$ReleaseNumber }	
    exec { msbuild $DatabaseProjectFile /p:Configuration=Release  /p:RunOctoPack=true  /p:OctoPackPublishPackageToFileShare=$ReleasePackageDirectory /p:VisualStudioRelease=12.0  /p:OctoPackPackageVersion=$ReleaseNumber }	
}
