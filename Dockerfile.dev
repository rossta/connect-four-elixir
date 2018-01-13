FROM elixir:1.5.3

RUN apt-get update -qq
RUN apt-get install -y build-essential
RUN apt-get install -y -q apt-utils
RUN apt-get install -y -q inotify-tools

# Install the Phoenix framework itself
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

# Set directory for our app ENV APP_HOME /app
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY mix.exs mix.lock $APP_HOME/

# Install hex
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.clean --all && \
    mix deps.get

# Copy code
ADD . $APP_HOME
