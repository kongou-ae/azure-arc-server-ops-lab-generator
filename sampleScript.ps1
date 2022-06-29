# Deploying resources
New-AzSubscriptionDeployment -Name (Get-date -format yyMMdd) -Location "japaneast" -TemplateFile .\main.bicep -TemplateParameterFile "param.json"

# Deleting resources
Remove-AzResourceGroup -Name rg-net-arcsvlab-eval -Force -AsJob
Remove-AzResourceGroup -Name rg-vm-arcsvlab-eval -Force -AsJob