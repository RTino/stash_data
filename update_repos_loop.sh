#!/bin/bash
cd /src
update_repos(){
	! [[ "$STASH_HOSTNAME" ]] && echo STASH_HOSTNAME not set && exit 1
	! [[ "$STASH_PORT" ]] && echo STASH_PORT not set && exit 1
	! [[ "$STASH_USERNAME" ]] && echo STASH_USERNAME not set && exit 1
	! [[ "$STASH_PASSWORD" ]] && echo STASH_PASSWORD not set && exit 1
	username_html_encoded="$(echo "$STASH_USERNAME" | sed -e 's/%/%25/g' -e 's/ /%20/g' -e 's/!/%21/g' -e 's/"/%22/g' -e 's/#/%23/g' -e 's/\$/%24/g' -e 's/\&/%26/g' -e 's/'\''/%27/g' -e 's/(/%28/g' -e 's/)/%29/g' -e 's/\*/%2a/g' -e 's/+/%2b/g' -e 's/,/%2c/g' -e 's/-/%2d/g' -e 's/\./%2e/g' -e 's/\//%2f/g' -e 's/:/%3a/g' -e 's/;/%3b/g' -e 's//%3e/g' -e 's/?/%3f/g' -e 's/@/%40/g' -e 's/\[/%5b/g' -e 's/\\/%5c/g' -e 's/\]/%5d/g' -e 's/\^/%5e/g' -e 's/_/%5f/g' -e 's/`/%60/g' -e 's/{/%7b/g' -e 's/|/%7c/g' -e 's/}/%7d/g' -e 's/~/%7e/g')"
	for project in $(curl -u "$STASH_USERNAME":"$STASH_PASSWORD" -X GET -H "Content-Type: application/json" "http://${STASH_HOSTNAME}:${STASH_PORT}/rest/api/1.0/projects?limit=1000" 2>/dev/null | jq .values[].key | tr -d '"')
	do
		for repo_cloneurl in $(curl -u "$STASH_USERNAME":"$STASH_PASSWORD" -X GET -H "Content-Type: application/json" "http://${STASH_HOSTNAME}:${STASH_PORT}/rest/api/1.0/projects/${project}/repos?limit=1000" 2>/dev/null | jq .values[].cloneUrl | tr -d '"')
		do
			repo_cloneurl="https://${username_html_encoded}:${STASH_PASSWORD}@${repo_cloneurl#*@}"
			reponame_git=${repo_cloneurl##*/}
			reponame=${reponame_git%*.git}
			echo Updating "${project}/${reponame}"
			if ! git clone "$repo_cloneurl" "${project}/${reponame}"
			then
				pushd "${project}/${reponame}" && \
				git fetch --all
				popd
			fi
		done
	done
}

while :
do
	echo Updating repos
	update_repos
	echo Sleeping 24h
	sleep 24h
done