FROM confluentinc/ksql-clickstream-demo:5.0.0

LABEL version="1.0"
LABEL description="Extending confluentinc/ksql image adding a few more packages"

#ENV http_proxy=
#ENV https_proxy=

RUN apt-get update
RUN apt-get install vim-tiny -y

# I know you are not supposed to do this, it's not very docker-like
ENTRYPOINT ["tail", "-f", "/dev/null"]

