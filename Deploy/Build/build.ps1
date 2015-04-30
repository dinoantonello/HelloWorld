properties {
	$BaseDirectory = "F:\Hello_World"
   $SolutionFile = "$BaseDirectory\SourceCode\Hello_World.sln"
   $ReleasePackageDirectory = "$BaseDirectory\Deploy\_release"
   $WebProjectDirectory = "$BaseDirectory\SourceCode\Website\"
   $WebProjectFile = "$BaseDirectory\SourceCode\Website\Website.csproj"
}

task default -depends Init, build, UpdateReleaseNumber, package

task Init {
	cls 
}

task build {
	exec { msbuild $SolutionFile /p:Configuration=Release /p:VisualStudioRelease=12 }
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

task package {
	
	if (Test-Path $ReleasePackageDirectory) {
		Remove-Item -Recurse -Force  $ReleasePackageDirectory
	} 
	
	mkdir $ReleasePackageDirectory

	exec { msbuild $WebProjectFile /p:Configuration=Release  /p:RunOctoPack=true  /p:OctoPackPublishPackageToFileShare=$ReleasePackageDirectory /p:VisualStudioRelease=12.0  /p:OctoPackPackageVersion=$ReleaseNumber }	
}