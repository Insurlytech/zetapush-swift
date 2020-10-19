#Contributing

If you want to submit improvements or fixes you can create a PR with your linked issue and submit changes to review

###Generate a new version

- Update changelog to target changes inside this new version
- Udpate Readme with the right new version in the Installation Section
- Update podspec with the right new version for the parameter `spec.version`
- Merge pervious changes into master
- Tag your commit on master with the new version name


###Publish on cocoapods
**! WARNING ! we can't push this repo to Cocoapods because we are not owner, so don't do this**

checkout the tag you want to deploy to cocoapods and launch this command :

```
pod trunk push ZetaPushNetwork.podspec
```

###Publish on SPM
If you tag master with the new version, nothing to do more. Everything is done ;)
