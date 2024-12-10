@echo off
setlocal

REM Replace these with your GitHub username and repository name
set USER=USERNAME
set REPO=REPO

echo Creating Milestones...
for /f "delims=" %%G in ('jq -c ".[]" milestones.json') do (
  for /f "delims=" %%H in ('echo %%G^| jq -r ".title"') do set "title=%%H"
  for /f "delims=" %%I in ('echo %%G^| jq -r ".description"') do set "description=%%I"

  gh api --method POST -H "Accept: application/vnd.github+json" /repos/%USER%/%REPO%/milestones -f title="%title%" -f state="open" -f description="%description%"
)

echo Creating Issues...
for /f "delims=" %%G in ('jq -c ".[]" issues.json') do (
  for /f "delims=" %%H in ('echo %%G^| jq -r ".title"') do set "ititle=%%H"
  for /f "delims=" %%I in ('echo %%G^| jq -r ".body"') do set "ibody=%%I"
  for /f "delims=" %%J in ('echo %%G^| jq -r ".milestone"') do set "imstone=%%J"
  for /f "delims=" %%K in ('echo %%G^| jq -r "[.labels[]] | join(\",\")"') do set "ilabels=%%K"

  REM Retrieve the milestone number by searching by title
  for /f "delims=" %%L in ('gh api repos/%USER%/%REPO%/milestones --jq ".[] | select(.title==\"%imstone%\").number"') do set "mnum=%%L"

  gh issue create --repo %USER%/%REPO% --title "%ititle%" --body "%ibody%" --label "%ilabels%" --milestone %mnum%
)

echo All milestones and issues created successfully!
endlocal