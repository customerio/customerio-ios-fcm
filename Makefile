SHELL = /bin/sh

lint:
	./binny swiftlint lint --strict

# specify swiftversion this way instead of .swift-version to (1) keep project files slim and (2) we can specify the version in a CI server matrix for multiple version testing. 
# use the min Swift version that we support/test against. 
format:
	./binny swiftformat . --swiftversion 5.5 && ./binny swiftlint lint --fix

