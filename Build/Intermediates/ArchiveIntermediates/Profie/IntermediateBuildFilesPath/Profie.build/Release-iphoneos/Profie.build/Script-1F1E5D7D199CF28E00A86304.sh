#!/bin/sh
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${PROJECT_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-Info.plist)
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" ${PROJECT_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-Info.plist
