#!/bin/bash

#  Copyright 2023 Spider-Admin@Z+d9Knmjd3hQeeZU6BOWPpAAxxs
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

repositoryPath="/var/lib/svn/"
originalName="code.original"
changedName="code.history-changed"
originalSVN="${repositoryPath}${originalName}/"
changedSVN="${repositoryPath}${changedName}/"
dumpFile="dump.svn"

dump() {
	local revision=$1
	echo "Transfer revision ${revision}..."
	svnadmin dump ${originalSVN} --quiet --incremental --revision ${revision} > ${dumpFile}
}

load() {
	svnadmin load ${changedSVN} --quiet --normalize-props < ${dumpFile}
	rm ${dumpFile}
}
fixPermission() {
	local name=$1
	chown --recursive www-data:www-data ${repositoryPath}${name}/
}

echo "Clone code from svn.code.sf.net..."
rsync --archive --delete svn.code.sf.net::p/jtcfrost/code/ ${originalSVN}

echo "Create repository ${changedName}..."
rm --recursive --force ${changedSVN}
svnadmin create ${changedSVN}

dump "0:3202"
load
# Skip revision 3203: Created /tags/old
# Skip revision 3204: Moved /tags to /tags/old

dump "3205:3343"
load
# Skip revision 3344: Moved /trunk/contrib to /contrib
# Skip revision 3345: Created /old

dump "3346"
load
# Skip revision 3347: Moved /trunk/frost to /frost
# Skip revision 3348: Created /frost/trunk
# Skip revision 3349: Created /frost/tags
# Skip revision 3350: Moved /frost/bin to /frost/trunk/bin
# Skip revision 3351: Moved /frost/specs to /frost/trunk/specs
# Skip revision 3352: Moved /frost/help to /frost/trunk/help
# Skip revision 3353: Moved /frost/source to /frost/trunk/source
# Skip revision 3354: Moved /frost/lib to /frost/trunk/lib
# Skip revision 3355: Moved /frost/res to /frost/trunk/res
# Skip revision 3356: Moved /branches to /old/branches
# Skip revision 3357: Moved /tags to /old/tags

dump "3358"
sed --in-place 's/3358/3343/g' ${dumpFile}
sed --in-place 's/3357/3342/g' ${dumpFile}
sed --in-place 's/frost\/miscSources/trunk\/frost\/miscSources/g' ${dumpFile}
sed --in-place 's/ misc/ trunk\/misc/g' ${dumpFile}
load
# Skip revision 3359: Deleted /trunk

dump "3360"
sed --in-place 's/3360/3344/g' ${dumpFile}
sed --in-place 's/3359/3343/g' ${dumpFile}
sed --in-place 's/frost\/buildsupport/trunk\/frost\/buildsupport/g' ${dumpFile}
sed --in-place 's/ misc/ trunk\/misc/g' ${dumpFile}
load
# Skip revision 3361: Created /frost/branches
# Skip revision 3362: Moved /frost/.classpath to /frost/trunk/.classpath
# Skip revision 3363: Moved /frost/.project to /frost/trunk/.project
# Skip revision 3364: Moved /frost/HOWTO-BUILD.txt to /frost/trunk/HOWTO-BUILD.txt
# Skip revision 3365: Moved /frost/build.xml to /frost/trunk/build.xml
# Skip revision 3366: Moved /frost/build-release.xml to /frost/trunk/build-release.xml

dump "3367:3440"
sed --in-place 's/ frost\/trunk/ trunk\/frost/g' ${dumpFile}
load

dump "3441"
sed --in-place 's/3441/3419/g' ${dumpFile}
sed --in-place 's/3440/3418/g' ${dumpFile}
sed --in-place 's/ frost.core/ trunk\/frost.core/g' ${dumpFile}
sed --in-place 's/ frost/ trunk\/frost/g' ${dumpFile}
load

dump "3442"
sed --in-place 's/ frost.core\/trunk/ trunk\/frost.core/g' ${dumpFile}
load
# Skip revision 3443: Created frost/trunk

dump "3444:3445"
sed --in-place 's/ frost\/trunk/ trunk/g' ${dumpFile}
load
# Skip revision 3446: Moved frost.core/trunk to frost.core/frost.core
# Skip revision 3447: Added frost/branches
# Skip revision 3448: Moved frost.core/frost.core to frost/trunk/frost.core
# Skip revision 3449: Deleted frost.core
# Skip revision 3450: Added frost/tags

dump "3451"
sed --in-place 's/ frost\/trunk/ trunk/g' ${dumpFile}
load
# Skip revision 3452: Added frost/trunk/frost
# Skip revision 3453: Added frost/trunk/frost.core/frost.core
# Skip revision 3454: Deleted frost/trunk/frost.core/frost.core
# Skip revision 3455: Deleted frost/trunk/frost

dump "3456:3477"
sed --in-place 's/ frost\/trunk/ trunk/g' ${dumpFile}
load

echo "Fix permissions..."
fixPermission "${originalName}"
fixPermission "${changedName}"
