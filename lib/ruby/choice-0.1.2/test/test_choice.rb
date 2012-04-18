$:.unshift "../lib:lib"
require 'test/unit'
require 'choice'

$VERBOSE = nil

class TestChoice < Test::Unit::TestCase
  
  def setup
    Choice.reset!
    Choice.dont_exit_on_help = true
    Choice.send(:class_variable_set, '@@choices', true)
  end
    
  def test_choices
    Choice.options do
      header "Tell me about yourself?"
      header ""
      option :band do
        short "-b"
        long "--band=BAND"
        cast String
        desc "Your favorite band."
        validate /\w+/
      end
      option :animal do
        short "-a"
        long "--animal=ANIMAL"
        cast String
        desc "Your favorite animal."
      end
      footer ""
      footer "--help This message"
    end
    
    band = 'LedZeppelin'
    animal = 'Reindeer'
    
    args = ['-b', band, "--animal=#{animal}"]
    Choice.args = args
    
    assert_equal band, Choice.choices['band']
    assert_equal animal, Choice.choices[:animal]
    assert_equal ["Tell me about yourself?", ""], Choice.header
    assert_equal ["", "--help This message"], Choice.footer
  end
  
  def test_failed_parse
    assert Hash.new, Choice.parse
  end
  
  HELP_STRING = ''
  def test_help
    Choice.output_to(HELP_STRING)
    
    Choice.options do
      banner "Usage: choice [-mu]"
      header ""
      option :meal do
        short '-m'
        desc 'Your favorite meal.'
      end
      
      separator ""
      separator "And you eat it with..."
      
      option :utencil do
        short "-u"
        long "--utencil[=UTENCIL]"
        desc "Your favorite eating utencil."
      end
    end

    Choice.args = ['-m', 'lunch', '--help']
    
    help_string = <<-HELP
Usage: choice [-mu]

    -m                               Your favorite meal.

And you eat it with...
    -u, --utencil[=UTENCIL]          Your favorite eating utencil.
HELP

    assert_equal help_string, HELP_STRING
  end
  
  UNKNOWN_STRING = ''
  def test_unknown_argument
    Choice.output_to(UNKNOWN_STRING)
    
    Choice.options do
      banner "Usage: choice [-mu]"
      header ""
      option :meal do
        short '-m'
        desc 'Your favorite meal.'
      end
      
      separator ""
      separator "And you eat it with..."
      
      option :utencil do
        short "-u"
        long "--utencil[=UTENCIL]"
        desc "Your favorite eating utencil."
      end
    end

    Choice.args = ['-m', 'lunch', '--motorcycles']
    
    help_string = <<-HELP
Usage: choice [-mu]

    -m                               Your favorite meal.

And you eat it with...
    -u, --utencil[=UTENCIL]          Your favorite eating utencil.
HELP
    
    assert_equal help_string, UNKNOWN_STRING
  end
  
  REQUIRED_STRING = ''
  def test_required_argument
    Choice.output_to(REQUIRED_STRING)
    
    Choice.options do
      banner "Usage: choice [-mu]"
      header ""
      option :meal, :required => true do
        short '-m'
        desc 'Your favorite meal.'
      end
      
      separator ""
      separator "And you eat it with..."
      
      option :utencil do
        short "-u"
        long "--utencil[=UTENCIL]"
        desc "Your favorite eating utencil."
      end
    end

    Choice.args = ['-u', 'spork']
    
    help_string = <<-HELP
Usage: choice [-mu]

    -m                               Your favorite meal.

And you eat it with...
    -u, --utencil[=UTENCIL]          Your favorite eating utencil.
HELP
    
    assert_equal help_string, REQUIRED_STRING
  end

  def test_shorthand_choices
    Choice.options do
      header "Tell me about yourself?"
      header ""
      options :band => { :short => "-b", :long => "--band=BAND", :cast => String, :desc => ["Your favorite band.", "Something cool."],
                        :validate => /\w+/ },
              :animal => { :short => "-a", :long => "--animal=ANIMAL", :cast => String, :desc => "Your favorite animal." }
      
      footer ""
      footer "--help This message"
    end
    
    band = 'LedZeppelin'
    animal = 'Reindeer'
    
    args = ['-b', band, "--animal=#{animal}"]
    Choice.args = args
    
    assert_equal band, Choice.choices['band']
    assert_equal animal, Choice.choices[:animal]
    assert_equal ["Tell me about yourself?", ""], Choice.header
    assert_equal ["", "--help This message"], Choice.footer
  end
end
