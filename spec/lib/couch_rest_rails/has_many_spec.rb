require File.dirname(__FILE__) + '/../../spec_helper'

describe "CouchRestRails::Document#has_many" do

  before :each do
    setup_foo_bars

    CouchRestRails::Database.create('foo')

    class ::TestReview < CouchRestRails::Document
      use_database :foo
    end

    class ::TestProduct < CouchRestRails::Document
      use_database :foo

      has_many :test_reviews
    end

  end
  
  after :all do
    cleanup_foo_bars
  end
  
  it "should define a view on the foreign class by the foreign key" do
    ::TestReview.should have_view(:by_test_product_id)
    lambda { TestReview.by_test_product_id }.should_not raise_error
  end

  describe "association getter on the receiver" do
    before :each do
      @test_product = TestProduct.new
    end

    it "should be defined" do
      @test_product.should respond_to(:test_reviews)
    end

    it "should call the view on the foreign class with the id as an argument and the rest of the options expanded" do
      expected_opts = [ 'options', 'and', 'more arguments']
      TestReview.should_receive(:by_test_product_id).with(@test_product.id, *expected_opts)

      @test_product.test_reviews(*expected_opts)
    end
    
  end
  
end

