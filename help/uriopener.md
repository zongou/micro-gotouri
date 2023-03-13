# uriopener Plugin #
Open the uri where the cursor is on.

### To initiate the function
Fisrt. Place the cusor on or ahead of the target link uri,  
Then run:

```
> openuri
```

### To open uri with a cusom command
{uri} in option string will be replaced with true uri value  
Run to set cmd option:

```
> set uriopener.cmd "yourCustomCommand"
```

An example to open uri with chrome in incognito:
 
```
> set uriopener.cmd "path/to/chrome/executable -incognito {uri}"
```

Reset to default:

```
> set uriopener.cmd "default"
```