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
name="code.commit-to-std-layout"
rsync --archive --delete ${repositoryPath}code.original/ ${repositoryPath}${name}/

svn checkout http://localhost/svn/${name}/
cd ${name}/
svn move --parents old/branches/ branches/
svn move --parents old/tags/ tags/
svn rm old/
svn move --parents tags/old/* tags/
svn rm tags/old/
svn move --parents frost/trunk/ trunk/
svn rm frost/branches/
svn rm frost/tags/
svn rm frost/
svn move --parents contrib/ trunk/contrib/
svn move --parents misc/ trunk/misc/
svn commit --message "Restore original SVN structure"
