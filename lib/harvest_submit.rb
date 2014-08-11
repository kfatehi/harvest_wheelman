require 'json'
require 'selenium-webdriver'
require 'timerizer'

##
# Puts +str+ into the pasteboard (Mac only)
def pbcopy(str)
  return unless RUBY_PLATFORM =~ /darwin/
  `echo "#{str.strip}" | pbcopy`
end

class Date
  def self.nearest_sunday
    date = Date.today
    wday = date.wday
    if wday >= 4
      wday.upto(6) do
        date = 1.day.after(date)
      end
    elsif wday <= 3
      wday.downto(1) do
        date = 1.day.before(date)
      end
    end
    return date
  end
end

module HarvestWheelman
  class HarvestSubmit
    class UnknownTimeIntervalError < StandardError ; end
    DATEFORMAT = "%m/%d/%Y"
    attr_reader :harvest
    attr_writer :from, :to

    def initialize(settings_file)
      File.open(settings_file) do |f|
        @settings = JSON.parse(f.read)
      end
      if not @settings['pay_period']
        @ppw = 2
        @to = date_to_string Date.nearest_sunday
      end
      determine_time_interval!
    end

    ##
    # Pay period weeks
    def ppw
      @ppw ||= @settings['pay_period']['weeks'] rescue 2
    end

    def determine_time_interval!
      if date_valid? from
        if date_valid? to
        else
          puts "Setting TO via the FROM based on a #{ppw} week pay period"
          @to = date_to_string(1.day.before(ppw.weeks.after(string_to_date(from))))
        end
      elsif date_valid? to
        puts "Setting FROM via the TO based on a #{ppw} week pay period"
        @from = date_to_string(1.day.after(ppw.weeks.before(string_to_date(to))))
      else
        raise UnknownTimeIntervalError
      end
    end

    def string_to_date(input)
      Date.strptime(input, DATEFORMAT)
    end

    def date_to_string(input)
      input.strftime(DATEFORMAT)
    end

    def date_valid?(input)
      return false unless input
      begin
        string_to_date input
      rescue ArgumentError
        false
      end
    end

    def from
      @from ||= @settings['pay_period']['from'] rescue nil
    end

    def to
      @to ||= @settings['pay_period']['to'] rescue nil
    end

    def site
      @settings["harvest"]["site"]
    end
    
    def user
      @settings['harvest']['user']
    end

    def pass
      @settings['harvest']['pass']
    end

    def whoami
      `whoami`.strip.capitalize
    end

    def pdf_name
      "#{subject}.pdf"
    end

    def subject
      "#{whoami}'s Timesheet #{from} - #{to}"
    end

    def body
      <<-EOF
Hello,
Attached is my timesheet for pay period #{from} - #{to}

Thank you,
#{whoami}

Generated using http://rubygems.org/gems/harvest_wheelman
Version #{HarvestWheelman::VERSION}
      EOF
    end

    def drive_to_pdf
      begin
        puts "Starting chromedriver"
        @driver = Selenium::WebDriver.for :chrome
        @base_url = "https://#{site}.harvestapp.com/"
        puts "Driving to #{@base_url}"
        @driver.manage.timeouts.implicit_wait = 30
        @verification_errors = []
        @driver.get(@base_url + "/account/login")
        puts "Signing in as #{user}"
        @driver.find_element(:id, "email").clear
        @driver.find_element(:id, "email").send_keys user
        @driver.find_element(:id, "user_password").clear
        @driver.find_element(:id, "user_password").send_keys pass
        @driver.find_element(:id, "sign-in-button").click
        puts "Heading to the Reports area"
        @driver.find_element(:link, "Reports").click
        @driver.find_element(:css, "span.btn-dropdown").click
        @driver.find_element(:link, "Custom").click

        puts "Entering custom dates"
        @driver.find_element(:id, "start_date").clear
        @driver.find_element(:id, "start_date").send_keys from
        @driver.find_element(:id, "end_date").clear
        @driver.find_element(:id, "end_date").send_keys to

        puts "Requesting detailed report"
        @driver.find_element(:link, "Update Report").click
        @driver.find_element(:link, "Detailed Report").click
        @driver.find_elements(:tag_name => 'option').find{|i| i.text == 'Task'}.click
        
        puts "Print as PDF. Filename:\n#{pdf_name}"
        if pbcopy pdf_name
          puts "Filename is currently in your pasteboard for file save dialog..."
        end
        @driver.execute_script('window.print()')
        @driver.find_element(:xpath, "//nav[@id='nav']/div/ul/li[4]/a").click
        @driver.find_element(:link, "Sign Out").click
        puts "Email your PDF."
        pbcopy subject
        puts <<-EOF
        -------------------------------
#{subject}


#{body}
        -------------------------------
        EOF
      rescue Exception => ex
puts <<-EOF
Error: #{ex.message}
------------------
#{ex.backtrace.join("\n")} 
EOF
      ensure
        @driver.quit
      end
    end
  end
end
