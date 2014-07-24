FROM ubuntu:precise
MAINTAINER James Cunningham <tetrauk@gmail.com>

# Generate Locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
RUN apt-get update

# Install Official PostgreSQL Repo
RUN apt-get install -qqy wget sudo
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet --no-check-certificate -O /tmp/ACCC4CF8.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc && apt-key add /tmp/ACCC4CF8.asc
RUN apt-get update

# Install PostgreSQL
RUN apt-get -qq update && LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-9.2 postgresql-contrib-9.2 libpq-dev

# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

ADD postgresql.conf /etc/postgresql/9.2/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.2/main/pg_hba.conf
ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run
RUN rm -rf /var/lib/postgresql/9.2/main

EXPOSE 5432
CMD ["/usr/local/bin/run"]

