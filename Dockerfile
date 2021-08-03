# Dockerfile for the generating the Archelon Docker image
#
# To build:
#
# docker build -t docker.lib.umd.edu/archelon:<VERSION> -f Dockerfile .
#
# where <VERSION> is the Docker image version to create.
FROM ruby:2.6.3
WORKDIR /opt/archelon

# Install npm, to enable "yarn" to be installed
# And netcat, for checking if the database is available
RUN apt-get update && \
    apt-get install -y netcat-openbsd && \
    apt-get install -y build-essential && \
    apt-get install -y git && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    apt update && \
    apt-get clean

COPY ./Gemfile ./Gemfile.lock /opt/archelon/
RUN bundle install --deployment
COPY . /opt/archelon

RUN npm install --global yarn && \
    yarn

ENV RAILS_RELATIVE_URL_ROOT=
ENV SCRIPT_NAME=

# The following SECRET_KEY_BASE variable is used so that the
# "assets:precompile" command will run run without throwing an error.
# It will have no effect on the application when it is actually run.
#
# Similarly, the PROD_DATABASE_ADAPTER variable is needed for the
# "assets:precompile" Rake task to complete, but will have no effect
# on the application when it is actually run.
ENV SECRET_KEY_BASE=IGNORE_ME
RUN PROD_DATABASE_ADAPTER=postgresql bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bin/docker_start.sh"]
