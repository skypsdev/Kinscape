FROM ruby:2.7.0
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq \
    && apt-get install -y build-essential libpq-dev nodejs zlib1g-dev liblzma-dev yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN gem install bundler:2.1.4
WORKDIR /kinscape
COPY encrypted_action_text ./encrypted_action_text
COPY Gemfile* ./
RUN bundle config set without 'staging production' \
  && bundle install \
  && find /usr/local/bundle/cache -name "*.gem" -delete \
  && find /usr/local/bundle/gems -name "*.c" -delete \
  && find /usr/local/bundle/gems -name "*.o" -delete
COPY package.json ./
RUN yarn install
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
