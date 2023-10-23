FROM ruby:3.2.2-alpine

ENV PORT 8000

RUN apk update \
    && apk add postgresql-dev nodejs yarn build-base \
    && addgroup -S ruby \
    && adduser -S -u 1000 -G ruby ruby \
    && mkdir /home/ruby/app \
    && chown ruby:ruby /home/ruby/app

RUN gem install bundler && chmod -R 777 "$GEM_HOME"


USER ruby
WORKDIR /home/ruby/app
COPY --chown=ruby . .

ENV BUNDLE_WITHOUT test development

RUN bundle install --jobs 4

CMD bundle exec puma -t 5:5 -p ${PORT:-$PORT}