#!/bin/sh

#
#  build-ffmpeg.sh
#  Aural
#
#  Copyright © 2021 Kartik Venugopal. All rights reserved.
#
#  This software is licensed under the MIT software license.
#  See the file "LICENSE" in the project root directory for license terms.
#

#
# This script builds XCFrameworks that wrap FFmpeg shared libraries (.dylib) and their
# corresponding public headers. These frameworks are suitable for use by Aural Player but not for general
# purpose FFmpeg use.
#
# Please see "README.txt" (in the same directory as this script) for detailed instructions and notes
# related to the use of this script.
#

function runBuild {

    cleanXCFrameworksDir
    buildFFmpeg
    
    if [[ "$createFatLibs" == "true" ]]
    then
    createFatLibs
    fi
    
    copyHeaders
}
