# Betten Börse

A simple ruby script to match guests with hosts.

## Installation

You will need ruby and rubygems installed on your system. Simply checkout the project and run

```sh
bundle install
```

## Running

You need to get CSV files detailing the availability of hosts and guests. When you have these files, you can run:

```sh
bundle exec ruby betten-börse.rb hosts.csv guests.csv
```

## Test

You need spec installed in order to run the tests:

```sh
bundle exec ruby spec/*.rb
```
