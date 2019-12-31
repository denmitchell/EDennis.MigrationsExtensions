param([string]$file)
# #######################################################
#
# Author: Dennis Mitchell
# Last Modified: 2019-09-26
# Functionality: Generate Dynamic SQL, replacing various
#                tokens with variables.  Variable tokens
#                in source SQL may start with @ character.
# 
# Named Arguments:      -file 'pathToSqlFile'
# Positional Arguments: '@FirstVariable' '@SecondVariable' 
#                       ... etc.        
#
# #######################################################

$scriptPath = $MyInvocation.MyCommand.Path
$folder = Split-Path $scriptPath

Push-Location $folder
$filePath = Resolve-Path $file
$sql = [IO.File]::ReadAllText($filePath) 
Pop-Location


$sql = $sql -replace "'", "''"
$declares = ""

for ($i=0 ;$i -lt $args.Count; $i++) {
    $varName = "@" + ($args[$i] -replace "@", "")
    $declares += "declare $varName varchar(500) = '$varName';`r`n"
    $sql = $sql -replace $args[$i], "' + $varName + '"
} 

$sql = $declares + "declare @sql varchar(max) = '$sql'"
$sql += "`r`nPRINT @sql"

[IO.File]::WriteAllText(($filePath -replace "[.]sql", ".dynamic.sql"),$sql) 