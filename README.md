# Frost-Migration

This is how I converted Frost from SVN to Git. The layout of the repository in SVN was somehow broken, so I tested several ways to fix it:

- code.original = Unchanged code converted to Git. Most of the tags/branches exists 2-3 times.
- code.commit-to-std-layout = Rearrange the code to fit the standard layout of SVN. Most of the tags/branches exists 3-4 times.
- code.history-changed = History of code was changed such that no duplicate tags/branches appear in the resulting repository and to fit the standard layout of SVN.

## 1. Install required software

```
apt-get install git subversion git-svn rsync
```

https://tecadmin.net/install-svn-server-on-debian/

-> Remove line "Alias /svn /var/lib/svn"

## 2. Generate users.txt

```
svn checkout https://svn.code.sf.net/p/jtcfrost/code/
cd code
svn log --xml --quiet | grep author | sort -u | perl -pe 's/.*>(.*?)<.*/$1 = /' > ../users.txt
```

## 3. Edit users.txt

- https://sourceforge.net/p/forge/documentation/User%20Email%20Alias/
- https://sourceforge.net/u/artur8ur/profile/
- https://lore.kernel.org/netdev/20230623225513.2732256-10-dhowells@redhat.com/

## 4. Run rewrite-history.sh

This will clone the SVN repository of Frost to `/var/lib/svn/code.original/`. It will then rewrite the history and save the result to `/var/lib/svn/code.history-changed/`.

## 5. Optional: Run change-layout.sh

This will copy `/var/lib/svn/code.original/` to `/var/lib/svn/code.commit-to-std-layout/` and rearranges everything to match the standard layout of SVN.

## 6. Convert to Git

code.original:

`git svn clone http://localhost/svn/code.original/ --authors-file=./users.txt --no-metadata --prefix "" --trunk=frost/trunk --branches=frost/branches --branches=old/branches --tags=frost/tags --tags=old/tags --tags=old/tags/old ./code.original/`

code.commit-to-std-layout:

`git svn clone http://localhost/svn/code.commit-to-std-layout/ --authors-file=./users.txt --no-metadata --prefix "" --stdlayout ./code.commit-to-std-layout/`

code.history-changed:

`git svn clone http://localhost/svn/code.history-changed/ --authors-file=./users.txt --no-metadata --prefix "" --stdlayout ./code.history-changed/`

Each of the commands took very long to finish. Then "cd" into the newly created folder and run

`git config core.filemode false`

## 7. Some adjustments

Obviously I used "code.history-changed" and did some adjustments as described here

https://git-scm.com/book/en/v2/Git-and-Other-Systems-Migrating-to-Git

```
for t in $(git for-each-ref --format='%(refname:short)' refs/remotes/tags); do git tag ${t/tags\//} $t && git branch -D -r $t; done
for b in $(git for-each-ref --format='%(refname:short)' refs/remotes); do git branch $b refs/remotes/$b && git branch -D -r $b; done
for p in $(git for-each-ref --format='%(refname:short)' | grep @); do git branch -D $p; done
git branch -d trunk
```

Then I manually checked some duplicate tags and removed the duplicates:

```
git tag -d release-03-Jan-2011_beta@3209
git tag -d release-01-Jan-2011_beta-1
git tag release-01-Jan-2011_beta-1 release-01-Jan-2011_beta-1@3201
git tag -d release-01-Jan-2011_beta-1@3201
git tag -d version_19-Jul-2007
git tag version_19-Jul-2007 version_19-Jul-2007@2739
git tag -d version_19-Jul-2007@2739
git tag -d version_2009-03-14_\(last-with-05-support\)
git tag version_2009-03-14_\(last-with-05-support\) version_2009-03-14_\(last-with-05-support\)@3090
git tag -d version_2009-03-14_\(last-with-05-support\)@3090
#
# release-03-Jan-2011_beta vs. release-03-Jan-2011_beta@3209
# - 1 Empty commit with the new tag.
# 
# release-01-Jan-2011_beta-1 vs. release-01-Jan-2011_beta-1@3201
# - 1 Empty commit with the new tag.
# 
# version_2009-03-14_(last-with-05-support) vs. version_2009-03-14_(last-with-05-support)@3090
# - 1 Empty commit with the new tag.
# 
# version_19-Jul-2007 vs. version_19-Jul-2007@2739
# - 1 Empty commit.
# - 1 Commit with the new tag and all files were deleted.
```

The repository "code.history-changed" can be found here:

https://github.com/Spider-Admin/Frost

### TODO

- Verify the users in users.txt. Are the names correct? Better emails, which are recognized by GitHub?
- Are you satisfied with code.history-changed?
- Did I missed something?

## Future tasks

- Migrate from Maven to Gradle.
- Update dependencies such that Frost will run with at least OpenJDK 15.
- Replace Joda-Time with java.time.
- Replace Logging with Logback and slf4j.
- Replace Perst with SQLite.

I will try to reuse parts of Frost-Next by

- The Kitty@++ from USK@~kiTTy3Rc2kOhIRnJl1P13JXtZeJSqln76h7DC3AgGw,Ocr6A3ZSED6iBZJZrCd9jTtW5JuxkRP7S4NXL9XWBgg,AQACAAE/The_Kitty/12/#link-FrostNext
- naejadu@CdAgQ8S8lIWCxanP4t4YMVkXaJM
