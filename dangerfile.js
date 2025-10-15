// File that Danger runs to catch potential errors during PR reviews: https://danger.systems/js/
import {message, danger, warn} from "danger"
import {readFileSync} from "fs"

// The SDK is deployed to multiple dependency management softwares (Cocoapods and Swift Package Manager). 
// This code tries to prevent forgetting to update metadata files for one but not the other. 
let isSPMFilesModified = danger.git.modified_files.includes('Package.swift') 
let isCococapodsFilesModified = danger.git.modified_files.filter((filePath) => filePath.endsWith('.podspec')).length > 0

console.log(`SPM files modified: ${isSPMFilesModified}, CocoaPods: ${isCococapodsFilesModified}`)

if (isSPMFilesModified || isCococapodsFilesModified) {
  if (!isSPMFilesModified) { warn("Cocoapods files (*.podspec) were modified but Swift Package Manager files (Package.*) files were not. This is error-prone when updating dependencies in one service but not the other. Double-check that you updated all of the correct files.") }
  if (!isCococapodsFilesModified) { warn("Swift Package Manager files (Package.*) were modified but Cocoapods files (*.podspec) files were not. This is error-prone when updating dependencies in one service but not the other. Double-check that you updated all of the correct files.") }
}

// Check Firebase version consistency between Package.swift and CioFirebaseWrapper.podspec
function checkFirebaseVersionConsistency() {
  try {
    // Read Package.swift and extract Firebase version range
    const packageSwiftContent = readFileSync('Package.swift', 'utf8')
    const firebasePackageMatch = packageSwiftContent.match(/\.package\(url: "https:\/\/github\.com\/firebase\/firebase-ios-sdk\.git", \.upToNextMajor\(from: "(\d+\.\d+\.\d+)"\)\)/)
    
    if (!firebasePackageMatch) {
      warn("Could not parse Firebase version range from Package.swift")
      return
    }
    
    const spmVersion = firebasePackageMatch[1]
    const spmMajor = spmVersion.split('.')[0]
    
    // Read CioFirebaseWrapper.podspec and extract FirebaseMessaging version range
    const podspecContent = readFileSync('CioFirebaseWrapper.podspec', 'utf8')
    const firebaseDepMatch = podspecContent.match(/spec\.dependency "FirebaseMessaging", "~> (\d+)\.(\d+)"/)
    
    if (!firebaseDepMatch) {
      warn("Could not parse FirebaseMessaging version range from CioFirebaseWrapper.podspec")
      return
    }
    
    const podspecMajor = firebaseDepMatch[1]
    const podspecMinor = firebaseDepMatch[2]
    
    // Compare major versions
    if (spmMajor !== podspecMajor) {
      warn(`Firebase major version mismatch! Package.swift: ${spmMajor}.x, CioFirebaseWrapper.podspec: ${podspecMajor}.x`)
    } else {
      message(`✅ Firebase major versions are consistent: ${spmMajor}.x`)
    }
  } catch (error) {
    warn(`Error checking Firebase version consistency: ${error.message}`)
  }
}

// Run the Firebase version consistency check if Firebase-related files were modified
if (isSPMFilesModified || isCococapodsFilesModified) {
  checkFirebaseVersionConsistency()
}

