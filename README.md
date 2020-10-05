# reproducible-build

# Usage:

````bash
./rebuild.sh
````

# Explanation

Rebuild will inject a parent pom and rebuild injector shell script into the child project.

It will then execute the reproducible build and clean up everything afterwards except for the two *.buildinfo and *.jar files left in the target folder
