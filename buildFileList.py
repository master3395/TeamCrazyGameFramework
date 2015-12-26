import subprocess
import re

#Get all files in repository:
pipe = subprocess.Popen(["git", "ls-files"],
	stdout = subprocess.PIPE,
	stderr = subprocess.PIPE)
out, err = pipe.communicate()

#Retrieve game files:
filenames = []
pattern = "(src/game/.+)\n"
regex = re.compile(pattern)
for match in regex.finditer(out):
	filenames.append(match.group(1))

#Write file:
filelist = open("filelist.txt", "w")
filelist.write("\n".join(str(x) for x in filenames))