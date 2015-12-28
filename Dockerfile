FROM debian

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y git jq curl
ADD update_repos_loop.sh /
VOLUME /src
WORKDIR /src
CMD ["/update_repos_loop.sh"]
