#==============================================================================
# title       : TweetBrowser
#------------------------------------------------------------------------------
# author      : jubin-park
# date        : 2022.02.06
# environment : rgss/mkxp-z
# repository  : https://github.com/jubin-park/rgss/tree/master/mkxp-z/tweet_browser
#==============================================================================

# check if using mkxp-z
if !defined?(System) || !System.is_a?(Module) || !defined?(System::VERSION) || !System::VERSION.is_a?(String)
  raise "This script is only available on mkxp-z."
end
# check mkxp-z and ruby versions
if not '''
mkxp-z2.3.0+ruby3.1.0'''.include?("mkxp-z#{System::VERSION}+ruby#{RUBY_VERSION}")
  raise "This script is not supported by the current version: mkxp-z#{System::VERSION}+ruby#{RUBY_VERSION}"
end
# add ruby path to $LOAD_PATH
ruby_dir = File.join(File.dirname(__FILE__), RUBY_VERSION)
$LOAD_PATH.unshift(ruby_dir) unless $LOAD_PATH.include?(ruby_dir)
# import cgi
require 'cgi'

module TweetBrowser
  def tweet(text: nil, url: nil, hashtags: nil)
    tweet_url = generate_tweet_url(text: text, url: url, hashtags: hashtags)
    System.launch(tweet_url)
  end

  def generate_tweet_url(**kwargs)
    final_url = "https://twitter.com/intent/tweet?"

    if kwargs[:text].is_a?(String)
      encoded_text = CGI.escape(kwargs[:text])
      final_url << "text=" << encoded_text
    end
    
    if kwargs[:url].is_a?(String)
      encoded_url = CGI.escape(kwargs[:url])
      final_url << "&url=" << encoded_url
    end

    encoded_hashtags = if kwargs[:hashtags].is_a?(String)
      CGI.escape(kwargs[:hashtags])
    elsif kwargs[:hashtags].is_a?(Array) && kwargs[:hashtags].count > 0
      CGI.escape(kwargs[:hashtags].join(','))
    else
      nil
    end
    final_url << "&hashtags=" << encoded_hashtags if !encoded_hashtags.nil?

    return final_url
  end

  module_function(:tweet)
  module_function(:generate_tweet_url)
end