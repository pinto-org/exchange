docker run -v $(pwd):/Wells ethereum/solc:stable --base-path ./Wells $(tr '\n' ' ' < remappings.txt) -o /Wells/out --userdoc --devdoc --overwrite /Wells/src/Well.sol