# HarvestWheelman

I use this tool to generate a PDF report from Harvest the way my company wants them for every pay period.

## Example Settings File

```json
{
  "harvest":{
    "site":"---",
    "user":"---",
    "pass":"---"
  },
  "pay_period":{
    "weeks":2,            # weeks in a pay period; used when only 1 date given (optional and defaults to 2)
    "from":"09/03/2012",  # start of pay period (optional if 'to' exists)
    "to":"09/16/2012"     # end of pay period (optional if 'from' exists)
  }
}
```

## Installation

Add this line to your application's Gemfile:

    gem 'harvest_wheelman'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install harvest_wheelman

## Usage

`harvest_wheelman`

Optionally you can pass in a settings file like this:

`harvest_wheelman ~/MyStuff/harvest_Wheelman.json` 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
