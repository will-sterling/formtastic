# coding: utf-8
require 'rubygems'

gem 'activesupport', '>= 2.3.5'
gem 'actionpack', '>= 2.3.5'
require 'active_support'
require 'action_pack'
require 'action_view'
require 'action_controller'

begin
  gem 'activemodel', '>= 3.0.0.beta'
  require 'active_model'
rescue Exception
end

gem 'rspec', '>= 1.2.6'
gem 'rspec-rails', '>= 1.2.6'
gem 'hpricot', '>= 0.6.1'
gem 'rspec_tag_matchers', '>= 1.0.0'
require 'rspec_tag_matchers'

require 'custom_macros'

begin
  Spec::Runner.configure do |config|
    config.include(RspecTagMatchers)
    config.include(CustomMacros)
  end
rescue
  require 'rspec/core'
  Rspec.configure do |config|
    config.include RspecTagMatchers
    config.include CustomMacros
    config.mock_with :rspec
  end
end

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/formtastic'))
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/formtastic/layout_helper'))

module ActionView
  class OutputBuffer < Formtastic::Util.rails_safe_buffer_class
  end
end

module FormtasticSpecHelper
  include ActionView::Context if defined?(ActionView::Context)
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper if defined?(ActionView::Helpers::ActiveRecordHelper)
  include ActionView::Helpers::ActiveModelHelper if defined?(ActionView::Helpers::ActiveModelHelper)
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper
  include ActiveSupport
  include ActionController::PolymorphicRoutes
  
  include Formtastic::SemanticFormHelper
  
  def default_input_type(column_type, column_name = :generic_column_name)
    @new_post.stub!(column_name)
    @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => column_type)) unless column_type.nil?

    semantic_form_for(@new_post) do |builder|
      @default_type = builder.send(:default_input_type, column_name)
    end

    return @default_type
  end
  
  class ::Post
    extend ActiveModel::Naming if defined?(ActiveModel::Naming)
    include ActiveModel::Conversion if defined?(ActiveModel::Conversion)

    def id
    end

    def persisted?
    end
  end
  module ::Namespaced
    class Post
      extend ActiveModel::Naming if defined?(ActiveModel::Naming)
      include ActiveModel::Conversion if defined?(ActiveModel::Conversion)

      def id
      end

      def persisted?
      end
    end
  end
  class ::Author
    extend ActiveModel::Naming if defined?(ActiveModel::Naming)
    include ActiveModel::Conversion if defined?(ActiveModel::Conversion)

    def to_label
    end
  end
  class ::Continent
    extend ActiveModel::Naming if defined?(ActiveModel::Naming)
    include ActiveModel::Conversion if defined?(ActiveModel::Conversion)
  end
  
  def mock_everything
    
    # Resource-oriented styles like form_for(@post) will expect a path method for the object,
    # so we're defining some here.
    def post_path(o); "/posts/1"; end
    def posts_path; "/posts"; end
    def new_post_path; "/posts/new"; end

    def author_path(o); "/authors/1"; end
    def authors_path; "/authors"; end
    def new_author_path; "/authors/new"; end
    
    @fred = mock('user')
    @fred.stub!(:class).and_return(::Author)
    @fred.stub!(:to_label).and_return('Fred Smith')
    @fred.stub!(:login).and_return('fred_smith')
    @fred.stub!(:id).and_return(37)
    @fred.stub!(:new_record?).and_return(false)
    @fred.stub!(:errors).and_return(mock('errors', :[] => nil))
    @fred.stub!(:to_key).and_return(nil)
    @fred.stub!(:persisted?).and_return(nil)

    @bob = mock('user')
    @bob.stub!(:class).and_return(::Author)
    @bob.stub!(:to_label).and_return('Bob Rock')
    @bob.stub!(:login).and_return('bob')
    @bob.stub!(:created_at)
    @bob.stub!(:id).and_return(42)
    @bob.stub!(:posts).and_return([])
    @bob.stub!(:post_ids).and_return([])
    @bob.stub!(:new_record?).and_return(false)
    @bob.stub!(:errors).and_return(mock('errors', :[] => nil))
    @bob.stub!(:to_key).and_return(nil)
    @bob.stub!(:persisted?).and_return(nil)
    
    @james = mock('user')
    @james.stub!(:class).and_return(::Author)
    @james.stub!(:to_label).and_return('James Shock')
    @james.stub!(:login).and_return('james')
    @james.stub!(:id).and_return(75)
    @james.stub!(:posts).and_return([])
    @james.stub!(:post_ids).and_return([])
    @james.stub!(:new_record?).and_return(false)
    @james.stub!(:errors).and_return(mock('errors', :[] => nil))
    @james.stub!(:to_key).and_return(nil)
    @james.stub!(:persisted?).and_return(nil)
    

    ::Author.stub!(:find).and_return([@fred, @bob])
    ::Author.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Author.stub!(:human_name).and_return('::Author')
    ::Author.stub!(:reflect_on_validations_for).and_return([])
    ::Author.stub!(:reflect_on_association).and_return { |column_name| mock('reflection', :options => {}, :klass => Post, :macro => :has_many) if column_name == :posts }
    ::Author.stub!(:content_columns).and_return([mock('column', :name => 'login'), mock('column', :name => 'created_at')])
    ::Author.stub!(:to_key).and_return(nil)
    ::Author.stub!(:persisted?).and_return(nil)

    # Sometimes we need a mock @post object and some Authors for belongs_to
    @new_post = mock('post')
    @new_post.stub!(:class).and_return(::Post)
    @new_post.stub!(:id).and_return(nil)
    @new_post.stub!(:new_record?).and_return(true)
    @new_post.stub!(:errors).and_return(mock('errors', :[] => nil))
    @new_post.stub!(:author).and_return(nil)
    @new_post.stub!(:main_post).and_return(nil)
    @new_post.stub!(:sub_posts).and_return([]) #TODO should be a mock with methods for adding sub posts
    @new_post.stub!(:to_key).and_return(nil)
    @new_post.stub!(:to_model).and_return(@new_post)
    @new_post.stub!(:persisted?).and_return(nil)

    @freds_post = mock('post')
    @freds_post.stub!(:class).and_return(::Post)
    @freds_post.stub!(:to_label).and_return('Fred Smith')
    @freds_post.stub!(:id).and_return(19)
    @freds_post.stub!(:author).and_return(@fred)
    @freds_post.stub!(:author_id).and_return(@fred.id)
    @freds_post.stub!(:authors).and_return([@fred])
    @freds_post.stub!(:author_ids).and_return([@fred.id])
    @freds_post.stub!(:new_record?).and_return(false)
    @freds_post.stub!(:errors).and_return(mock('errors', :[] => nil))
    @freds_post.stub!(:to_key).and_return(nil)
    @freds_post.stub!(:persisted?).and_return(nil)
    @fred.stub!(:posts).and_return([@freds_post])
    @fred.stub!(:post_ids).and_return([@freds_post.id])

    ::Post.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Post.stub!(:human_name).and_return('Post')
    ::Post.stub!(:reflect_on_all_validations).and_return([])
    ::Post.stub!(:reflect_on_validations_for).and_return([])
    ::Post.stub!(:reflect_on_association).and_return do |column_name|
      case column_name
      when :author, :author_status
        mock = mock('reflection', :options => {}, :klass => ::Author, :macro => :belongs_to)
        mock.stub!(:[]).with(:class_name).and_return("Author")
        mock
      when :authors
        mock('reflection', :options => {}, :klass => ::Author, :macro => :has_and_belongs_to_many)
      when :sub_posts
        mock('reflection', :options => {}, :klass => ::Post, :macro => :has_many)
      when :main_post
        mock('reflection', :options => {}, :klass => ::Post, :macro => :belongs_to)
      end
      
    end
    ::Post.stub!(:find).and_return([@freds_post])
    ::Post.stub!(:content_columns).and_return([mock('column', :name => 'title'), mock('column', :name => 'body'), mock('column', :name => 'created_at')])
    ::Post.stub!(:to_key).and_return(nil)
    ::Post.stub!(:persisted?).and_return(nil)
    
    @new_post.stub!(:title)
    @new_post.stub!(:body)
    @new_post.stub!(:published)
    @new_post.stub!(:publish_at)
    @new_post.stub!(:created_at)
    @new_post.stub!(:secret)
    @new_post.stub!(:time_zone)
    @new_post.stub!(:category_name)
    @new_post.stub!(:allow_comments)
    @new_post.stub!(:column_for_attribute).with(:meta_description).and_return(mock('column', :type => :string, :limit => 255))
    @new_post.stub!(:column_for_attribute).with(:title).and_return(mock('column', :type => :string, :limit => 50))
    @new_post.stub!(:column_for_attribute).with(:body).and_return(mock('column', :type => :text))
    @new_post.stub!(:column_for_attribute).with(:published).and_return(mock('column', :type => :boolean))
    @new_post.stub!(:column_for_attribute).with(:publish_at).and_return(mock('column', :type => :date))
    @new_post.stub!(:column_for_attribute).with(:time_zone).and_return(mock('column', :type => :string))
    @new_post.stub!(:column_for_attribute).with(:allow_comments).and_return(mock('column', :type => :boolean))
    
    @new_post.stub!(:author).and_return(@bob)
    @new_post.stub!(:author_id).and_return(@bob.id)

    @new_post.should_receive(:publish_at=).any_number_of_times
    @new_post.should_receive(:title=).any_number_of_times
    @new_post.stub!(:main_post_id).and_return(nil)
        
  end
  
  def self.included(base)
    base.class_eval do
      
      attr_accessor :output_buffer
      
      def protect_against_forgery?
        false
      end
      
    end
  end
  
  def with_config(config_method_name, value, &block)
    old_value = ::Formtastic::SemanticFormBuilder.send(config_method_name)
    ::Formtastic::SemanticFormBuilder.send(:"#{config_method_name}=", value)
    yield
    ::Formtastic::SemanticFormBuilder.send(:"#{config_method_name}=", old_value)
  end
  
  def with_deprecation_silenced(&block)
    ::ActiveSupport::Deprecation.silenced = true
    yield
    ::ActiveSupport::Deprecation.silenced = false
  end
  
end

::ActiveSupport::Deprecation.silenced = false
