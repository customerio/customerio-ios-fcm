// File that Danger runs to catch potential errors during PR reviews: https://danger.systems/js/
import {danger, warn} from "danger"

// The SDK is deployed to multiple dependency management softwares (Cocoapods and Swift Package Manager).
// This code tries to prevent forgetting to update metadata files for one but not the other.
// Added files count as well as edited ones: danger-js reports a newly added or renamed path in
// `created_files`, so consulting `modified_files` alone would miss a podspec being introduced.
let touchedFiles = danger.git.modified_files.concat(danger.git.created_files)
let isSPMFilesModified = touchedFiles.includes('Package.swift')
let isCococapodsFilesModified = touchedFiles.filter((filePath) => filePath.endsWith('.podspec')).length > 0

console.log(`SPM files modified: ${isSPMFilesModified}, CocoaPods: ${isCococapodsFilesModified}`)

if (isSPMFilesModified || isCococapodsFilesModified) {
  if (!isSPMFilesModified) { warn("Cocoapods files (*.podspec) were modified but Swift Package Manager files (Package.*) files were not. This is error-prone when updating dependencies in one service but not the other. Double-check that you updated all of the correct files.") }
  if (!isCococapodsFilesModified) { warn("Swift Package Manager files (Package.*) were modified but Cocoapods files (*.podspec) files were not. This is error-prone when updating dependencies in one service but not the other. Double-check that you updated all of the correct files.") }
}

// Firebase/Customer.io version consistency between Package.swift and the podspec is asserted by
// .github/workflows/dependency-versions.yml, which asks each package manager to evaluate its own manifest
// rather than parsing either file here.
