#
# Automate the creation of C++ project
#

Param(
    [string] $ProjectName,
    [switch] $ExcludeLicense = $false,
    [switch] $CreateGitIgnore = $false
)

if (-Not $ProjectName) {
    Write-Error "Please provide a project name."
    return
}

if (Test-Path -Path "$ProjectName") {
    Write-Warning "Project '$ProjectName' already exists."
    return
}

Write-Host "Creating project '$ProjectName'..."

New-Item -ItemType Directory -Path "$ProjectName" -ErrorAction Stop | Out-Null
New-Item -ItemType Directory -Path "$ProjectName\code" -ErrorAction Stop | Out-Null
New-Item -ItemType Directory -Path "$ProjectName\misc" -ErrorAction Stop | Out-Null

New-Item -ItemType File -Path "$ProjectName\$ProjectName.sublime-project" | Out-Null
New-Item -ItemType File -Path "$ProjectName\misc\shell.bat" | Out-Null
New-Item -ItemType File -Path "$ProjectName\code\build.bat" | Out-Null
New-Item -ItemType File -Path "$ProjectName\code\$ProjectName.cpp" | Out-Null

# LICENSE content
if (-Not $ExcludeLicense) {

    New-Item -ItemType File -Path "$ProjectName\LICENSE" | Out-Null

    $license = @"
    MIT License

    Copyright (c) $(Get-Date -Format "yyyy") Nicolas Gerber

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
"@

    Set-Content -Path "$ProjectName\LICENSE" -Value $license   
}

# shell.bat content
$shell = @"
@echo off
echo Starting visual studio 2019 x64 tools
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x64
"@
Set-Content -Path "$ProjectName\misc\shell.bat" -Value $shell

# build.bat content
$build = @"
@echo off

set CommonCompilerFlags=-MTd -Od -nologo -EHsc -GR- -W4 -Z7

set BuildDirectory=..\..\build\$ProjectName

if not exist %BuildDirectory% mkdir %BuildDirectory%
pushd %BuildDirectory%

:: del *.pdb > NUL 2> NUL

cl %CommonCompilerFlags% %~dp0\$ProjectName.cpp

popd
"@
Set-Content -Path "$ProjectName\code\build.bat" -Value $build

# main.cpp content
$main = @"
#include <stdio.h>

int main(char *ArgCount, char **Args)
{
    printf("Hello from $ProjectName!");
    return 0;
}
"@
Set-Content -Path "$ProjectName\code\$ProjectName.cpp" -Value $main


# sublime project
$project = @"
{
    "folders":
    [
        {
            "path": "."
        }
    ],
    "build_systems":
    [
        {
            "name": "Build $ProjectName",
            "shell_cmd": "`${project_path}/code/build.bat",
            "working_dir": "`${project_path}/code",
            "syntax": "vc_output.tmLanguage",
            "file_regex": "^((?:\\w\\:)?[^\\:\\n]+)\\((\\d+)\\)(\\s)?\\: (?:fatal error|error|warning) \\w\\d+: ()([^\\n]+)$",
            "variants":
            [
                {
                    "name": "run",
                    "shell_cmd": "`${project_path}/../build/$ProjectName/$ProjectName.exe",
                    "working_dir": "`${project_path}/../build/$ProjectName"
                }
            ]
        }
    ]
}
"@
Set-Content -Path "$ProjectName\$ProjectName.sublime-project" -Value $project

# git ignore
if ($CreateGitIgnore) {
    
    New-Item -ItemType File -Path "$ProjectName\.gitignore" | Out-Null

    $gitignore = @"
    # Sublime files
    *.sublime-workspace

    # Prerequisites
    *.d

    # Compiled Object files
    *.slo
    *.lo
    *.o
    *.obj

    # Precompiled Headers
    *.gch
    *.pch

    # Compiled Dynamic libraries
    *.so
    *.dylib
    *.dll

    # Fortran module files
    *.mod
    *.smod

    # Compiled Static libraries
    *.lai
    *.la
    *.a
    *.lib

    # Executables
    *.exe
    *.out
    *.app
"@

    Set-Content -Path "$ProjectName\.gitignore" -Value $gitignore
}
