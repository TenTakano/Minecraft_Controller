FROM elixir:1.10.4-alpine

WORKDIR /home/minecraft_controller
COPY ./ /home/minecraft_controller/

ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

# This is a secret for docker build. This should be overwritten by `docker run`
ENV SECRET_KEY_BASE=wE9GdKOszRedTXXKgwIiqiuhoCtWjMyTvkPhuojijgPhMB00enXIU6OlxkpTbgFa

# compile project
RUN mix local.hex --force \
  && mix local.rebar --force \
  && mix setup \
  && mix deps.compile \
  && mix release

CMD ["_build/prod/rel/minecraft_controller/bin/minecraft_controller", "start"]
