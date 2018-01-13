FROM elixir:1.5.3-slim as builder

RUN apt-get -qq update
RUN apt-get -qq install git build-essential
RUN apt-get install -y libpq-dev

ENV MIX_ENV=prod
ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy code
COPY mix.exs mix.lock $APP_HOME/
COPY config config
COPY apps apps

# Install hex
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.clean --all && \
    mix deps.get

WORKDIR $APP_HOME
ENV MIX_ENV=prod
RUN MIX_ENV=prod mix phx.digest

WORKDIR $APP_HOME

COPY rel rel

RUN mix release --env=$MIX_ENV

#############################

FROM debian:jessie-slim

ENV APP_HOME /app
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update
RUN apt-get -qq install -y locales

# Set LOCALE to UTF8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get -qq install libssl1.0.0 libssl-dev
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/connect_four_elixir .

CMD ["./bin/connect_four_elixir", "foreground"]
