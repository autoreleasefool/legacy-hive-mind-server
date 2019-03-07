![Logo](media/HiveServer.png)

# HiveAI Server

Backend access to the HiveMind.

## Getting started

1. First, you'll need to grab a couple other repos to build the entire system and play a game of Hive against the HiveMind.
    * [Hive Client](https://github.com/josephroqueca/hive-client)
    * [Hive Server](https://github.com/josephroqueca/hive-server)
    * [HiveMind](https://github.com/josephroqueca/hivemind)
2. `bundle install` to install dependencies, including [Ruby on Rails](https://github.com/rails/rails/)
3. `rails s` to start the server
    * You may need to update `app/controllers/hive_mind_controller.rb` to point to your clone of [HiveMind](https://github.com/josephroqueca/hivemind)
    * Currently, the app assumes the two repositories have been cloned within the same parent directory
4. That's it! You've got a server running.

### Requirements

* Ruby 2.5+

## Contributing

1. Follow the directions above to get the server running
2. Open a PR with your changes 👍
