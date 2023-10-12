# Launching and Connecting our Terra house to TerraTowns

We started out this week by creating a mock server for Terratowns, we needed a mock server to use in rapidly testing out our APIs as we create our custom provider.

# TerraTowns Mock Server

The code for our custom provider i located in the [Terratowns mock server repo](https://github.com/ExamProCo/terratowns_mock_server) and tghe first thing we need to do is to download the repo so we can easily work with the code.

To do this we run the below command:

```sh
git clone https://github.com/ExamProCo/terratowns_mock_server.git
```

The next thing we need to do is to delete the `.git` directory in the just downloaded repo.

```sh
cd terratowns_mock_server
rm -rf .git
```

I then added the necessary configuration to my `gitypod.yml` and my `postCreateCommand.sh` files.

In the `gitpod.yml` file
```yml
  - name: sinatra
    before: | 
      cd $PROJECT_ROOT
      cd terratowns_mock_server
      bundle install
      bundle exec ruby server.rb 
```

In the `postCreateCommand` file

```sh
# Navigate to the project root, Navigate to the Sinatra application directory Install dependencies & start the Sinatra server
cd "$PROJECT_ROOT"
cd "terratowns_mock_server"
bundle install
bundle exec ruby server.rb
```

The `bundle install` command will install ruby packages and the `bundle exec ruby server` command will start up the ruby server for us.

I renamed the bin directory in the `terratowns_mock_server` directory to `terratowns` and moved this folder into the `bin` directory in the top level.

I did this because that directory contains all scripts we would use to build our terratowns mock server.

I then made all the scripts in that directory executable, instead of doing it one at a time for all the scripts in the directory I used one command that applied to all the scripts at once:

```sh
chmod u+x bin/terratown/*
```

This command simply says, apply this permission to all the files in this directory.

