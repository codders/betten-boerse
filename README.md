# Betten Börse

A simple ruby script to match guests with hosts.

## Installation

You will need ruby and rubygems installed on your system. Simply checkout the project and run

```sh
bundle install
```

## Getting the data

The data needs to come from a CMS system. We use Mautic for this purpose. If you have a dump of the CMS data in CSV format, and you have the `csvtool` command installed, you can run `./extract_csvs.sh` to generate host and guest CSV files

```sh
./extract_csvs.sh contacts_october-1-2019.csv
```

## Running

You need to get CSV files detailing the availability of hosts and guests. When you have these files, you can run:

```sh
bundle exec ruby betten-börse.rb --hosts hosts.csv --guests guests.csv
```

to produce a complete report. If you want data output in a format that can be imported back into Mautic, add the `--format csv` option:

```sh
bundle exec ruby betten-börse.rb --hosts hosts.csv --guests guests.csv --format csv
```

## Test

You need spec installed in order to run the tests:

```sh
bundle exec ruby spec/*.rb
```
